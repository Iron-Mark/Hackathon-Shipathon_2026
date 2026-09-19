// The chest-day simulation. Pure Dart: owns a SaveGame and the static
// content, applies use cases, mutates state deterministically and returns the
// domain events that describe what happened (last event is SaveRequested
// whenever meaningful state changed).
import 'content.dart';
import 'events.dart';
import 'player.dart';
import 'rules.dart';

class GameEngine {
  GameEngine(this.content, this.state) : _quest = QuestEngine(content.quest);

  final GameContent content;
  SaveGame state;
  final QuestEngine _quest;

  PlayerProfile get player => state.player;
  QuestDefinition get quest => content.quest;

  QuestProgress get questProgress =>
      player.questProgress[quest.id] ?? QuestProgress(questId: quest.id);

  QuestObjectiveDefinition? get currentObjective =>
      _quest.currentObjective(questProgress);

  bool objectiveDone(String objectiveId) {
    final o = quest.objectives.where((o) => o.id == objectiveId).firstOrNull;
    return o != null && questProgress.count(o.id) >= o.targetCount;
  }

  bool get sessionBuilt => quest.objectives
      .where((o) => o.type == ObjectiveType.workoutValidation)
      .every((o) => questProgress.count(o.id) >= o.targetCount);

  bool get trainingDone => quest.objectives
      .where((o) => o.type == ObjectiveType.trainingCompletion)
      .every((o) => questProgress.count(o.id) >= o.targetCount);

  bool get returnedToCoach => quest.objectives
      .where((o) => o.type == ObjectiveType.npcAfterTraining)
      .every((o) => questProgress.count(o.id) >= o.targetCount);

  bool isCodexUnlocked(String exerciseId) =>
      player.unlockedCodexIds.contains(DiscoveryRules.codexId(exerciseId));

  bool get knowledgeUnlocked =>
      player.unlockedKnowledgeIds.contains(content.knowledge.id);

  // ---------------------------------------------------------------------
  // Use cases
  // ---------------------------------------------------------------------

  /// Dialogue the coach speaks for the current quest state (section 53).
  String coachDialogueId() {
    final p = questProgress;
    if (p.isCompleted) return 'coach_completion';
    if (p.state == QuestState.available) return 'coach_intro';
    if (trainingDone && !returnedToCoach) return 'coach_after_training';
    return 'coach_after_discovery';
  }

  List<GameEvent> interactWithNpc(String npcId) {
    if (npcId != content.coach.id) return const [];
    final dialogueId = coachDialogueId();
    final events = <GameEvent>[NPCInteracted(npcId, dialogueId)];
    _applyQuest(QuestSignal.npc(npcId), events);
    events.add(const SaveRequested());
    return events;
  }

  List<GameEvent> inspectExercise(String exerciseId) {
    final exercise = content.exercises[exerciseId];
    if (exercise == null) return const [];
    final events = <GameEvent>[];
    var p = player;
    if (!p.hasDiscovered(exerciseId)) {
      p = p.copyWith(
        discoveredExerciseIds: {...p.discoveredExerciseIds, exerciseId},
      );
      state = state.copyWith(player: p);
      events.add(ExerciseDiscovered(exerciseId));
      if (exercise.codexUnlock) {
        final codexId = DiscoveryRules.codexId(exerciseId);
        if (!p.unlockedCodexIds.contains(codexId)) {
          p = p.copyWith(unlockedCodexIds: {...p.unlockedCodexIds, codexId});
          state = state.copyWith(player: p);
          events.add(CodexUnlocked(codexId));
        }
      }
      _grantXp(DiscoveryRules.discoveryXp, 'discovery', events);
      _applyQuest(QuestSignal.discovered(exercise), events);
    }
    events.add(ExerciseInspected(exerciseId));
    _applyQuest(QuestSignal.inspected(exercise), events);
    events.add(const SaveRequested());
    return events;
  }

  List<GameEvent> toggleWorkoutExercise(String exerciseId) {
    if (!content.exercises.containsKey(exerciseId)) return const [];
    final next = state.selection.toggle(exerciseId);
    if (identical(next, state.selection)) return const [];
    state = state.copyWith(selection: next);
    return [WorkoutSelectionChanged(next)];
  }

  WorkoutValidationResult previewWorkout() => WorkoutValidator.validate(
    state.selection,
    content.exercises,
    player.discoveredExerciseIds,
  );

  (WorkoutValidationResult, List<GameEvent>) validateWorkout() {
    final result = previewWorkout();
    final events = <GameEvent>[WorkoutValidated(result)];
    if (result.isValid) {
      _applyQuest(const QuestSignal.workout(true), events);
      events.add(const SaveRequested());
    }
    return (result, events);
  }

