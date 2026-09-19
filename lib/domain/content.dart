// Static definitions. This layer deliberately has no Flutter dependency.
enum MovementRole {
  press('Press'),
  isolation('Isolation');

  const MovementRole(this.label);
  final String label;

  static MovementRole parse(Object? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }
    throw FormatException('Unknown movementRole: $value');
  }
}

/// Turns a snake_case content ID into a display label ("upper_chest" ->
/// "Upper Chest"). Display text only; IDs stay stable.
String humanize(String id) => id
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

String requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid $key');
  }
  return value;
}

String contentId(Map<String, dynamic> json) {
  final value = requiredText(json, 'id');
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    throw FormatException('Invalid content ID: $value');
  }
  return value;
}

List<String> stringList(Map<String, dynamic> json, String key) =>
    List<String>.unmodifiable((json[key] as List).cast<String>());

int nonNegative(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int || value < 0) {
    throw FormatException('$key must be a nonnegative integer');
  }
  return value;
}

class Exercise {
  Exercise.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      name = requiredText(json, 'name'),
      category = requiredText(json, 'category'),
      movementRole = MovementRole.parse(json['movementRole']),
      primaryMuscles = stringList(json, 'primaryMuscles'),
      secondaryMuscles = stringList(json, 'secondaryMuscles'),
      emphasis = stringList(json, 'emphasis'),
      equipment = stringList(json, 'equipment'),
      fatigueCost = nonNegative(json, 'fatigueCost'),
      hydrationCost = nonNegative(json, 'hydrationCost'),
      xpReward = nonNegative(json, 'xpReward'),
      techniqueDifficulty = nonNegative(json, 'techniqueDifficulty'),
      codexUnlock = json['codexUnlock'] as bool,
      summary = requiredText(json, 'summary'),
      techniqueNotes = stringList(json, 'techniqueNotes');

  final String id, name, category, summary;
  final MovementRole movementRole;
  final List<String> primaryMuscles, secondaryMuscles, emphasis, equipment;
  final List<String> techniqueNotes;
  final int fatigueCost, hydrationCost, xpReward, techniqueDifficulty;
  final bool codexUnlock;
}

enum ObjectiveType {
  npcInteraction('npc_interaction'),
  exerciseDiscovery('exercise_discovery'),
  exerciseInspection('exercise_inspection'),
  workoutValidation('workout_validation'),
  trainingCompletion('training_completion'),
  npcAfterTraining('npc_interaction_after_training'),
  recoveryAction('recovery_action');

  const ObjectiveType(this.id);
  final String id;

  static ObjectiveType parse(Object? value) {
    for (final type in values) {
      if (type.id == value) return type;
    }
    throw FormatException('Unknown objective type: $value');
  }
}

class QuestObjectiveDefinition {
  QuestObjectiveDefinition.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      label = requiredText(json, 'label'),
      type = ObjectiveType.parse(json['type']),
      targetCount = nonNegative(json, 'targetCount'),
      conditions = Map.unmodifiable(
        json['conditions'] as Map<String, dynamic>,
      ) {
    if (targetCount == 0) throw const FormatException('Zero objective target');
  }
  final String id, label;
  final ObjectiveType type;
  final int targetCount;
  final Map<String, dynamic> conditions;
}

class QuestDefinition {
  QuestDefinition.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      title = requiredText(json, 'title'),
      districtId = requiredText(json, 'districtId'),
      objectives = List.unmodifiable(
        (json['objectives'] as List).map(
          (e) => QuestObjectiveDefinition.fromJson(e as Map<String, dynamic>),
        ),
      ),
      rewardXp = nonNegative(json['reward'] as Map<String, dynamic>, 'xp'),
      knowledgeIds = stringList(
        json['reward'] as Map<String, dynamic>,
        'knowledgeIds',
      ) {
    if (objectives.isEmpty ||
        objectives.map((o) => o.id).toSet().length != objectives.length) {
      throw const FormatException(
        'Quest objectives must be nonempty and unique',
      );
    }
  }
  final String id, title, districtId;
  final List<QuestObjectiveDefinition> objectives;
  final int rewardXp;
  final List<String> knowledgeIds;
}

class WorldPoint {
  const WorldPoint(this.x, this.y, this.z);
  factory WorldPoint.fromJson(Map<String, dynamic> json) => WorldPoint(
    (json['x'] as num).toDouble(),
    (json['y'] as num? ?? 0).toDouble(),
    (json['z'] as num).toDouble(),
  );
  final double x, y, z;
}

class ColliderDefinition {
  ColliderDefinition.fromJson(Map<String, dynamic> json)
    : x = (json['x'] as num).toDouble(),
      z = (json['z'] as num).toDouble(),
      width = (json['width'] as num).toDouble(),
      depth = (json['depth'] as num).toDouble() {
    if (![x, z, width, depth].every((v) => v.isFinite) ||
        width <= 0 ||
        depth <= 0) {
      throw const FormatException('Invalid collider');
    }
  }
  final double x, z, width, depth;
}

