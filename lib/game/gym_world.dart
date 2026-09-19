// Builds the Hypertrophy Gym scene from the district definition and the
// AssetCatalog. Generated GLB models are preferred; if a model fails to load
// the object is built from primitives so the game always stays playable.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart'
    show Color, FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../domain/content.dart';
import 'asset_catalog.dart';

class GymWorld {
  GymWorld(this.district, {this.graphicsQuality = 'medium'});

  final DistrictDefinition district;
  final String graphicsQuality;

  final Node root = Node(name: 'gym');
  final Node playerRoot = Node(name: 'player_root');
  Node? _coachModel;
  final Map<String, Node> _stationNodes = {};
  final Map<String, Node> _limbs = {};
  final Map<String, vm.Vector3> _limbRest = {};
  late final Node _marker;
  final List<String> loadWarnings = [];

  /// Yaw applied to imported humanoids so their modelled front (+Z, toward
  /// the camera side) matches the runtime's yaw convention.
  static const modelFacingOffset = 0.0;

  static final _accent = vm.Vector4(0.95, 0.55, 0.22, 1);

  Future<void> build(Scene scene) async {
    scene.add(root);
    _configureLighting(scene);

    final gym = await _load(AssetCatalog.gym, fallback: _fallbackGym);
    // The shell is always on screen; skipping its frustum test removes the
    // one way a stale/imprecise bound could blank the floor and walls for a
    // frame while the camera moves.
    _disableCulling(gym);
    root.add(gym);

    for (final def in district.interactables) {
      final node = Node(name: def.id)
        ..position = vm.Vector3(def.x, 0, def.z)
        ..rotation = vm.Quaternion.axisAngle(
          vm.Vector3(0, 1, 0),
          def.rotationY,
        );
      final placements = AssetCatalog.stations[def.asset] ?? const [];
      if (placements.isEmpty) {
        node.add(
          _fallbackBox(
            def.width,
            1.0,
            def.depth,
            vm.Vector4(0.3, 0.3, 0.32, 1),
          ),
        );
      }
      for (final p in placements) {
        final model = await _load(
          p.path,
          fallback: () => _fallbackStation(def),
        );
        model.position = vm.Vector3(p.dx, 0, p.dz);
        if (p.rotationY != 0) {
          model.rotation = vm.Quaternion.axisAngle(
            vm.Vector3(0, 1, 0),
            p.rotationY,
          );
        }
        if (def.isNpc) {
          _coachModel = model;
          // The coach faces the entrance / camera side (+Z).
          model.rotation = vm.Quaternion.axisAngle(
            vm.Vector3(0, 1, 0),
            modelFacingOffset,
          );
        }
        node.add(model);
      }
      _stationNodes[def.id] = node;
      root.add(node);
    }

    final player = await _load(
      AssetCatalog.player,
      fallback: () => _fallbackHumanoid(vm.Vector4(0.3, 0.44, 0.54, 1)),
    );
    for (final limb in ['arm_l', 'arm_r', 'leg_l', 'leg_r', 'torso', 'head']) {
      final n = player.getChildByName(limb);
      if (n != null) {
        _limbs[limb] = n;
        _limbRest[limb] = n.position;
      }
    }
    playerRoot.add(player);
    root.add(playerRoot);

    _marker = Node(
      name: 'interaction_marker',
      mesh: Mesh(
        RingGeometry(innerRadius: 0.55, outerRadius: 0.72, segments: 40),
        UnlitMaterial()..baseColorFactor = _accent,
      ),
    )..visible = false;
    root.add(_marker);

    for (final sign in AssetCatalog.signs) {
      await _attachSign(sign);
    }
  }

