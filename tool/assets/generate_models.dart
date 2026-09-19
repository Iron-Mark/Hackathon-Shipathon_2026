// Generates the original low-poly IRON ASCENT model kit as GLB files.
//
//   dart run tool/assets/generate_models.dart
//
// Output: assets/models/*.glb (converted to .fsceneb by flutter_scene's build
// hook at build time and loaded through the AssetCatalog by source path).
// Conventions: metres, Y up, ground at y = 0, model front faces +Z.
import 'dart:io';

import 'glb_writer.dart';

// Shared palette: industrial grit + hopeful rebuilding.
const concrete = Mat('concrete', 0.56, 0.54, 0.50, roughness: 0.95);
const concreteDark = Mat('concrete_dark', 0.36, 0.35, 0.34, roughness: 0.95);
const rubberFloor = Mat('rubber_floor', 0.21, 0.21, 0.23, roughness: 0.9);
const recoveryFloor = Mat('recovery_floor', 0.30, 0.34, 0.31, roughness: 0.9);
const darkSteel = Mat(
  'dark_steel',
  0.20,
  0.21,
  0.24,
  metallic: 0.7,
  roughness: 0.55,
);
const paintedSteel = Mat(
  'painted_steel',
  0.33,
  0.36,
  0.34,
  metallic: 0.2,
  roughness: 0.6,
);
const rustAccent = Mat('rust_accent', 0.74, 0.36, 0.12, roughness: 0.65);
const blackRubber = Mat('black_rubber', 0.05, 0.05, 0.06, roughness: 0.85);
const wornFabric = Mat('worn_fabric', 0.26, 0.22, 0.20, roughness: 0.95);
const ironPlate = Mat(
  'iron_plate',
  0.14,
  0.14,
  0.15,
  metallic: 0.8,
  roughness: 0.45,
);
const wood = Mat('wood', 0.46, 0.33, 0.20, roughness: 0.9);
const warmLight = Mat(
  'warm_light',
  1.0,
  0.86,
  0.62,
  emissive: 4.0,
  roughness: 0.4,
);
const dayLight = Mat(
  'day_light',
  0.86,
  0.90,
  0.98,
  emissive: 2.6,
  roughness: 0.4,
);
const chrome = Mat('mirror', 0.85, 0.86, 0.88, metallic: 1.0, roughness: 0.05);
const waterBlue = Mat('water_blue', 0.30, 0.58, 0.78, roughness: 0.3);
const coolerBody = Mat(
  'cooler_body',
  0.72,
  0.74,
  0.76,
  metallic: 0.1,
  roughness: 0.5,
);
const paperCup = Mat('paper_cup', 0.90, 0.88, 0.84, roughness: 0.8);
const matTeal = Mat('mat_teal', 0.22, 0.42, 0.38, roughness: 0.95);
const matDark = Mat('mat_dark', 0.14, 0.26, 0.24, roughness: 0.95);
const towel = Mat('towel', 0.82, 0.80, 0.76, roughness: 0.95);
const skin = Mat('skin', 0.80, 0.62, 0.50, roughness: 0.8);
const skinCoach = Mat('skin_coach', 0.56, 0.40, 0.30, roughness: 0.8);
const hair = Mat('hair', 0.16, 0.12, 0.10, roughness: 0.9);
const shirt = Mat('shirt', 0.30, 0.44, 0.54, roughness: 0.9);
const shorts = Mat('shorts', 0.20, 0.20, 0.23, roughness: 0.9);
const shoe = Mat('shoe', 0.12, 0.12, 0.13, roughness: 0.8);
const coachShirt = Mat('coach_shirt', 0.15, 0.15, 0.16, roughness: 0.9);
const coachPants = Mat('coach_pants', 0.28, 0.29, 0.31, roughness: 0.9);
const eye = Mat('eye', 0.08, 0.07, 0.07, roughness: 0.5);

