import 'content.dart';
import 'events.dart';
import 'player.dart';

/// Pure event evaluation. World location and rendering never reach this class.
QuestProgress evaluateQuest(GameContent content, PlayerProfile player,
    QuestProgress progress, GameEvent event) {
  if (progress.state != QuestState.active) return progress;
  final counts = Map<String, int>.from(progress.objectiveProgress);
  final exercise = content.exercises[event.id];
  var water = progress.waterAfterCoach;
  if (event.type == GameEventType.waterConsumed && progress.done('return_to_coach')) water = true;
  for (final objective in content.quest.objectives) {
    if ((counts[objective.id] ?? 0) >= objective.targetCount) continue;
    final conditions = objective.conditions;
    bool matchesExercise() => exercise != null &&
      (conditions['category'] == null || exercise.category == conditions['category']) &&
      (conditions['primaryMuscle'] == null || exercise.primaryMuscles.contains(conditions['primaryMuscle'])) &&
      (conditions['movementRole'] == null || exercise.movementRole.name == conditions['movementRole']);
    final matches = switch (objective.type) {
      ObjectiveType.npcInteraction => event.type == GameEventType.npcInteracted && event.id == conditions['npcId'],
      ObjectiveType.exerciseDiscovery => event.type == GameEventType.exerciseDiscovered && matchesExercise(),
      ObjectiveType.exerciseInspection => event.type == GameEventType.exerciseInspected && matchesExercise(),
      ObjectiveType.workoutValidation => event.type == GameEventType.workoutValidated && event.id == conditions['validator'],
      ObjectiveType.trainingCompletion => event.type == GameEventType.exerciseCompleted &&
          matchesExercise() && progress.done('build_three_exercise_session'),
      ObjectiveType.npcAfterTraining => event.type == GameEventType.npcInteracted &&
          event.id == conditions['npcId'] && progress.done('complete_working_set'),
      ObjectiveType.recoveryAction => event.type == GameEventType.recoveryPerformed &&
          event.id == conditions['stationType'] && progress.done('return_to_coach') && water,
    };
    if (matches) {
      if (objective.type == ObjectiveType.exerciseDiscovery) {
        counts[objective.id] = player.discoveredExerciseIds.where((id) {
          final e = content.exercises[id];
          return e != null && e.category == conditions['category'] && e.primaryMuscles.contains(conditions['primaryMuscle']);
        }).length.clamp(0, objective.targetCount);
      } else {
        counts[objective.id] = ((counts[objective.id] ?? 0) + 1).clamp(0, objective.targetCount);
      }
    }
  }
  return progress.copyWith(objectiveProgress: counts, waterAfterCoach: water);
}
