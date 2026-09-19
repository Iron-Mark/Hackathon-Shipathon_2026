import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/domain/player.dart';
import 'package:iron_ascent/domain/rules.dart';

import '../support/test_content.dart';

void main() {
  final content = loadTestContent();
  final exercises = content.exercises;
  final allDiscovered = {incline, machine, cable};

  WorkoutValidationResult validate(
    List<String> ids, {
    Set<String>? discovered,
  }) => WorkoutValidator.validate(
    WorkoutSelection(ids),
    exercises,
    discovered ?? allDiscovered,
  );

  group('new game defaults', () {
    test('canonical starting state', () {
      final save = SaveGame.newGame(content.quest.id);
      expect(save.schemaVersion, 1);
      expect(save.player.level, 1);
      expect(save.player.xp, 0);
      expect(
        save.player.condition,
        PlayerCondition(hydration: 80, fatigue: 10),
      );
      expect(save.player.discoveredExerciseIds, isEmpty);
      expect(save.player.unlockedCodexIds, isEmpty);
      expect(save.player.unlockedKnowledgeIds, isEmpty);
      final q = save.player.questProgress[content.quest.id]!;
      expect(q.state, QuestState.available);
      expect(q.rewardClaimed, isFalse);
      expect(save.selection.exerciseIds, isEmpty);
      expect(save.settings.reducedMotion, isFalse);
      expect(save.settings.audioVolume, 1);
      expect(save.settings.graphicsQuality, 'medium');
    });
  });

  group('condition clamping', () {
    test('hydration and fatigue stay within 0..100', () {
      expect(
        PlayerCondition(hydration: 95).change(hydration: 15).hydration,
        100,
      );
      expect(PlayerCondition(hydration: 5).change(hydration: -15).hydration, 0);
      expect(PlayerCondition(fatigue: 95).change(fatigue: 15).fatigue, 100);
      expect(PlayerCondition(fatigue: 5).change(fatigue: -15).fatigue, 0);
      expect(PlayerCondition(hydration: 500, fatigue: -3).hydration, 100);
      expect(PlayerCondition(hydration: 500, fatigue: -3).fatigue, 0);
    });
  });

  group('workout validation', () {
    test('press + press + isolation -> valid', () {
      final r = validate([incline, machine, cable]);
      expect(r.isValid, isTrue);
      expect(
        r.passedRules,
        containsAll(['exactly_three', 'contains_press', 'contains_isolation']),
      );
      expect(r.warnings, isEmpty);
    });

    test('press + press + press -> invalid with educational feedback', () {
      final r = validate([incline, machine, incline]);
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.isolationRequired));
      expect(r.errors, contains(WorkoutValidator.noDuplicates));
      expect(r.warnings, contains(WorkoutValidator.pressHeavy));
      expect(r.warnings, contains(WorkoutValidator.sameRoleHint));
      expect(r.feedback.toUpperCase(), isNot(contains('WRONG')));
      expect(r.feedback.toUpperCase(), isNot(contains('FAILED')));
    });

    test('isolation + isolation + isolation -> invalid', () {
      final r = validate([cable, cable, cable]);
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.pressRequired));
    });

    test('2 exercises -> invalid', () {
      final r = validate([incline, cable]);
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.exactlyThree));
    });

    test('4 exercises -> invalid', () {
      final r = validate([incline, machine, cable, incline]);
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.exactlyThree));
    });

    test('duplicates -> invalid', () {
      final r = validate([incline, incline, cable]);
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.noDuplicates));
    });

    test('undiscovered exercise -> invalid', () {
      final r = validate(
        [incline, machine, cable],
        discovered: {incline, machine},
      );
      expect(r.isValid, isFalse);
      expect(r.errors, contains(WorkoutValidator.discoveredOnly));
    });

    test('selection never grows past three', () {
      var s = WorkoutSelection();
      for (final id in [incline, machine, cable, incline]) {
        s = s.toggle(id);
      }
      expect(s.exerciseIds, [machine, cable]);
      s = s.toggle(incline);
      expect(s.exerciseIds, hasLength(3));
      expect(s.toggle('pec_deck').exerciseIds, hasLength(3));
    });
  });

  group('training', () {
    final inclinePress = exercises[incline]!;
    final fresh = PlayerCondition(hydration: 80, fatigue: 10);

    test('grade mapping for five reps', () {
      expect(TrainingRules.gradeFor(5, 5), TrainingGrade.excellent);
      expect(TrainingRules.gradeFor(4, 5), TrainingGrade.good);
      expect(TrainingRules.gradeFor(3, 5), TrainingGrade.rough);
      expect(TrainingRules.gradeFor(2, 5), TrainingGrade.rough);
      expect(TrainingRules.gradeFor(1, 5), TrainingGrade.failed);
      expect(TrainingRules.gradeFor(0, 5), TrainingGrade.failed);
    });

    test('XP formula: base 20 -> 25 / 20 / 15 / 10', () {
      int xp(int clean) => TrainingRules.performSet(
        exercise: inclinePress,
        condition: fresh,
        cleanReps: clean,
      ).xpGranted;
      expect(xp(5), 25);
      expect(xp(4), 20);
      expect(xp(3), 15);
      expect(xp(0), 10);
    });

    test('fatigue formula applies grade and state multipliers', () {
      int fatigue(int clean, int current) => TrainingRules.performSet(
        exercise: inclinePress,
        condition: PlayerCondition(fatigue: current),
        cleanReps: clean,
      ).fatigueAdded;
      expect(fatigue(4, 10), 12); // 12 * 1.0 * 1.0
      expect(fatigue(2, 10), 13); // 12 * 1.1 = 13.2
      expect(fatigue(0, 10), 14); // 12 * 1.2 = 14.4
      expect(fatigue(5, 50), 13); // 12 * 1.0 * 1.1
      expect(fatigue(5, 75), 14); // 12 * 1.0 * 1.2
      expect(fatigue(0, 80), 17); // 12 * 1.2 * 1.2 = 17.28
    });

    test('hydration cost equals the exercise hydrationCost', () {
      final r = TrainingRules.performSet(
        exercise: inclinePress,
        condition: fresh,
        cleanReps: 4,
      );
      expect(r.hydrationLost, 3);
      expect(r.totalReps, 5);
      expect(r.cleanReps, 4);
      expect(r.grade, TrainingGrade.good);
    });

    test('condition modifiers shrink the timing window slightly', () {
      expect(TrainingRules.timingWindowScale(fresh), 1.0);
      expect(
        TrainingRules.timingWindowScale(PlayerCondition(hydration: 40)),
        closeTo(0.95, 1e-9),
      );
      expect(
        TrainingRules.timingWindowScale(PlayerCondition(hydration: 10)),
        closeTo(0.90, 1e-9),
      );
      expect(
        TrainingRules.timingWindowScale(PlayerCondition(fatigue: 60)),
        closeTo(0.95, 1e-9),
      );
      expect(
        TrainingRules.timingWindowScale(
          PlayerCondition(hydration: 10, fatigue: 90),
        ),
        closeTo(0.80, 1e-9),
      );
    });
  });

  group('level progression', () {
    test('thresholds 0/100/250/450/700', () {
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(249), 2);
      expect(levelForXp(250), 3);
      expect(levelForXp(450), 4);
      expect(levelForXp(700), 5);
      expect(levelForXp(5000), 5);
      expect(xpForNextLevel(0), 100);
      expect(xpForNextLevel(135), 250);
      expect(xpForNextLevel(700), isNull);
    });
  });
}
