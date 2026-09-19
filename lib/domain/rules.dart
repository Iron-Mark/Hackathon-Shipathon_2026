// Gameplay rules from 04_IRON_ASCENT_Game_Systems_and_Data.md.
// Pure Dart. No Flutter, renderer, storage or platform imports.
import 'dart:math' as math;

import 'content.dart';
import 'player.dart';

// ---------------------------------------------------------------------------
// Workout validation (sections 19–23)
// ---------------------------------------------------------------------------

class WorkoutValidationResult {
  const WorkoutValidationResult({
    required this.isValid,
    this.passedRules = const [],
    this.warnings = const [],
    this.errors = const [],
  });
  final bool isValid;
  final List<String> passedRules, warnings, errors;

  /// One educational sentence describing what would improve the session.
  String get feedback => [...warnings, ...errors].join('\n\n');
}

class WorkoutValidator {
  static const exactlyThree =
      'Select exactly three exercises for this chest-day session.';
  static const pressRequired = 'Add at least one chest pressing movement.';
  static const isolationRequired =
      'Include a chest isolation movement so the session is not built '
      'entirely around pressing.';
  static const noDuplicates = 'Choose three different exercises.';
  static const discoveredOnly =
      'Inspect a station in the gym before adding its exercise to a session.';
  static const pressHeavy = 'Your session is heavily press-focused.';
  static const isolationHeavy =
      'Your session is built entirely around isolation work.';
  static const sameRoleHint =
      'Try including a chest isolation movement so the session is not built '
      'entirely around the same movement role.';
  static const sameRoleHintIsolation =
      'Try including a chest pressing movement so the session is not built '
      'entirely around the same movement role.';

  static WorkoutValidationResult validate(
    WorkoutSelection selection,
    Map<String, Exercise> exercises,
    Set<String> discoveredIds,
  ) {
    final ids = selection.exerciseIds;
    final passed = <String>[], warnings = <String>[], errors = <String>[];

    if (ids.length == 3) {
      passed.add('exactly_three');
    } else {
      errors.add(exactlyThree);
    }
    if (ids.toSet().length == ids.length) {
      passed.add('no_duplicates');
    } else {
      errors.add(noDuplicates);
    }
    final undiscovered = ids.where((id) => !discoveredIds.contains(id));
    if (undiscovered.isEmpty) {
      passed.add('all_discovered');
    } else {
      errors.add(discoveredOnly);
    }
    final known = ids.map((id) => exercises[id]).nonNulls.toList();
    if (known.length != ids.length) errors.add('Exercise not found.');

    final roles = known.map((e) => e.movementRole).toSet();
    final hasPress = roles.contains(MovementRole.press);
    final hasIsolation = roles.contains(MovementRole.isolation);
    if (hasPress) {
      passed.add('contains_press');
    } else {
      errors.add(pressRequired);
    }
    if (hasIsolation) {
      passed.add('contains_isolation');
    } else {
      errors.add(isolationRequired);
    }
    if (known.length > 1 && roles.length == 1) {
      if (hasPress) {
        warnings.addAll([pressHeavy, sameRoleHint]);
      } else {
        warnings.addAll([isolationHeavy, sameRoleHintIsolation]);
      }
    }
    return WorkoutValidationResult(
      isValid: errors.isEmpty,
      passedRules: passed,
      warnings: warnings,
      errors: errors,
    );
  }
}

// ---------------------------------------------------------------------------
// Training (sections 24–33)
// ---------------------------------------------------------------------------

enum TrainingGrade {
  excellent(1.25, 1.00, 'EXCELLENT'),
  good(1.00, 1.00, 'GOOD'),
  rough(0.75, 1.10, 'ROUGH'),
  failed(0.50, 1.20, 'FAILED');

  const TrainingGrade(this.xpMultiplier, this.fatigueMultiplier, this.label);
  final double xpMultiplier, fatigueMultiplier;
  final String label;
}

class TrainingResult {
  const TrainingResult({
    required this.exerciseId,
    required this.totalReps,
    required this.cleanReps,
    required this.grade,
    required this.fatigueAdded,
    required this.hydrationLost,
    required this.xpGranted,
  });
  final String exerciseId;
  final int totalReps, cleanReps, fatigueAdded, hydrationLost, xpGranted;
  final TrainingGrade grade;
}