  void _configureLighting(Scene scene) {
    scene.environmentIntensity = 0.55;
    scene.exposure = 0.85;
    // Single-sample targets + FXAA: avoids MSAA resolve paths that some
    // WebGL/ANGLE drivers drop frames on, and is cheaper on mobile GPUs.
    scene.antiAliasingMode = AntiAliasingMode.fxaa;
    final shadows = graphicsQuality != 'low';
    if (graphicsQuality == 'low') scene.renderScale = 0.75;
    scene.directionalLight = DirectionalLight(
      direction: vm.Vector3(-0.35, -1.0, 0.45),
      color: vm.Vector3(1.0, 0.93, 0.82),
      intensity: 2.6,
      castsShadow: shadows,
      shadowMapResolution: graphicsQuality == 'high' ? 2048 : 1024,
      // One 40m gym: two cascades cover it; four just doubles shadow passes.
      shadowCascadeCount: 2,
      shadowMaxDistance: 40,
      shadowSoftness: 0.06,
    );
    if (graphicsQuality == 'high') {
      scene.ambientOcclusion.enabled = true;
      scene.ambientOcclusion.intensity = 0.8;
    }
  }

  void _disableCulling(Node node) {
    node.frustumCulled = false;
    for (final child in node.children) {
      _disableCulling(child);
    }
  }

  Future<Node> _load(String path, {required Node Function() fallback}) async {
    try {
      return await loadScene(path);
    } catch (e) {
      loadWarnings.add('$path: $e');
      debugPrint('IRON ASCENT asset fallback for $path: $e');
      return fallback();
    }
  }

  // ---------------------------------------------------------------------
  // Runtime updates
  // ---------------------------------------------------------------------

  void placePlayer(vm.Vector3 position, double yaw) {
    playerRoot.position = position;
    playerRoot.rotation = vm.Quaternion.axisAngle(
      vm.Vector3(0, 1, 0),
      yaw + modelFacingOffset,
    );
  }

  void animatePlayer({
    required double walkPhase,
    required double walkWeight,
    required double idleTime,
    required double interactPose,
  }) {
    final swing = math.sin(walkPhase) * 0.75 * walkWeight;
    _swing('arm_l', -swing + interactPose * -1.6);
    _swing('arm_r', swing);
    _swing('leg_l', swing);
    _swing('leg_r', -swing);
    final torso = _limbs['torso'];
    final rest = _limbRest['torso'];
    if (torso != null && rest != null) {
      final bob =
          math.sin(idleTime * 1.6) * 0.012 * (1 - walkWeight) +
          math.sin(walkPhase * 2).abs() * 0.03 * walkWeight;
      torso.position = vm.Vector3(rest.x, rest.y + bob, rest.z);
    }
  }

  void animateCoach(double time) {
    final coach = _coachModel;
    if (coach == null) return;
    final torso = coach.getChildByName('torso');
    if (torso == null) return;
    final bob = math.sin(time * 1.3) * 0.01;
    torso.position = vm.Vector3(0, 0.95 * (1.85 / 1.75) + bob, 0);
  }

