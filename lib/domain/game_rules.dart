import 'content.dart';
import 'events.dart';
import 'player.dart';
import 'quest_system.dart';
import 'training.dart';

/// Deterministic gameplay aggregate. Use cases call it; widgets never mutate it.
class GameRules {
  GameRules(this.content, {SaveGame? save})
      : _player = save?.player ?? PlayerProfile(questProgress: {
          content.quest.id: QuestProgress(questId: content.quest.id),
        }),
        _settings = save?.settings ?? const GameSettings(),
        _selection = save?.selection ?? WorkoutSelection();

  final GameContent content;
  PlayerProfile _player;
  GameSettings _settings;
  WorkoutSelection _selection;
  final List<GameEvent> _events = [];
  TrainingAttempt? _attempt;
  TrainingResult? lastTrainingResult;
  PlayerProfile get player => _player;
  GameSettings get settings => _settings;
  WorkoutSelection get selection => _selection;
  TrainingAttempt? get attempt => _attempt;
  QuestProgress get quest => _player.questProgress[content.quest.id]!;
  SaveGame get snapshot => SaveGame(player: player, settings: settings, selection: selection);
  List<GameEvent> drainEvents() {
    final result = List<GameEvent>.unmodifiable(_events);
    _events.clear();
    return result;
  }

  void _setQuest(QuestProgress progress) {
    _player = _player.copyWith(questProgress: {..._player.questProgress, progress.questId: progress});
  }

  void _emit(GameEvent event) {
    _events.add(event);
    final before = quest;
    final after = evaluateQuest(content, player, before, event);
    _setQuest(after);
    for (final objective in content.quest.objectives) {
      if (before.count(objective.id) < objective.targetCount && after.count(objective.id) >= objective.targetCount) {
        _events.add(GameEvent(GameEventType.questObjectiveCompleted, id: objective.id));
      }
    }
  }

  void _grantXp(int amount) {
    final oldLevel = player.level;
    _player = player.copyWith(xp: player.xp + amount);
    _emit(GameEvent(GameEventType.xpGranted, value: amount));
    if (player.level > oldLevel) _emit(GameEvent(GameEventType.playerLeveledUp, value: player.level));
  }

  void _finishAction() {
    final complete = content.quest.objectives.every((o) => quest.count(o.id) >= o.targetCount);
    if (quest.state == QuestState.active && complete && !quest.rewardClaimed) {
      _setQuest(quest.copyWith(state: QuestState.completed, rewardClaimed: true));
      _grantXp(content.quest.rewardXp);
      for (final id in content.quest.knowledgeIds) {
        if (!player.unlockedKnowledgeIds.contains(id)) {
          _player = player.copyWith(unlockedKnowledgeIds: {...player.unlockedKnowledgeIds, id});
          _emit(GameEvent(GameEventType.knowledgeUnlocked, id: id));
        }
      }
      _emit(GameEvent(GameEventType.questCompleted, id: content.quest.id));
    }
    _events.add(const GameEvent(GameEventType.saveRequested));
  }

  void newGame() {
    _player = PlayerProfile(questProgress: {content.quest.id: QuestProgress(questId: content.quest.id)});
    _selection = WorkoutSelection();
    _attempt = null;
    lastTrainingResult = null;
    _emit(const GameEvent(GameEventType.newGameCreated));
    _finishAction();
  }

  String interactWithNpc(String id) {
    if (id != content.coach.id) throw const FormatException('Coach not found.');
    final wasAvailable = quest.state == QuestState.available;
    final line = quest.state == QuestState.completed ? 'coach_completion'
        : wasAvailable ? 'coach_intro'
        : quest.done('complete_working_set') ? 'coach_after_training' : 'coach_after_discovery';
    if (wasAvailable) {
      _setQuest(quest.copyWith(state: QuestState.active));
      _emit(GameEvent(GameEventType.questStarted, id: content.quest.id));
    }
    _emit(GameEvent(GameEventType.npcInteracted, id: id));
    // Exploration before meeting the coach still counts; it never pays twice.
    if (wasAvailable) {
      for (final exerciseId in player.discoveredExerciseIds) {
        _emit(GameEvent(GameEventType.exerciseDiscovered, id: exerciseId));
        _emit(GameEvent(GameEventType.exerciseInspected, id: exerciseId));
      }
    }
    _finishAction();
    return content.coach.dialogue[line]!;
  }