void humanoid(
  GlbModel model, {
  required double height,
  required double bulk,
  required Mat skinMat,
  required Mat top,
  required Mat bottom,
  bool cap = false,
  bool stripe = false,
}) {
  final s = height / 1.75;
  final b = bulk; // 1.0 neutral, 1.25 trained
  final root = model.node('root');
  final torso = root.child('torso', v3(0, 0.95 * s, 0));
  torso.box(v3(0, 0.08 * s, 0), v3(0.36 * s * b, 0.18 * s, 0.22 * s), bottom);
  torso.box(v3(0, 0.42 * s, 0), v3(0.42 * s * b, 0.50 * s, 0.24 * s * b), top);
  if (stripe) {
    torso.box(
      v3(0, 0.50 * s, 0.121 * s * b),
      v3(0.34 * s * b, 0.06 * s, 0.01),
      rustAccent,
    );
  }
  torso.cylinder(v3(0, 0.70 * s, 0), 0.05 * s, 0.06 * s, skinMat, segments: 8);

  final head = torso.child('head', v3(0, 0.73 * s, 0));
  head.box(v3(0, 0.13 * s, 0), v3(0.24 * s, 0.26 * s, 0.24 * s), skinMat);
  if (cap) {
    head.box(
      v3(0, 0.255 * s, -0.01 * s),
      v3(0.27 * s, 0.07 * s, 0.27 * s),
      coachShirt,
    );
    head.box(
      v3(0, 0.23 * s, 0.17 * s),
      v3(0.24 * s, 0.02 * s, 0.12 * s),
      coachShirt,
    );
  } else {
    head.box(
      v3(0, 0.255 * s, -0.02 * s),
      v3(0.26 * s, 0.06 * s, 0.26 * s),
      hair,
    );
  }
  for (final x in [-0.06, 0.06]) {
    head.box(
      v3(x * s, 0.15 * s, 0.121 * s),
      v3(0.035 * s, 0.035 * s, 0.01),
      eye,
    );
  }

  for (final side in [1.0, -1.0]) {
    final name = side > 0 ? 'l' : 'r';
    final arm = torso.child('arm_$name', v3(side * 0.27 * s * b, 0.62 * s, 0));
    arm.box(v3(0, -0.10 * s, 0), v3(0.13 * s * b, 0.22 * s, 0.13 * s * b), top);
    arm.box(
      v3(0, -0.40 * s, 0),
      v3(0.11 * s * b, 0.38 * s, 0.11 * s * b),
      skinMat,
    );
    arm.box(
      v3(0, -0.62 * s, 0.01 * s),
      v3(0.10 * s, 0.08 * s, 0.10 * s),
      skinMat,
    );

    final leg = root.child('leg_$name', v3(side * 0.10 * s, 0.95 * s, 0));
    leg.box(v3(0, -0.24 * s, 0), v3(0.16 * s * b, 0.46 * s, 0.18 * s), bottom);
    leg.box(v3(0, -0.68 * s, 0), v3(0.13 * s, 0.42 * s, 0.14 * s), skinMat);
    leg.box(v3(0, -0.91 * s, 0.04 * s), v3(0.14 * s, 0.08 * s, 0.27 * s), shoe);
  }
}

GlbModel player() {
  final m = GlbModel('player_base');
  humanoid(
    m,
    height: 1.75,
    bulk: 1.0,
    skinMat: skin,
    top: shirt,
    bottom: shorts,
  );
  return m;
}

GlbModel coach() {
  final m = GlbModel('hypertrophy_coach');
  humanoid(
    m,
    height: 1.85,
    bulk: 1.22,
    skinMat: skinCoach,
    top: coachShirt,
    bottom: coachPants,
    cap: true,
    stripe: true,
  );
  return m;
}