class TrainingRules {
  static const repsPerSet = 5;

  /// Section 26 mapping for a five-rep set, scaled for other set sizes.
  static TrainingGrade gradeFor(int cleanReps, int totalReps) {
    if (totalReps <= 0) return TrainingGrade.failed;
    final ratio = cleanReps / totalReps;
    if (ratio >= 1.0) return TrainingGrade.excellent;
    if (ratio >= 0.8) return TrainingGrade.good;
    if (ratio >= 0.4) return TrainingGrade.rough;
    return TrainingGrade.failed;
  }

  /// Section 28 current-fatigue modifier.
  static double fatigueStateMultiplier(int fatigue) {
    if (fatigue >= 75) return 1.20;
    if (fatigue >= 50) return 1.10;
    return 1.00;
  }

  /// Section 30: small timing-window penalties from condition. Returns the
  /// scale to apply to the control zone width (1.0 = no penalty).
  static double timingWindowScale(PlayerCondition condition) {
    var scale = 1.0;
    if (condition.hydration < 25) {
      scale -= 0.10;
    } else if (condition.hydration < 50) {
      scale -= 0.05;
    }
    if (condition.fatigue >= 75) {
      scale -= 0.10;
    } else if (condition.fatigue >= 50) {
      scale -= 0.05;
    }
    return scale;
  }

  static TrainingResult performSet({
    required Exercise exercise,
    required PlayerCondition condition,
    required int cleanReps,
    int totalReps = repsPerSet,
  }) {
    final clean = cleanReps.clamp(0, totalReps);
    final grade = gradeFor(clean, totalReps);
    final fatigueAdded =
        (exercise.fatigueCost *
                grade.fatigueMultiplier *
                fatigueStateMultiplier(condition.fatigue))
            .round();
    return TrainingResult(
      exerciseId: exercise.id,
      totalReps: totalReps,
      cleanReps: clean,
      grade: grade,
      fatigueAdded: fatigueAdded,
      hydrationLost: exercise.hydrationCost,
      xpGranted: (exercise.xpReward * grade.xpMultiplier).round(),
    );
  }
}

// ---------------------------------------------------------------------------
// Recovery and discovery constants (sections 15, 35, 36)
// ---------------------------------------------------------------------------

class RecoveryRules {
  static const waterHydration = 15;
  static const matFatigueRelief = 15;
}

class DiscoveryRules {
  static const discoveryXp = 5;
  static String codexId(String exerciseId) => 'codex:$exerciseId';
}

// ---------------------------------------------------------------------------
// Quest engine (sections 37–43)
// ---------------------------------------------------------------------------

enum QuestSignalKind { npc, discovered, inspected, workout, trained, recovered }

/// A domain-level description of something that happened, used to match
/// quest objectives without depending on the event classes.
class QuestSignal {
  const QuestSignal._(
    this.kind, {
    this.npcId,
    this.exercise,
    this.workoutValid = false,
    this.stationType,
  });
  const QuestSignal.npc(String npcId)
    : this._(QuestSignalKind.npc, npcId: npcId);
  const QuestSignal.discovered(Exercise exercise)
    : this._(QuestSignalKind.discovered, exercise: exercise);
  const QuestSignal.inspected(Exercise exercise)
    : this._(QuestSignalKind.inspected, exercise: exercise);
  const QuestSignal.workout(bool valid)
    : this._(QuestSignalKind.workout, workoutValid: valid);
  const QuestSignal.trained(Exercise exercise)
    : this._(QuestSignalKind.trained, exercise: exercise);
  const QuestSignal.recovered(String stationType)
    : this._(QuestSignalKind.recovered, stationType: stationType);

  final QuestSignalKind kind;
  final String? npcId;
  final Exercise? exercise;
  final bool workoutValid;
  final String? stationType;
}

class QuestUpdate {
  const QuestUpdate({
    required this.progress,
    this.started = false,
    this.completedObjectives = const [],
    this.completed = false,
    this.progressed = false,
  });
  final QuestProgress progress;
  final bool started, completed, progressed;
  final List<QuestObjectiveDefinition> completedObjectives;
  bool get changed => started || completed || progressed;
}

class QuestEngine {
  const QuestEngine(this.quest);
  final QuestDefinition quest;

  bool _objectiveDone(QuestProgress p, QuestObjectiveDefinition o) =>
      p.count(o.id) >= o.targetCount;

