import 'training.dart';

enum GameEventType {
  gameStarted, newGameCreated, saveLoaded, npcInteracted,
  exerciseDiscovered, exerciseInspected, exerciseStarted, exerciseCompleted,
  workoutSelectionChanged, workoutValidated, hydrationChanged, fatigueChanged,
  waterConsumed, recoveryPerformed, xpGranted, playerLeveledUp,
  questStarted, questObjectiveCompleted, questCompleted, codexUnlocked,
  knowledgeUnlocked, saveRequested, entitlementUpdated, settingsChanged,
}

class GameEvent {
  const GameEvent(this.type, {this.id, this.value, this.result});
  final GameEventType type;
  final String? id;
  final int? value;
  final TrainingResult? result;
}