GlbModel inclineBench() {
  final m = GlbModel('incline_bench');
  final n = m.node('bench');
  for (final x in [-0.22, 0.22]) {
    n.box(v3(x, 0.04, -0.05), v3(0.08, 0.06, 1.30), darkSteel);
  }
  n.box(v3(0, 0.04, -0.62), v3(0.62, 0.06, 0.08), darkSteel);
  n.box(v3(0, 0.04, 0.52), v3(0.62, 0.06, 0.08), darkSteel);
  n.box(v3(0, 0.25, 0.30), v3(0.10, 0.42, 0.10), darkSteel);
  n.box(v3(0, 0.40, -0.45), v3(0.10, 0.74, 0.10), rustAccent);
  n.box(v3(0, 0.48, 0.25), v3(0.38, 0.09, 0.46), wornFabric);
  n.box(
    v3(0, 0.767, -0.175),
    v3(0.38, 0.09, 0.72),
    wornFabric,
    rotation: rotX(55),
  );
  n.box(
    v3(0, 0.60, -0.28),
    v3(0.08, 0.30, 0.08),
    darkSteel,
    rotation: rotX(55),
  );
  return m;
}

GlbModel dumbbells() {
  final m = GlbModel('dumbbells');
  final n = m.node('dumbbells');
  for (final z in [0.0, 0.32]) {
    n.cylinder(
      v3(0, 0.09, z),
      0.025,
      0.34,
      darkSteel,
      axis: v3(1, 0, 0),
      segments: 8,
    );
    for (final x in [-0.16, 0.16]) {
      n.cylinder(
        v3(x, 0.09, z),
        0.09,
        0.08,
        ironPlate,
        axis: v3(1, 0, 0),
        segments: 6,
      );
    }
  }
  return m;
}

GlbModel machinePress() {
  final m = GlbModel('machine_chest_press');
  final n = m.node('machine');
  n.box(v3(0, 0.04, 0), v3(1.50, 0.08, 1.20), darkSteel);
  n.box(v3(0.15, 0.30, 0.15), v3(0.10, 0.44, 0.10), darkSteel);
  n.box(v3(0.15, 0.52, 0.15), v3(0.42, 0.10, 0.42), wornFabric);
  n.box(v3(0.15, 0.95, -0.10), v3(0.42, 0.72, 0.10), wornFabric);
  n.box(v3(0.15, 0.75, -0.18), v3(0.10, 1.10, 0.08), darkSteel);
  // Weight tower on the left.
  for (final z in [-0.22, 0.22]) {
    n.box(v3(-0.62, 0.98, z), v3(0.06, 1.90, 0.06), paintedSteel);
  }
  n.box(v3(-0.62, 1.94, 0), v3(0.16, 0.06, 0.52), paintedSteel);
  for (var i = 0; i < 9; i++) {
    n.box(v3(-0.62, 0.16 + i * 0.065, 0), v3(0.24, 0.05, 0.40), ironPlate);
  }
  n.box(v3(-0.62, 1.32, 0), v3(0.02, 1.2, 0.02), darkSteel);
  // Press arms with handles.
  n.box(v3(0.15, 1.42, -0.15), v3(1.10, 0.08, 0.08), rustAccent);
  for (final x in [-0.22, 0.52]) {
    n.box(
      v3(x, 1.20, 0.10),
      v3(0.06, 0.06, 0.60),
      rustAccent,
      rotation: rotX(-40),
    );
    n.cylinder(v3(x, 1.02, 0.42), 0.025, 0.28, blackRubber, segments: 8);
  }
  n.box(v3(0.15, 0.14, 0.50), v3(0.40, 0.05, 0.26), blackRubber);
  return m;
}

