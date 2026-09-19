// Generated-asset manifest. Gameplay code refers to canonical keys; only this
// file knows where the files live (assets/models, produced by
// tool/assets/generate_models.dart and converted by the flutter_scene hook).

class ModelPlacement {
  const ModelPlacement(
    this.path, {
    this.dx = 0,
    this.dz = 0,
    this.rotationY = 0,
  });
  final String path;
  final double dx, dz, rotationY;
}

class SignDefinition {
  const SignDefinition(
    this.text, {
    required this.x,
    required this.y,
    required this.z,
    this.rotationY = 0,
    this.width = 3.2,
    this.height = 0.5,
    this.accent = false,
  });
  final String text;
  final double x, y, z, rotationY, width, height;
  final bool accent;
}

class AssetCatalog {
  static const models = 'assets/models';

  static const player = '$models/player_base.glb';
  static const coach = '$models/hypertrophy_coach.glb';
  static const gym = '$models/hypertrophy_gym.glb';
  static const inclineBench = '$models/incline_bench.glb';
  static const dumbbells = '$models/dumbbells.glb';
  static const machineChestPress = '$models/machine_chest_press.glb';
  static const cableStation = '$models/cable_station.glb';
  static const waterStation = '$models/water_station.glb';
  static const recoveryMat = '$models/recovery_mat.glb';

  /// Composite station models keyed by the `asset` field of an interactable.
  static const Map<String, List<ModelPlacement>> stations = {
    'coach': [ModelPlacement(coach)],
    'incline_press': [
      ModelPlacement(inclineBench),
      ModelPlacement(dumbbells, dx: 0.72, dz: 0.15),
    ],
    'machine_chest_press': [ModelPlacement(machineChestPress)],
    'cable_fly': [ModelPlacement(cableStation)],
    'water_station': [ModelPlacement(waterStation)],
    'recovery_mat': [ModelPlacement(recoveryMat)],
  };

  /// Diegetic wayfinding signage rendered as text quads at runtime.
  static const signs = [
    SignDefinition('HYPERTROPHY', x: 8.0, y: 1.75, z: 0.57, accent: true),
    SignDefinition(
      'PRESSING',
      x: 8.0,
      y: 2.45,
      z: 2.0,
      width: 2.4,
      height: 0.4,
    ),
    SignDefinition('CABLES', x: 13.3, y: 2.45, z: 5.0, width: 2.0, height: 0.4),
    SignDefinition(
      'RECOVERY',
      x: 9.5,
      y: 2.55,
      z: 8.6,
      width: 2.6,
      height: 0.4,
    ),
  ];
}