class InteractableDefinition extends ColliderDefinition {
  InteractableDefinition.fromJson(super.json)
    : id = contentId(json),
      name = requiredText(json, 'name'),
      type = requiredText(json, 'type'),
      targetId = requiredText(json, 'targetId'),
      asset = requiredText(json, 'asset'),
      interactionRadius = (json['interactionRadius'] as num).toDouble(),
      trainingEnabled = json['trainingEnabled'] as bool,
      solid = json['solid'] as bool? ?? true,
      rotationY = (json['rotationY'] as num? ?? 0).toDouble(),
      super.fromJson() {
    if (![
          'npc',
          'exercise_station',
          'water_station',
          'recovery_mat',
        ].contains(type) ||
        !interactionRadius.isFinite ||
        interactionRadius <= 0) {
      throw const FormatException('Invalid interactable');
    }
  }
  final String id, name, type, targetId, asset;
  final double interactionRadius, rotationY;
  final bool trainingEnabled, solid;

  bool get isNpc => type == 'npc';
  bool get isExerciseStation => type == 'exercise_station';
  bool get isWaterStation => type == 'water_station';
  bool get isRecoveryMat => type == 'recovery_mat';
}

class DistrictDefinition {
  DistrictDefinition.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      name = requiredText(json, 'name'),
      sceneAsset = requiredText(json, 'sceneAsset'),
      spawn = WorldPoint.fromJson(json['spawn'] as Map<String, dynamic>),
      stationIds = stringList(json, 'stationIds'),
      npcIds = stringList(json, 'npcIds'),
      bounds = Map<String, double>.unmodifiable(
        (json['bounds'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      interactables = List.unmodifiable(
        (json['interactables'] as List).map(
          (e) => InteractableDefinition.fromJson(e as Map<String, dynamic>),
        ),
      ),
      colliders = List.unmodifiable(
        (json['colliders'] as List).map(
          (e) => ColliderDefinition.fromJson(e as Map<String, dynamic>),
        ),
      ),
      previews = List.unmodifiable(
        (json['previews'] as List).map(
          (e) => Map<String, String>.unmodifiable(
            (e as Map).cast<String, String>(),
          ),
        ),
      ),
      leagues = stringList(json, 'leagues') {
    final ids = interactables.map((e) => e.id).toSet();
    if (ids.length != interactables.length ||
        !stationIds.every(ids.contains) ||
        !npcIds.every(ids.contains)) {
      throw const FormatException(
        'District has duplicate or missing world references',
      );
    }
    if (bounds['minX']! >= bounds['maxX']! ||
        bounds['minZ']! >= bounds['maxZ']! ||
        spawn.x < bounds['minX']! ||
        spawn.x > bounds['maxX']! ||
        spawn.z < bounds['minZ']! ||
        spawn.z > bounds['maxZ']!) {
      throw const FormatException('Invalid bounds or spawn');
    }
  }
  final String id, name, sceneAsset;
  final WorldPoint spawn;
  final List<String> stationIds, npcIds, leagues;
  final Map<String, double> bounds;
  final List<InteractableDefinition> interactables;
  final List<ColliderDefinition> colliders;
  final List<Map<String, String>> previews;
}

class NPCDefinition {
  NPCDefinition.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      name = requiredText(json, 'name'),
      role = requiredText(json, 'role'),
      dialogueIds = stringList(json, 'dialogueIds'),
      dialogue = Map.unmodifiable(
        (json['dialogue'] as Map).cast<String, String>(),
      ) {
    if (!dialogueIds.every(dialogue.containsKey)) {
      throw const FormatException('Missing dialogue');
    }
  }
  final String id, name, role;
  final List<String> dialogueIds;
  final Map<String, String> dialogue;
}

class KnowledgeUnlock {
  KnowledgeUnlock.fromJson(Map<String, dynamic> json)
    : id = contentId(json),
      name = requiredText(json, 'name'),
      category = requiredText(json, 'category'),
      summary = requiredText(json, 'summary');
  final String id, name, category, summary;
}

class GameContent {
  GameContent({
    required List<Exercise> exercises,
    required this.quest,
    required this.district,
    required this.coach,
    required this.knowledge,
  }) : exercises = Map.unmodifiable({for (final e in exercises) e.id: e}) {
    if (this.exercises.length != exercises.length || exercises.isEmpty) {
      throw const FormatException('Exercise IDs must be unique');
    }
    if (quest.districtId != district.id ||
        !district.npcIds.contains(coach.id) ||
        !quest.knowledgeIds.every((id) => id == knowledge.id)) {
      throw const FormatException('Broken content references');
    }
    for (final station in district.interactables) {
      if (station.type == 'exercise_station' &&
          !this.exercises.containsKey(station.targetId)) {
        throw FormatException('Missing exercise: ${station.targetId}');
      }
      if (station.type == 'npc' && station.targetId != coach.id) {
        throw FormatException('Missing NPC: ${station.targetId}');
      }
    }
  }
  final Map<String, Exercise> exercises;
  final QuestDefinition quest;
  final DistrictDefinition district;
  final NPCDefinition coach;
  final KnowledgeUnlock knowledge;
}