GlbModel cableStation() {
  final m = GlbModel('cable_station');
  final n = m.node('cables');
  for (final side in [-1.0, 1.0]) {
    final x = side * 0.95;
    n.box(v3(x, 1.15, 0), v3(0.46, 2.30, 0.36), darkSteel);
    n.box(v3(x, 0.05, 0), v3(0.70, 0.10, 0.60), darkSteel);
    // Visible plate stack behind a painted guard on the inner face.
    for (var i = 0; i < 10; i++) {
      n.box(
        v3(x - side * 0.26, 0.20 + i * 0.07, 0),
        v3(0.06, 0.055, 0.28),
        ironPlate,
      );
    }
    n.box(v3(x - side * 0.30, 1.15, 0), v3(0.02, 2.1, 0.02), paintedSteel);
    // Pulley, cable and handle.
    n.cylinder(
      v3(x - side * 0.30, 2.10, 0.14),
      0.08,
      0.05,
      paintedSteel,
      axis: v3(0, 0, 1),
      segments: 10,
    );
    n.box(v3(x - side * 0.30, 1.58, 0.16), v3(0.012, 1.0, 0.012), darkSteel);
    n.box(v3(x - side * 0.30, 1.08, 0.16), v3(0.06, 0.06, 0.02), paintedSteel);
    n.cylinder(
      v3(x - side * 0.30, 1.00, 0.16),
      0.02,
      0.14,
      blackRubber,
      axis: v3(0, 0, 1),
      segments: 8,
    );
  }
  n.box(v3(0, 2.25, 0), v3(2.30, 0.10, 0.12), rustAccent);
  n.box(v3(0, 2.25, -0.10), v3(2.30, 0.06, 0.06), darkSteel);
  return m;
}

GlbModel waterStation() {
  final m = GlbModel('water_station');
  final n = m.node('water');
  n.box(v3(0, 0.50, 0), v3(0.42, 1.00, 0.42), coolerBody);
  n.box(v3(0, 0.02, 0), v3(0.46, 0.04, 0.46), darkSteel);
  n.box(v3(0, 1.02, 0), v3(0.44, 0.06, 0.44), darkSteel);
  n.cylinder(v3(0, 1.10, 0), 0.07, 0.10, waterBlue, segments: 10);
  n.cylinder(v3(0, 1.36, 0), 0.17, 0.42, waterBlue, segments: 10);
  n.cylinder(v3(0, 1.60, 0), 0.10, 0.06, waterBlue, segments: 10);
  n.box(v3(0, 0.66, 0.26), v3(0.30, 0.03, 0.12), darkSteel);
  n.box(v3(-0.06, 0.74, 0.23), v3(0.05, 0.05, 0.06), waterBlue);
  n.box(v3(0.06, 0.74, 0.23), v3(0.05, 0.05, 0.06), rustAccent);
  n.cylinder(v3(0.30, 0.85, 0), 0.04, 0.45, paperCup, segments: 8);
  n.box(v3(0.30, 1.08, 0), v3(0.06, 0.04, 0.06), darkSteel);
  return m;
}

GlbModel recoveryMat() {
  final m = GlbModel('recovery_mat');
  final n = m.node('mat');
  n.box(v3(0, 0.025, 0), v3(1.10, 0.05, 1.80), matTeal);
  n.box(v3(0, 0.051, 0.86), v3(1.10, 0.004, 0.08), matDark);
  n.box(v3(0, 0.051, -0.86), v3(1.10, 0.004, 0.08), matDark);
  n.cylinder(
    v3(0, 0.11, -0.72),
    0.075,
    0.55,
    matDark,
    axis: v3(1, 0, 0),
    segments: 10,
  );
  n.box(v3(0.32, 0.08, 0.66), v3(0.34, 0.06, 0.24), towel);
  return m;
}

