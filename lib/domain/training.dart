import 'content.dart';
import 'player.dart';

class WorkoutValidationResult {
  const WorkoutValidationResult({required this.passedRules, required this.warnings, required this.errors});
  final List<String> passedRules, warnings, errors;
  bool get isValid => errors.isEmpty;
}

WorkoutValidationResult validateWorkout(WorkoutSelection selection,
    Map<String, Exercise> catalog, Set<String> discovered) {
  final ids = selection.exerciseIds;
  final exercises = ids.map((id) => catalog[id]).whereType<Exercise>().toList();
  final passed = <String>[];
  final warnings = <String>[];
  final errors = <String>[];
  void rule(bool condition, String id, String message) {
    (condition ? passed : errors).add(condition ? id : message);
  }
  rule(ids.length == 3, 'exactly_three', 'Select exactly three exercises for this chest-day session.');
  rule(ids.toSet().length == ids.length, 'unique', 'Choose three different exercises.');
  rule(ids.every(discovered.contains), 'discovered', 'Explore the gym and discover each exercise before selecting it.');
  rule(exercises.length == ids.length, 'known', 'One of these exercises is unavailable. Choose a discovered station.');
  rule(exercises.every((e) => e.primaryMuscles.contains('chest')), 'chest', 'Choose chest movements for this session.');
  rule(exercises.any((e) => e.movementRole == MovementRole.press),
      'contains_press', 'Add at least one chest pressing movement.');
  rule(exercises.any((e) => e.movementRole == MovementRole.isolation),
      'contains_isolation', 'Include a chest isolation movement so the session is not built entirely around pressing.');
  if (exercises.isNotEmpty && exercises.every((e) => e.movementRole == MovementRole.press)) {
    warnings.add('Your session is heavily press-focused. Try including a chest isolation movement so the session is not built entirely around the same movement role.');
  }
  if (exercises.isNotEmpty && exercises.every((e) => e.movementRole == MovementRole.isolation)) {
    warnings.add('Isolation complements pressing. Include a chest press to give the session both movement roles.');
  }
  return WorkoutValidationResult(passedRules: List.unmodifiable(passed),
      warnings: List.unmodifiable(warnings), errors: List.unmodifiable(errors));
}

enum RepGrade { clean, good, rough, miss }
enum TrainingGrade { excellent, good, rough, failed }

double timingWindowMultiplier(PlayerCondition condition) {
  final hydrationPenalty = condition.hydration < 25 ? 0.10 : condition.hydration < 50 ? 0.05 : 0.0;
  final fatiguePenalty = condition.fatigue >= 75 ? 0.10 : condition.fatigue >= 50 ? 0.05 : 0.0;
  return 1 - hydrationPenalty - fatiguePenalty;
}

RepGrade scoreRep(double position, PlayerCondition condition) {
  if (!position.isFinite) return RepGrade.miss;
  final distance = (position.clamp(0, 1) - .5).abs();
  final window = timingWindowMultiplier(condition);
  if (distance <= .14 * window) return RepGrade.clean;
  if (distance <= .24 * window) return RepGrade.good;
  if (distance <= .38 * window) return RepGrade.rough;
  return RepGrade.miss;
}

class TrainingResult {
  const TrainingResult({required this.exerciseId, required this.totalReps,
    required this.cleanReps, required this.grade, required this.fatigueAdded,
    required this.hydrationLost, required this.xpGranted});
  final String exerciseId;
  final int totalReps, cleanReps, fatigueAdded, hydrationLost, xpGranted;
  final TrainingGrade grade;
}

TrainingResult calculateTraining(Exercise exercise, PlayerCondition condition,
    List<RepGrade> reps) {
  if (reps.length != 5) throw ArgumentError('A working set requires exactly five reps.');
  final clean = reps.where((r) => r == RepGrade.clean).length;
  final grade = clean == 5 ? TrainingGrade.excellent : clean == 4 ? TrainingGrade.good
      : clean >= 2 ? TrainingGrade.rough : TrainingGrade.failed;
  final xpMultiplier = switch (grade) {
    TrainingGrade.excellent => 1.25, TrainingGrade.good => 1.0,
    TrainingGrade.rough => .75, TrainingGrade.failed => .5,
  };
  final gradeFatigue = switch (grade) {
    TrainingGrade.excellent || TrainingGrade.good => 1.0,
    TrainingGrade.rough => 1.1, TrainingGrade.failed => 1.2,
  };
  final stateFatigue = condition.fatigue >= 75 ? 1.2 : condition.fatigue >= 50 ? 1.1 : 1.0;
  return TrainingResult(exerciseId: exercise.id, totalReps: 5, cleanReps: clean,
    grade: grade, fatigueAdded: (exercise.fatigueCost * gradeFatigue * stateFatigue).round(),
    hydrationLost: exercise.hydrationCost, xpGranted: (exercise.xpReward * xpMultiplier).round());
}

class TrainingAttempt {
  TrainingAttempt({required this.exerciseId, required this.condition, required this.accessible});
  final String exerciseId;
  final PlayerCondition condition;
  final bool accessible;
  final List<RepGrade> _reps = [];
  List<RepGrade> get reps => List.unmodifiable(_reps);
  bool get completed => _reps.length == 5;
  RepGrade record(double position) {
    if (completed) throw StateError('Set already complete');
    final grade = accessible ? RepGrade.clean : scoreRep(position, condition);
    _reps.add(grade);
    return grade;
  }
}
