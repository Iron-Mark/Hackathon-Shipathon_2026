// Real-time game runtime. Owns frame state: player transform, velocity,
// camera, collision, animation and the active interaction target. Nothing
// here decides fitness outcomes; interactions are handed to a callback that
// routes them to application use cases.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../domain/content.dart';
import 'collision.dart';
import 'gym_world.dart';
import 'input.dart';
import 'interaction.dart';

typedef InteractCallback = void Function(InteractableDefinition target);

class GameRuntime {
  GameRuntime({
    required this.district,
    required this.onInteract,
    this.reducedMotion = false,
    this.graphicsQuality = 'medium',
  });

  final DistrictDefinition district;
  final InteractCallback onInteract;
  bool reducedMotion;
  final String graphicsQuality;

  final Scene scene = Scene();
  final InputState input = InputState();
  late final KeyboardInputAdapter keyboard = KeyboardInputAdapter(input);
  late final TouchInputAdapter touch = TouchInputAdapter(input);

  late final GymWorld world;
  late final CollisionWorld collision;
  late final InteractionSystem interactions;

  /// The active interaction target, published only when it changes.
  final ValueNotifier<InteractableDefinition?> target = ValueNotifier(null);

  /// While true the world keeps rendering but input is ignored (panels open).
  bool paused = false;

  /// Interact presses are ignored for a moment after a panel closes so the
  /// key that closed it cannot immediately re-open it.
  double _interactCooldown = 0;
  void lockInteract([double seconds = 0.35]) => _interactCooldown = seconds;

  static const playerRadius = 0.32;
  static const walkSpeed = 3.4; // m/s
  static const cameraOffset = (x: 0.0, y: 9.2, z: 6.8);

  vm.Vector3 _position = vm.Vector3.zero();
  double _yaw = 0; // radians, world facing around +Y
  vm.Vector2 _facing = vm.Vector2(0, -1);
  vm.Vector3 _cameraPos = vm.Vector3.zero();
  vm.Vector3 _cameraTarget = vm.Vector3.zero();
  double _walkPhase = 0;
  double _idleTime = 0;
  double _interactPose = 0;
  double _speedBlend = 0;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  vm.Vector3 get playerPosition => _position.clone();

  Future<void> load() async {
    await Scene.initializeStaticResources();
    world = GymWorld(district, graphicsQuality: graphicsQuality);
    await world.build(scene);
    final b = district.bounds;
    collision = CollisionWorld(
      bounds: WorldBounds(b['minX']!, b['minZ']!, b['maxX']!, b['maxZ']!),
      colliders: [
        for (final i in district.interactables)
          if (i.solid)
            BoxCollider.centered(i.x, i.z, i.width, i.depth, id: i.id),
        for (final c in district.colliders)
          BoxCollider.centered(c.x, c.z, c.width, c.depth),
      ],
    );
    interactions = InteractionSystem(district.interactables);
    respawn();
    _loaded = true;
  }

  void respawn() {
    _position = vm.Vector3(district.spawn.x, 0, district.spawn.z);
    _facing = vm.Vector2(0, -1);
    _yaw = math.atan2(_facing.x, _facing.y);
    _cameraPos = _desiredCameraPos();
    _cameraTarget = _desiredCameraTarget();
    _applyPlayerTransform();
  }

  /// Camera-relative movement basis: screen "up" moves the player away from
  /// the camera along the ground, screen "right" moves along +X.
  // flutter_scene is left-handed: with the camera on +Z looking toward -Z,
  // world +X appears on the left of the screen, so screen-right is -X.
  static final vm.Vector2 _forward = vm.Vector2(0, -1);
  static final vm.Vector2 _right = vm.Vector2(-1, 0);

  void tick(double dt) {
    if (!_loaded) return;
    // Sub-step long frames so slow devices keep real-time speed without
    // tunnelling through thin colliders.
    dt = dt.clamp(0.0, 0.4);
    final steps = (dt / 0.05).ceil().clamp(1, 8);
    final move = paused ? vm.Vector2.zero() : input.movement;
    final pressed = input.consumeInteract();
    final wantInteract = pressed && !paused && _interactCooldown <= 0;
    _interactCooldown = math.max(0, _interactCooldown - dt);

    final velocity = (_right * move.x + _forward * move.y) * walkSpeed;
    final moving = velocity.length2 > 1e-4;
    if (moving) {
      final stepDelta = velocity * (dt / steps);
      for (var i = 0; i < steps; i++) {
        _position = collision.move(_position, stepDelta, playerRadius);
      }
      _facing = velocity.normalized();
      final targetYaw = math.atan2(_facing.x, _facing.y);
      _yaw = _lerpAngle(
        _yaw,
        targetYaw,
        reducedMotion ? 1 : 1 - math.exp(-14 * dt),
      );
      _walkPhase += dt * 9.5;
      _speedBlend = math.min(1, _speedBlend + dt * 8);
    } else {
      _speedBlend = math.max(0, _speedBlend - dt * 6);
      _idleTime += dt;
    }
    _interactPose = math.max(0, _interactPose - dt * 2.5);
    _applyPlayerTransform();
    world.animatePlayer(
      walkPhase: _walkPhase,
      walkWeight: _speedBlend,
      idleTime: _idleTime,
      interactPose: _interactPose,
    );
    world.animateCoach(_idleTime);

    // Camera: fixed angle, damped follow.
    final smoothing = reducedMotion ? 1.0 : 1 - math.exp(-6 * dt);
    _cameraPos = _cameraPos + (_desiredCameraPos() - _cameraPos) * smoothing;
    _cameraTarget =
        _cameraTarget + (_desiredCameraTarget() - _cameraTarget) * smoothing;

    // Interaction targeting.
    final p = vm.Vector2(_position.x, _position.z);
    final selected = interactions.select(p, _facing)?.definition;
    if (selected?.id != target.value?.id) {
      target.value = selected;
      world.highlight(selected);
    }
    if (wantInteract && selected != null) {
      _interactPose = 1;
      onInteract(selected);
    }
  }

  vm.Vector3 _desiredCameraPos() => vm.Vector3(
    _position.x + cameraOffset.x,
    cameraOffset.y,
    _position.z + cameraOffset.z,
  );

  vm.Vector3 _desiredCameraTarget() =>
      vm.Vector3(_position.x, 0.9, _position.z - 0.6);

  Camera get camera => PerspectiveCamera(
    position: _cameraPos,
    target: _cameraTarget,
    fovRadiansY: 36 * vm.degrees2Radians,
    fovNear: 0.5,
    fovFar: 80,
  );

  void _applyPlayerTransform() {
    world.placePlayer(_position, _yaw);
  }

  static double _lerpAngle(double a, double b, double t) {
    var d = (b - a) % (2 * math.pi);
    if (d > math.pi) d -= 2 * math.pi;
    if (d < -math.pi) d += 2 * math.pi;
    return a + d * t;
  }

  void dispose() {
    target.dispose();
  }
}