GlbModel gymShell() {
  final m = GlbModel('hypertrophy_gym');
  const minX = 0.5, maxX = 15.5, minZ = 0.5, maxZ = 11.5;
  const cx = (minX + maxX) / 2, cz = (minZ + maxZ) / 2;
  const w = maxX - minX, d = maxZ - minZ;

  final floor = m.node('floor');
  floor.box(v3(cx, -0.05, cz), v3(w + 0.6, 0.10, d + 0.6), rubberFloor);
  // Calmer recovery corner and a concrete apron by the entrance.
  floor.box(v3(9.5, 0.008, 10.0), v3(8.6, 0.016, 3.0), recoveryFloor);
  floor.box(v3(2.6, 0.008, 9.9), v3(4.2, 0.016, 3.2), concrete);
  // Floor seams (subtle rubber tile grid).
  for (var x = 2.5; x < maxX; x += 2.0) {
    floor.box(v3(x, 0.004, cz), v3(0.03, 0.008, d), paintedSteel);
  }
  for (var z = 2.5; z < maxZ; z += 2.0) {
    floor.box(v3(cx, 0.004, z), v3(w, 0.008, 0.03), paintedSteel);
  }

  final walls = m.node('walls');
  // Back wall (far side), side walls, and a low parapet toward the camera.
  walls.box(v3(cx, 1.6, minZ - 0.15), v3(w + 0.6, 3.2, 0.3), concrete);
  walls.box(v3(minX - 0.15, 1.6, cz), v3(0.3, 3.2, d + 0.6), concrete);
  walls.box(v3(maxX + 0.15, 1.6, cz), v3(0.3, 3.2, d + 0.6), concrete);
  walls.box(v3(cx, 0.45, maxZ + 0.15), v3(w + 0.6, 0.9, 0.3), concrete);
  // Dark base band and a rust accent stripe.
  walls.box(v3(cx, 0.30, minZ - 0.14), v3(w + 0.6, 0.6, 0.32), concreteDark);
  walls.box(v3(minX - 0.14, 0.30, cz), v3(0.32, 0.6, d + 0.6), concreteDark);
  walls.box(v3(maxX + 0.14, 0.30, cz), v3(0.32, 0.6, d + 0.6), concreteDark);
  walls.box(v3(cx, 1.05, minZ - 0.135), v3(w + 0.6, 0.10, 0.33), rustAccent);
  walls.box(v3(minX - 0.135, 1.05, cz), v3(0.33, 0.10, d + 0.6), rustAccent);
  walls.box(v3(maxX + 0.135, 1.05, cz), v3(0.33, 0.10, d + 0.6), rustAccent);
  walls.box(v3(cx, 0.92, maxZ + 0.15), v3(w + 0.6, 0.06, 0.34), darkSteel);
  // Columns and roof beams.
  for (final x in [5.5, 10.5]) {
    walls.box(v3(x, 1.6, minZ + 0.15), v3(0.45, 3.2, 0.5), concreteDark);
  }
  for (final z in [2.0, 5.0, 8.0]) {
    walls.box(v3(cx, 3.15, z), v3(w + 0.6, 0.16, 0.16), darkSteel);
  }
  // Windows: dusty daylight on the back wall.
  for (final x in [3.2, 8.0, 12.8]) {
    walls.box(v3(x, 2.4, minZ + 0.01), v3(2.6, 1.0, 0.04), darkSteel);
    walls.box(v3(x, 2.4, minZ + 0.03), v3(2.4, 0.86, 0.02), dayLight);
    walls.box(v3(x, 2.4, minZ + 0.045), v3(0.05, 0.86, 0.02), darkSteel);
    walls.box(v3(x, 2.4, minZ + 0.045), v3(2.4, 0.05, 0.02), darkSteel);
  }
  // Mirror panel between windows.
  walls.box(v3(5.6, 1.4, minZ + 0.03), v3(1.6, 1.6, 0.03), darkSteel);
  walls.box(v3(5.6, 1.4, minZ + 0.05), v3(1.5, 1.5, 0.01), chrome);
  // Sign backing plates (text is rendered at runtime on top).
  walls.box(v3(8.0, 1.75, minZ + 0.03), v3(3.6, 0.6, 0.05), darkSteel);
  walls.box(v3(8.0, 1.75, minZ + 0.03), v3(3.7, 0.7, 0.03), rustAccent);

  final lights = m.node('lights');
  for (final p in [
    (4.0, 3.5),
    (8.0, 3.5),
    (12.0, 3.5),
    (4.0, 7.0),
    (8.0, 7.0),
    (12.0, 7.0),
  ]) {
    lights.box(v3(p.$1, 3.02, p.$2), v3(0.03, 0.14, 0.03), darkSteel);
    lights.box(v3(p.$1, 2.92, p.$2), v3(0.9, 0.12, 0.34), darkSteel);
    lights.box(v3(p.$1, 2.855, p.$2), v3(0.8, 0.02, 0.26), warmLight);
  }
  // Warmer, lower lamp over the recovery corner.
  lights.box(v3(9.5, 2.62, 10.0), v3(0.03, 0.9, 0.03), darkSteel);
  lights.box(v3(9.5, 2.16, 10.0), v3(0.7, 0.10, 0.7), darkSteel);
  lights.box(v3(9.5, 2.105, 10.0), v3(0.6, 0.02, 0.6), warmLight);

  final props = m.node('props');
  // Lockers along the left wall.
  for (var i = 0; i < 4; i++) {
    final z = 0.85 + i * 0.45;
    props.box(v3(0.78, 0.9, z), v3(0.5, 1.8, 0.43), paintedSteel);
    props.box(v3(1.035, 0.9, z), v3(0.01, 1.7, 0.36), concreteDark);
    props.box(v3(1.04, 1.2, z + 0.12), v3(0.02, 0.10, 0.03), darkSteel);
  }
  // Plate rack near the machine press.
  props.box(v3(12.2, 0.03, 1.15), v3(1.5, 0.06, 0.5), darkSteel);
  for (final x in [-0.68, 0.68]) {
    props.box(v3(12.2 + x, 0.45, 1.15), v3(0.06, 0.9, 0.06), darkSteel);
  }
  props.cylinder(
    v3(12.2, 0.86, 1.15),
    0.03,
    1.5,
    darkSteel,
    axis: v3(1, 0, 0),
    segments: 8,
  );
  for (var i = -3; i <= 3; i++) {
    props.cylinder(
      v3(12.2 + i * 0.16, 0.66, 1.15),
      0.21,
      0.04,
      ironPlate,
      axis: v3(1, 0, 0),
      segments: 12,
    );
  }
  // Crates in the far right corner.
  props.box(v3(14.85, 0.33, 10.85), v3(0.66, 0.66, 0.66), wood);
  props.box(v3(14.15, 0.26, 10.95), v3(0.52, 0.52, 0.52), wood);
  props.box(v3(14.85, 0.91, 10.85), v3(0.50, 0.50, 0.50), wood);
  for (final x in [14.85, 14.15]) {
    props.box(
      v3(x, x > 14.5 ? 0.33 : 0.26, x > 14.5 ? 11.185 : 11.215),
      v3(0.04, x > 14.5 ? 0.6 : 0.46, 0.01),
      concreteDark,
    );
  }
  // Chalk bucket and a flat bench in the recovery corner.
  props.cylinder(v3(6.0, 0.15, 11.0), 0.14, 0.30, paintedSteel, segments: 10);
  props.box(v3(5.9, 0.42, 9.2), v3(0.36, 0.08, 1.1), wornFabric);
  for (final z in [8.75, 9.65]) {
    props.box(v3(5.9, 0.19, z), v3(0.30, 0.38, 0.08), darkSteel);
  }
  return m;
}

void main() {
  final models = [
    player(),
    coach(),
    inclineBench(),
    dumbbells(),
    machinePress(),
    cableStation(),
    waterStation(),
    recoveryMat(),
    gymShell(),
  ];
  Directory('assets/models').createSync(recursive: true);
  for (final model in models) {
    final path = 'assets/models/${model.name}.glb';
    final bytes = model.write(path);
    stdout.writeln('$path  ${(bytes / 1024).toStringAsFixed(1)} KB');
  }
}
