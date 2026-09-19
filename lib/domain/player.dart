class PlayerCondition {
  PlayerCondition({int hydration = 80, int fatigue = 10})
    : hydration = hydration.clamp(0, 100),
      fatigue = fatigue.clamp(0, 100);
  final int hydration, fatigue;
  PlayerCondition change({int hydration = 0, int fatigue = 0}) =>
      PlayerCondition(
        hydration: this.hydration + hydration,
        fatigue: this.fatigue + fatigue,
      );
}

enum QuestState { locked, available, active, completed }

class QuestProgress {
  QuestProgress({
    required this.questId,
    this.state = QuestState.available,
    Map<String, int> objectiveProgress = const {},
    this.rewardClaimed = false,
    this.waterAfterCoach = false,
  }) : objectiveProgress = Map.unmodifiable(objectiveProgress);
  final String questId;
  final QuestState state;
  final Map<String, int> objectiveProgress;
  final bool rewardClaimed, waterAfterCoach;
  int count(String id) => objectiveProgress[id] ?? 0;
  bool done(String id) => count(id) > 0;
  QuestProgress copyWith({
    QuestState? state,
    Map<String, int>? objectiveProgress,
    bool? rewardClaimed,
    bool? waterAfterCoach,
  }) => QuestProgress(
    questId: questId,
    state: state ?? this.state,
    objectiveProgress: objectiveProgress ?? this.objectiveProgress,
    rewardClaimed: rewardClaimed ?? this.rewardClaimed,
    waterAfterCoach: waterAfterCoach ?? this.waterAfterCoach,
  );
}

int levelForXp(int xp) {
  const thresholds = [0, 100, 250, 450, 700];
  return thresholds.where((value) => xp >= value).length.clamp(1, 5);
}

class PlayerProfile {
  PlayerProfile({
    this.playerId = 'local_player',
    this.xp = 0,
    PlayerCondition? condition,
    Set<String> discoveredExerciseIds = const {},
    Set<String> unlockedCodexIds = const {},
    Set<String> unlockedKnowledgeIds = const {},
    Map<String, QuestProgress> questProgress = const {},
  }) : condition = condition ?? PlayerCondition(),
       discoveredExerciseIds = Set.unmodifiable(discoveredExerciseIds),
       unlockedCodexIds = Set.unmodifiable(unlockedCodexIds),
       unlockedKnowledgeIds = Set.unmodifiable(unlockedKnowledgeIds),
       questProgress = Map.unmodifiable(questProgress);
  final String playerId;
  final int xp;
  int get level => levelForXp(xp);
  final PlayerCondition condition;
  final Set<String> discoveredExerciseIds,
      unlockedCodexIds,
      unlockedKnowledgeIds;
  final Map<String, QuestProgress> questProgress;
  PlayerProfile copyWith({
    int? xp,
    PlayerCondition? condition,
    Set<String>? discoveredExerciseIds,
    Set<String>? unlockedCodexIds,
    Set<String>? unlockedKnowledgeIds,
    Map<String, QuestProgress>? questProgress,
  }) => PlayerProfile(
    playerId: playerId,
    xp: xp ?? this.xp,
    condition: condition ?? this.condition,
    discoveredExerciseIds: discoveredExerciseIds ?? this.discoveredExerciseIds,
    unlockedCodexIds: unlockedCodexIds ?? this.unlockedCodexIds,
    unlockedKnowledgeIds: unlockedKnowledgeIds ?? this.unlockedKnowledgeIds,
    questProgress: questProgress ?? this.questProgress,
  );
}

class GameSettings {
  const GameSettings({
    this.audioVolume = 1,
    this.reducedMotion = false,
    this.graphicsQuality = 'medium',
    this.controlHints = true,
    this.textScale = 1,
  });
  final double audioVolume, textScale;
  final bool reducedMotion, controlHints;
  final String graphicsQuality;
  GameSettings copyWith({
    double? audioVolume,
    bool? reducedMotion,
    String? graphicsQuality,
    bool? controlHints,
    double? textScale,
  }) => GameSettings(
    audioVolume: (audioVolume ?? this.audioVolume).clamp(0, 1),
    reducedMotion: reducedMotion ?? this.reducedMotion,
    graphicsQuality: graphicsQuality ?? this.graphicsQuality,
    controlHints: controlHints ?? this.controlHints,
    textScale: (textScale ?? this.textScale).clamp(1, 1.5),
  );
}

class WorkoutSelection {
  WorkoutSelection([List<String> exerciseIds = const []])
    : exerciseIds = List.unmodifiable(exerciseIds);
  final List<String> exerciseIds;
}

class SaveGame {
  const SaveGame({
    required this.player,
    required this.settings,
    required this.selection,
    this.schemaVersion = 1,
  });
  final int schemaVersion;
  final PlayerProfile player;
  final GameSettings settings;
  final WorkoutSelection selection;
}

abstract interface class SaveRepository {
  Future<SaveGame?> load();
  Future<void> save(SaveGame save);
  Future<void> clear();
}