  bool allDone(QuestProgress p) =>
      quest.objectives.every((o) => _objectiveDone(p, o));

  bool _typeDone(QuestProgress p, ObjectiveType type) => quest.objectives
      .where((o) => o.type == type)
      .every((o) => _objectiveDone(p, o));

  QuestObjectiveDefinition? currentObjective(QuestProgress p) {
    for (final o in quest.objectives) {
      if (!_objectiveDone(p, o)) return o;
    }
    return null;
  }

  bool _matches(
    QuestObjectiveDefinition o,
    QuestSignal s,
    QuestProgress progress,
  ) {
    final c = o.conditions;
    final e = s.exercise;
    switch (o.type) {
      case ObjectiveType.npcInteraction:
        return s.kind == QuestSignalKind.npc && s.npcId == c['npcId'];
      case ObjectiveType.exerciseDiscovery:
        return s.kind == QuestSignalKind.discovered &&
            e != null &&
            (c['category'] == null || e.category == c['category']) &&
            (c['primaryMuscle'] == null ||
                e.primaryMuscles.contains(c['primaryMuscle']));
      case ObjectiveType.exerciseInspection:
        return s.kind == QuestSignalKind.inspected &&
            e != null &&
            (c['movementRole'] == null ||
                e.movementRole.name == c['movementRole']);
      case ObjectiveType.workoutValidation:
        return s.kind == QuestSignalKind.workout && s.workoutValid;
      case ObjectiveType.trainingCompletion:
        // "Don't collect exercises. Build a session." The working set counts
        // once the player has built a valid session; training is never
        // blocked, only the quest credit waits for the lesson.
        return s.kind == QuestSignalKind.trained &&
            e != null &&
            (c['primaryMuscle'] == null ||
                e.primaryMuscles.contains(c['primaryMuscle'])) &&
            _typeDone(progress, ObjectiveType.workoutValidation);
      case ObjectiveType.npcAfterTraining:
        // The return step must not count before training (spec phase 15).
        return s.kind == QuestSignalKind.npc &&
            s.npcId == c['npcId'] &&
            _typeDone(progress, ObjectiveType.trainingCompletion);
      case ObjectiveType.recoveryAction:
        return s.kind == QuestSignalKind.recovered &&
            s.stationType == c['stationType'] &&
            _typeDone(progress, ObjectiveType.npcAfterTraining);
    }
  }

  /// Applies one signal. When the quest is `available` and the signal is the
  /// coach interaction that starts it, the quest becomes active and
  /// [retroactive] signals (e.g. exercises discovered before talking to the
  /// coach) are credited so exploration order never soft-locks the player.
  QuestUpdate apply(
    QuestProgress progress,
    QuestSignal signal, {
    List<QuestSignal> retroactive = const [],
  }) {
    if (progress.state == QuestState.completed ||
        progress.state == QuestState.locked) {
      return QuestUpdate(progress: progress);
    }
    var started = false;
    var p = progress;
    var signals = [signal];
    if (p.state == QuestState.available) {
      final starter = quest.objectives.firstWhere(
        (o) => o.type == ObjectiveType.npcInteraction,
        orElse: () => quest.objectives.first,
      );
      if (!_matches(starter, signal, p)) return QuestUpdate(progress: p);
      started = true;
      p = p.copyWith(state: QuestState.active);
      signals = [signal, ...retroactive];
    }

    final completedNow = <QuestObjectiveDefinition>[];
    final counts = Map<String, int>.from(p.objectiveProgress);
    var progressed = false;
    for (final s in signals) {
      for (final o in quest.objectives) {
        final before = counts[o.id] ?? 0;
        if (before >= o.targetCount) continue;
        final snapshot = p.copyWith(objectiveProgress: counts);
        if (!_matches(o, s, snapshot)) continue;
        final after = math.min(o.targetCount, before + 1);
        counts[o.id] = after;
        progressed = true;
        if (after >= o.targetCount) completedNow.add(o);
      }
    }
    p = p.copyWith(objectiveProgress: counts);
    final completed = allDone(p);
    if (completed) p = p.copyWith(state: QuestState.completed);
    return QuestUpdate(
      progress: p,
      started: started,
      completedObjectives: completedNow,
      completed: completed,
      progressed: progressed,
    );
  }
}