  List<GameEvent> startTraining(String exerciseId) {
    if (!content.exercises.containsKey(exerciseId)) return const [];
    return [ExerciseStarted(exerciseId)];
  }

  /// Section 56 order: result, hydration, fatigue, XP, ExerciseCompleted,
  /// quest evaluation, save.
  List<GameEvent> completeTraining(
    String exerciseId,
    int cleanReps, {
    int totalReps = TrainingRules.repsPerSet,
  }) {
    final exercise = content.exercises[exerciseId];
    if (exercise == null) return const [];
    final result = TrainingRules.performSet(
      exercise: exercise,
      condition: player.condition,
      cleanReps: cleanReps,
      totalReps: totalReps,
    );
    final events = <GameEvent>[];
    _changeCondition(
      hydration: -result.hydrationLost,
      fatigue: result.fatigueAdded,
      events: events,
    );
    _grantXp(result.xpGranted, 'training', events);
    events.add(ExerciseCompleted(result));
    _applyQuest(QuestSignal.trained(exercise), events);
    events.add(const SaveRequested());
    return events;
  }

  List<GameEvent> drinkWater() {
    final events = <GameEvent>[const WaterConsumed()];
    _changeCondition(hydration: RecoveryRules.waterHydration, events: events);
    events.add(const SaveRequested());
    return events;
  }

  List<GameEvent> useRecoveryMat() {
    final events = <GameEvent>[const RecoveryPerformed('recovery_mat')];
    _changeCondition(fatigue: -RecoveryRules.matFatigueRelief, events: events);
    _applyQuest(const QuestSignal.recovered('recovery_mat'), events);
    events.add(const SaveRequested());
    return events;
  }

  List<GameEvent> updateSettings(GameSettings settings) {
    state = state.copyWith(settings: settings);
    return [SettingsChanged(settings), const SaveRequested()];
  }

  // ---------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------

  void _changeCondition({
    int hydration = 0,
    int fatigue = 0,
    required List<GameEvent> events,
  }) {
    final before = player.condition;
    final after = before.change(hydration: hydration, fatigue: fatigue);
    if (after == before) return;
    state = state.copyWith(player: player.copyWith(condition: after));
    if (after.hydration != before.hydration) {
      events.add(HydrationChanged(before.hydration, after.hydration));
    }
    if (after.fatigue != before.fatigue) {
      events.add(FatigueChanged(before.fatigue, after.fatigue));
    }
  }

  void _grantXp(int amount, String source, List<GameEvent> events) {
    if (amount <= 0) return;
    final before = player.level;
    state = state.copyWith(player: player.copyWith(xp: player.xp + amount));
    events.add(XPGranted(amount, source));
    if (player.level > before) events.add(PlayerLeveledUp(player.level));
  }

  void _applyQuest(QuestSignal signal, List<GameEvent> events) {
    final before = questProgress;
    final retroactive = <QuestSignal>[];
    if (before.state == QuestState.available) {
      for (final id in player.discoveredExerciseIds) {
        final e = content.exercises[id];
        if (e == null) continue;
        retroactive
          ..add(QuestSignal.discovered(e))
          ..add(QuestSignal.inspected(e));
      }
    }
    final update = _quest.apply(before, signal, retroactive: retroactive);
    if (!update.changed) return;
    state = state.copyWith(
      player: player.copyWith(
        questProgress: {...player.questProgress, quest.id: update.progress},
      ),
    );
    if (update.started) events.add(QuestStarted(quest.id));
    for (final o in update.completedObjectives) {
      events.add(QuestObjectiveCompleted(quest.id, o.id, o.label));
    }
    if (update.completed) {
      events.add(QuestCompleted(quest.id));
      _claimReward(events);
    }
  }

  void _claimReward(List<GameEvent> events) {
    final p = questProgress;
    if (p.rewardClaimed) return;
    state = state.copyWith(
      player: player.copyWith(
        questProgress: {
          ...player.questProgress,
          quest.id: p.copyWith(rewardClaimed: true),
        },
      ),
    );
    _grantXp(quest.rewardXp, 'quest', events);
    for (final id in quest.knowledgeIds) {
      if (player.unlockedKnowledgeIds.contains(id)) continue;
      state = state.copyWith(
        player: player.copyWith(
          unlockedKnowledgeIds: {...player.unlockedKnowledgeIds, id},
        ),
      );
      events.add(KnowledgeUnlocked(id));
    }
  }
}