  Exercise inspectExercise(String id) {
    final exercise = content.exercises[id];
    if (exercise == null) throw const FormatException('Exercise data unavailable.');
    if (!player.discoveredExerciseIds.contains(id)) {
      _player = player.copyWith(discoveredExerciseIds: {...player.discoveredExerciseIds, id});
      _emit(GameEvent(GameEventType.exerciseDiscovered, id: id));
      final codexId = 'codex:$id';
      if (exercise.codexUnlock && !player.unlockedCodexIds.contains(codexId)) {
        _player = player.copyWith(unlockedCodexIds: {...player.unlockedCodexIds, codexId});
        _emit(GameEvent(GameEventType.codexUnlocked, id: codexId));
      }
      _grantXp(5);
    }
    _emit(GameEvent(GameEventType.exerciseInspected, id: id));
    _finishAction();
    return exercise;
  }

  bool toggleExercise(String id) {
    if (_attempt != null || !player.discoveredExerciseIds.contains(id) || !content.exercises.containsKey(id)) return false;
    final ids = [...selection.exerciseIds];
    if (ids.contains(id)) { ids.remove(id); }
    else if (ids.length < 3) { ids.add(id); }
    else { return false; }
    _selection = WorkoutSelection(ids);
    _emit(GameEvent(GameEventType.workoutSelectionChanged, id: id));
    _finishAction();
    return true;
  }

  WorkoutValidationResult get workoutValidation => validateWorkout(selection, content.exercises, player.discoveredExerciseIds);

  WorkoutValidationResult validateSession() {
    final result = workoutValidation;
    if (result.isValid && quest.state != QuestState.available) {
      _emit(const GameEvent(GameEventType.workoutValidated, id: 'chest_day_mvp'));
      _finishAction();
    }
    return result;
  }

  bool canTrain(String id) => _attempt == null && player.discoveredExerciseIds.contains(id) &&
      selection.exerciseIds.contains(id) && workoutValidation.isValid && quest.done('build_three_exercise_session');

  void startExercise(String id) {
    if (!canTrain(id)) throw StateError('Build and validate your session before training at a selected station.');
    _attempt = TrainingAttempt(exerciseId: id, condition: player.condition, accessible: settings.reducedMotion);
    lastTrainingResult = null;
    _emit(GameEvent(GameEventType.exerciseStarted, id: id));
  }

  RepGrade performRep(double position) {
    final active = _attempt;
    if (active == null) throw StateError('No active set.');
    final rep = active.record(position);
    if (active.completed) {
      final result = calculateTraining(content.exercises[active.exerciseId]!, active.condition, active.reps);
      _attempt = null; // Consume the attempt before awarding anything.
      lastTrainingResult = result;
      _player = player.copyWith(condition: player.condition.change(hydration: -result.hydrationLost));
      _emit(GameEvent(GameEventType.hydrationChanged, value: player.condition.hydration));
      _player = player.copyWith(condition: player.condition.change(fatigue: result.fatigueAdded));
      _emit(GameEvent(GameEventType.fatigueChanged, value: player.condition.fatigue));
      _grantXp(result.xpGranted);
      _emit(GameEvent(GameEventType.exerciseCompleted, id: result.exerciseId, result: result));
      _finishAction();
    }
    return rep;
  }

  void cancelTraining() { _attempt = null; }

  int drinkWater() {
    final before = player.condition.hydration;
    _player = player.copyWith(condition: player.condition.change(hydration: 15));
    _emit(const GameEvent(GameEventType.waterConsumed, id: 'water_station'));
    _emit(GameEvent(GameEventType.hydrationChanged, value: player.condition.hydration));
    _finishAction();
    return player.condition.hydration - before;
  }

  int recover() {
    final before = player.condition.fatigue;
    _player = player.copyWith(condition: player.condition.change(fatigue: -15));
    _emit(const GameEvent(GameEventType.recoveryPerformed, id: 'recovery_mat'));
    _emit(GameEvent(GameEventType.fatigueChanged, value: player.condition.fatigue));
    _finishAction();
    return before - player.condition.fatigue;
  }

  void updateSettings(GameSettings value) {
    _settings = value;
    _emit(const GameEvent(GameEventType.settingsChanged));
    _finishAction();
  }
}