  void _swing(String limb, double angle) {
    final n = _limbs[limb];
    if (n == null) return;
    n.rotation = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), angle);
  }

  void highlight(InteractableDefinition? def) {
    if (def == null) {
      _marker.visible = false;
      return;
    }
    _marker
      ..visible = true
      ..position = vm.Vector3(def.x, 0.04, def.z)
      ..scale = vm.Vector3.all(math.max(def.width, def.depth) * 0.75);
  }

  // ---------------------------------------------------------------------
  // Signage
  // ---------------------------------------------------------------------

  Future<void> _attachSign(SignDefinition sign) async {
    try {
      final texture = await _renderSignTexture(sign);
      final w = sign.width, h = sign.height;
      // Screen-right is world -X, so U runs from +X (0) to -X (1) to keep
      // the text readable from the camera side.
      final builder = GeometryBuilder(deduplicate: false)
        ..texCoord(vm.Vector2(1, 1))
        ..addVertex(vm.Vector3(-w / 2, -h / 2, 0))
        ..texCoord(vm.Vector2(0, 1))
        ..addVertex(vm.Vector3(w / 2, -h / 2, 0))
        ..texCoord(vm.Vector2(0, 0))
        ..addVertex(vm.Vector3(w / 2, h / 2, 0))
        ..texCoord(vm.Vector2(1, 0))
        ..addVertex(vm.Vector3(-w / 2, h / 2, 0))
        ..addTriangle(0, 1, 2)
        ..addTriangle(0, 2, 3);
      final node =
          Node(
              name: 'sign_${sign.text}',
              mesh: Mesh(builder.build(), UnlitMaterial(colorTexture: texture)),
            )
            ..position = vm.Vector3(sign.x, sign.y, sign.z)
            ..rotation = vm.Quaternion.axisAngle(
              vm.Vector3(0, 1, 0),
              sign.rotationY,
            );
      root.add(node);
    } catch (e) {
      loadWarnings.add('sign ${sign.text}: $e');
      debugPrint('IRON ASCENT sign skipped (${sign.text}): $e');
    }
  }

  /// Rasterizes a wayfinding sign (text on a plate) into a small texture.
  Future<Texture2D> _renderSignTexture(SignDefinition sign) async {
    const height = 128.0;
    final width = (height * sign.width / sign.height).roundToDouble();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final bg = sign.accent ? const Color(0xFF2A1A10) : const Color(0xFF1C1E22);
    final frame = sign.accent
        ? const Color(0xFFBD5C1F)
        : const Color(0xFF4A4E55);
    final fg = sign.accent ? const Color(0xFFF2B27A) : const Color(0xFFE6E2D8);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width, height),
      ui.Paint()..color = frame,
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(8, 8, width - 16, height - 16),
      ui.Paint()..color = bg,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: sign.text,
        style: TextStyle(
          color: fg,
          fontSize: height * 0.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 24);
    painter.paint(
      canvas,
      ui.Offset((width - painter.width) / 2, (height - painter.height) / 2),
    );
    final image = await recorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    return Texture2D.fromImage(image);
  }

  // ---------------------------------------------------------------------
  // Primitive fallbacks (used only when a generated model fails to load)
  // ---------------------------------------------------------------------

  Node _fallbackBox(
    double w,
    double h,
    double d,
    vm.Vector4 color, {
    double y = 0,
  }) => Node(
    mesh: Mesh(
      CuboidGeometry(vm.Vector3(w, h, d)),
      PhysicallyBasedMaterial()
        ..baseColorFactor = color
        ..roughnessFactor = 0.9
        ..metallicFactor = 0.0,
    ),
  )..position = vm.Vector3(0, y + h / 2, 0);

  Node _fallbackHumanoid(vm.Vector4 color) {
    final skin = vm.Vector4(0.8, 0.62, 0.5, 1);
    final n = Node(name: 'humanoid_fallback');
    final torso = Node(name: 'torso')..position = vm.Vector3(0, 0.95, 0);
    torso.add(_fallbackBox(0.42, 0.5, 0.24, color, y: 0.17));
    torso.add(
      _fallbackBox(0.36, 0.18, 0.22, vm.Vector4(0.2, 0.2, 0.23, 1), y: -0.01),
    );
    final head = Node(name: 'head')..position = vm.Vector3(0, 0.73, 0);
    head.add(_fallbackBox(0.24, 0.26, 0.24, skin));
    torso.add(head);
    for (final side in [1.0, -1.0]) {
      final s = side > 0 ? 'l' : 'r';
      final arm = Node(name: 'arm_$s')
        ..position = vm.Vector3(side * 0.27, 0.62, 0);
      arm.add(_fallbackBox(0.12, 0.6, 0.12, skin, y: -0.62));
      torso.add(arm);
      final leg = Node(name: 'leg_$s')
        ..position = vm.Vector3(side * 0.1, 0.95, 0);
      leg.add(
        _fallbackBox(0.15, 0.9, 0.16, vm.Vector4(0.2, 0.2, 0.23, 1), y: -0.92),
      );
      n.add(leg);
    }
    n.add(torso);
    return n;
  }

  Node _fallbackStation(InteractableDefinition def) {
    final steel = vm.Vector4(0.22, 0.23, 0.26, 1);
    final pad = vm.Vector4(0.26, 0.22, 0.20, 1);
    final n = Node(name: '${def.id}_fallback');
    switch (def.asset) {
      case 'incline_press':
        n.add(_fallbackBox(0.4, 0.1, 0.5, pad, y: 0.45));
        n.add(
          _fallbackBox(0.4, 0.7, 0.1, pad, y: 0.5)
            ..position = vm.Vector3(0, 0.85, -0.3),
        );
        n.add(_fallbackBox(0.1, 0.45, 1.0, steel));
        n.add(
          _fallbackBox(0.1, 0.1, 0.3, steel, y: 0.05)
            ..position = vm.Vector3(0.7, 0.1, 0.2),
        );
      case 'machine_chest_press':
        n.add(
          _fallbackBox(0.4, 0.1, 0.4, pad, y: 0.45)
            ..position = vm.Vector3(0.15, 0.5, 0.15),
        );
        n.add(
          _fallbackBox(0.4, 0.7, 0.1, pad)
            ..position = vm.Vector3(0.15, 0.95, -0.1),
        );
        n.add(
          _fallbackBox(0.3, 1.9, 0.5, steel)
            ..position = vm.Vector3(-0.6, 0.95, 0),
        );
        n.add(
          _fallbackBox(1.1, 0.08, 0.08, steel)
            ..position = vm.Vector3(0.15, 1.4, -0.15),
        );
      case 'cable_fly':
        for (final x in [-0.95, 0.95]) {
          n.add(
            _fallbackBox(0.46, 2.3, 0.36, steel)
              ..position = vm.Vector3(x, 1.15, 0),
          );
        }
        n.add(
          _fallbackBox(2.3, 0.1, 0.12, vm.Vector4(0.74, 0.36, 0.12, 1))
            ..position = vm.Vector3(0, 2.25, 0),
        );
      case 'water_station':
        n.add(_fallbackBox(0.42, 1.0, 0.42, vm.Vector4(0.72, 0.74, 0.76, 1)));
        n.add(
          _fallbackBox(0.3, 0.4, 0.3, vm.Vector4(0.3, 0.58, 0.78, 1), y: 1.0),
        );
      case 'recovery_mat':
        n.add(_fallbackBox(1.1, 0.05, 1.8, vm.Vector4(0.22, 0.42, 0.38, 1)));
      case 'coach':
        return _fallbackHumanoid(vm.Vector4(0.15, 0.15, 0.16, 1));
      default:
        n.add(_fallbackBox(def.width, 1.0, def.depth, steel));
    }
    return n;
  }

  Node _fallbackGym() {
    final b = district.bounds;
    final minX = b['minX']!,
        maxX = b['maxX']!,
        minZ = b['minZ']!,
        maxZ = b['maxZ']!;
    final w = maxX - minX, d = maxZ - minZ;
    final cx = (minX + maxX) / 2, cz = (minZ + maxZ) / 2;
    final n = Node(name: 'gym_fallback');
    n.add(
      _fallbackBox(
        w + 0.6,
        0.1,
        d + 0.6,
        vm.Vector4(0.11, 0.11, 0.12, 1),
        y: -0.1,
      )..position = vm.Vector3(cx, -0.05, cz),
    );
    final concrete = vm.Vector4(0.56, 0.54, 0.5, 1);
    n.add(
      _fallbackBox(w + 0.6, 3.2, 0.3, concrete)
        ..position = vm.Vector3(cx, 1.6, minZ - 0.15),
    );
    n.add(
      _fallbackBox(0.3, 3.2, d + 0.6, concrete)
        ..position = vm.Vector3(minX - 0.15, 1.6, cz),
    );
    n.add(
      _fallbackBox(0.3, 3.2, d + 0.6, concrete)
        ..position = vm.Vector3(maxX + 0.15, 1.6, cz),
    );
    n.add(
      _fallbackBox(w + 0.6, 0.9, 0.3, concrete)
        ..position = vm.Vector3(cx, 0.45, maxZ + 0.15),
    );
    return n;
  }
}
