// Domain events. Pure Dart: systems communicate through these instead of
// reaching into each other. Payloads carry only what downstream needs.
import 'player.dart';
import 'rules.dart';

sealed class GameEvent {
  const GameEvent();
}

class NewGameCreated extends GameEvent {
  const NewGameCreated();
}

class SaveLoaded extends GameEvent {
  const SaveLoaded();
}

class NPCInteracted extends GameEvent {
  const NPCInteracted(this.npcId, this.dialogueId);
  final String npcId, dialogueId;
}

class ExerciseDiscovered extends GameEvent {
  const ExerciseDiscovered(this.exerciseId);
  final String exerciseId;
}

class ExerciseInspected extends GameEvent {
  const ExerciseInspected(this.exerciseId);
  final String exerciseId;
}

class ExerciseStarted extends GameEvent {
  const ExerciseStarted(this.exerciseId);
  final String exerciseId;
}

class ExerciseCompleted extends GameEvent {
  const ExerciseCompleted(this.result);
  final TrainingResult result;
  String get exerciseId => result.exerciseId;
}

class WorkoutSelectionChanged extends GameEvent {
  const WorkoutSelectionChanged(this.selection);
  final WorkoutSelection selection;
}

class WorkoutValidated extends GameEvent {
  const WorkoutValidated(this.result);
  final WorkoutValidationResult result;
}

class HydrationChanged extends GameEvent {
  const HydrationChanged(this.from, this.to);
  final int from, to;
  int get delta => to - from;
}

class FatigueChanged extends GameEvent {
  const FatigueChanged(this.from, this.to);
  final int from, to;
  int get delta => to - from;
}

class WaterConsumed extends GameEvent {
  const WaterConsumed();
}

class RecoveryPerformed extends GameEvent {
  const RecoveryPerformed(this.stationType);
  final String stationType;
}

class XPGranted extends GameEvent {
  const XPGranted(this.amount, this.source);
  final int amount;
  final String source;
}

class PlayerLeveledUp extends GameEvent {
  const PlayerLeveledUp(this.level);
  final int level;
}

class QuestStarted extends GameEvent {
  const QuestStarted(this.questId);
  final String questId;
}

class QuestObjectiveCompleted extends GameEvent {
  const QuestObjectiveCompleted(this.questId, this.objectiveId, this.label);
  final String questId, objectiveId, label;
}

class QuestCompleted extends GameEvent {
  const QuestCompleted(this.questId);
  final String questId;
}

class CodexUnlocked extends GameEvent {
  const CodexUnlocked(this.codexId);
  final String codexId;
}

class KnowledgeUnlocked extends GameEvent {
  const KnowledgeUnlocked(this.knowledgeId);
  final String knowledgeId;
}

class SaveRequested extends GameEvent {
  const SaveRequested();
}

class SettingsChanged extends GameEvent {
  const SettingsChanged(this.settings);
  final GameSettings settings;
}

class EntitlementUpdated extends GameEvent {
  const EntitlementUpdated(this.premium);
  final bool premium;
}
