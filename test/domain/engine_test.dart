import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/domain/engine.dart';
import 'package:iron_ascent/domain/events.dart';
import 'package:iron_ascent/domain/player.dart';
import 'package:iron_ascent/domain/rules.dart';

import '../support/test_content.dart';

void main() {
  late GameEngine engine;
  setUp(() => engine = newEngine());

  QuestProgress quest() => engine.questProgress;

  /// Coach -> discover all three -> build the canonical session.
  void reachTraining() {
    engine.interactWithNpc(coachId);
    for (final id in [incline, machine, cable]) {
      engine.inspectExercise(id);
      engine.toggleWorkoutExercise(id);
    }
    expect(engine.validateWorkout().$1.isValid, isTrue);
  }

  group('exercise discovery', () {
    test('first inspection discovers, unlocks Codex, grants +5 XP once', () {
      final events = engine.inspectExercise(incline);
      expect(events.whereType<ExerciseDiscovered>(), hasLength(1));
      expect(
        events.whereType<CodexUnlocked>().single.codexId,
        'codex:$incline',
      );
      expect(events.whereType<XPGranted>().single.amount, 5);
      expect(events.whereType<ExerciseInspected>(), hasLength(1));
      expect(events.last, isA<SaveRequested>());
      expect(engine.player.xp, 5);
      expect(engine.player.discoveredExerciseIds, {incline});
      expect(engine.isCodexUnlocked(incline), isTrue);

      final again = engine.inspectExercise(incline);
      expect(again.whereType<ExerciseDiscovered>(), isEmpty);
      expect(again.whereType<CodexUnlocked>(), isEmpty);
      expect(again.whereType<XPGranted>(), isEmpty);
      expect(again.whereType<ExerciseInspected>(), hasLength(1));
      expect(engine.player.xp, 5);
      expect(engine.player.unlockedCodexIds, hasLength(1));
    });

    test('inspection never changes condition', () {
      final before = engine.player.condition;
      engine.inspectExercise(cable);
      expect(engine.player.condition, before);
    });

    test('unknown exercise is a controlled no-op', () {
      expect(engine.inspectExercise('ghost'), isEmpty);
    });
  });

  group('quest progression', () {
    test('new game quest is available, coach starts it', () {
      expect(quest().state, QuestState.available);
      expect(engine.coachDialogueId(), 'coach_intro');
      final events = engine.interactWithNpc(coachId);
      expect(events.first, isA<NPCInteracted>());
      expect((events.first as NPCInteracted).dialogueId, 'coach_intro');
      expect(events.whereType<QuestStarted>(), hasLength(1));
      expect(
        events.whereType<QuestObjectiveCompleted>().single.objectiveId,
        'talk_to_coach',
      );
      expect(quest().state, QuestState.active);
      expect(engine.currentObjective!.id, 'discover_three_chest_exercises');
      expect(engine.coachDialogueId(), 'coach_after_discovery');
    });

    test('three discoveries complete discovery, press and isolation', () {
      engine.interactWithNpc(coachId);
      engine.inspectExercise(incline);
      expect(quest().count('discover_three_chest_exercises'), 1);
      expect(quest().count('inspect_press'), 1);
      expect(quest().count('inspect_isolation'), 0);
      engine.inspectExercise(machine);
      final events = engine.inspectExercise(cable);
      expect(quest().count('discover_three_chest_exercises'), 3);
      expect(quest().count('inspect_isolation'), 1);
      expect(
        events.whereType<QuestObjectiveCompleted>().map((e) => e.objectiveId),
        containsAll(['discover_three_chest_exercises', 'inspect_isolation']),
      );
      expect(engine.currentObjective!.id, 'build_three_exercise_session');
    });

    test('discoveries made before talking to the coach are credited', () {
      engine.inspectExercise(incline);
      engine.inspectExercise(cable);
      expect(quest().count('discover_three_chest_exercises'), 0);
      engine.interactWithNpc(coachId);
      expect(quest().count('discover_three_chest_exercises'), 2);
      expect(quest().count('inspect_press'), 1);
      expect(quest().count('inspect_isolation'), 1);
      expect(engine.player.xp, 10);
    });

    test('valid workout completes the builder objective; invalid does not', () {
      engine.interactWithNpc(coachId);
      for (final id in [incline, machine, cable]) {
        engine.inspectExercise(id);
      }
      engine.toggleWorkoutExercise(incline);
      engine.toggleWorkoutExercise(machine);
      var (result, events) = engine.validateWorkout();
      expect(result.isValid, isFalse);
      expect(events.whereType<QuestObjectiveCompleted>(), isEmpty);
      expect(quest().count('build_three_exercise_session'), 0);

      engine.toggleWorkoutExercise(cable);
      (result, events) = engine.validateWorkout();
      expect(result.isValid, isTrue);
      expect(
        events.whereType<QuestObjectiveCompleted>().single.objectiveId,
        'build_three_exercise_session',
      );
      expect(engine.state.selection.exerciseIds, [incline, machine, cable]);
    });

    test('training before the session is built changes condition only', () {
      engine.interactWithNpc(coachId);
      engine.inspectExercise(incline);
      final events = engine.completeTraining(incline, 4);
      expect(events.whereType<ExerciseCompleted>(), hasLength(1));
      expect(
        engine.player.condition,
        PlayerCondition(hydration: 77, fatigue: 22),
      );
      expect(quest().count('complete_working_set'), 0);
      expect(engine.currentObjective!.id, 'discover_three_chest_exercises');
    });

    test('training completes the set objective and mutates condition', () {
      reachTraining();
      final events = engine.completeTraining(incline, 4);
      final result = events.whereType<ExerciseCompleted>().single.result;
      expect(result.grade, TrainingGrade.good);
      expect(result.fatigueAdded, 12);
      expect(result.hydrationLost, 3);
      expect(result.xpGranted, 20);
      expect(events.whereType<HydrationChanged>().single.to, 77);
      expect(events.whereType<FatigueChanged>().single.to, 22);
      expect(
        engine.player.condition,
        PlayerCondition(hydration: 77, fatigue: 22),
      );
      expect(engine.player.xp, 35);
      expect(quest().count('complete_working_set'), 1);
      expect(engine.currentObjective!.id, 'return_to_coach');
      // Deterministic order (section 56).
      final types = events.map((e) => e.runtimeType).toList();
      expect(
        types.indexOf(HydrationChanged),
        lessThan(types.indexOf(FatigueChanged)),
      );
      expect(types.indexOf(FatigueChanged), lessThan(types.indexOf(XPGranted)));
      expect(
        types.indexOf(XPGranted),
        lessThan(types.indexOf(ExerciseCompleted)),
      );
      expect(types.last, SaveRequested);
    });

    test('a failed set still progresses the quest with reduced XP', () {
      reachTraining();
      final events = engine.completeTraining(incline, 0);
      final result = events.whereType<ExerciseCompleted>().single.result;
      expect(result.grade, TrainingGrade.failed);
      expect(result.xpGranted, 10);
      expect(result.fatigueAdded, 14);
      expect(quest().count('complete_working_set'), 1);
    });

    test('coach return only counts after training', () {
      reachTraining();
      engine.interactWithNpc(coachId);
      expect(quest().count('return_to_coach'), 0);
      expect(engine.coachDialogueId(), 'coach_after_discovery');
      engine.completeTraining(incline, 5);
      expect(engine.coachDialogueId(), 'coach_after_training');
      final events = engine.interactWithNpc(coachId);
      expect(
        (events.first as NPCInteracted).dialogueId,
        'coach_after_training',
      );
      expect(quest().count('return_to_coach'), 1);
    });

    test(
      'recovery mat only completes the final objective after coach return',
      () {
        reachTraining();
        engine.useRecoveryMat();
        expect(quest().count('recover'), 0);
        engine.completeTraining(incline, 5);
        engine.useRecoveryMat();
        expect(quest().count('recover'), 0);
        engine.interactWithNpc(coachId);
        engine.useRecoveryMat();
        expect(quest().count('recover'), 1);
      },
    );
  });

  group('recovery', () {
    test('water adds 15 hydration, caps at 100, leaves fatigue alone', () {
      engine.completeTraining(incline, 4); // 77 / 22
      var events = engine.drinkWater();
      expect(events.whereType<WaterConsumed>(), hasLength(1));
      expect(events.whereType<HydrationChanged>().single.to, 92);
      expect(events.whereType<FatigueChanged>(), isEmpty);
      engine.drinkWater();
      expect(engine.player.condition.hydration, 100);
      events = engine.drinkWater();
      expect(engine.player.condition.hydration, 100);
      expect(events.whereType<HydrationChanged>(), isEmpty);
      expect(engine.player.condition.fatigue, 22);
    });

    test('recovery mat removes 15 fatigue, floors at 0, leaves hydration', () {
      engine.completeTraining(incline, 4); // 77 / 22
      var events = engine.useRecoveryMat();
      expect(
        events.whereType<RecoveryPerformed>().single.stationType,
        'recovery_mat',
      );
      expect(events.whereType<FatigueChanged>().single.to, 7);
      expect(events.whereType<HydrationChanged>(), isEmpty);
      events = engine.useRecoveryMat();
      expect(engine.player.condition.fatigue, 0);
      expect(engine.player.condition.hydration, 77);
    });
  });

  group('full chest-day loop', () {
    List<GameEvent> playThrough(GameEngine e) {
      final all = <GameEvent>[];
      all.addAll(e.interactWithNpc(coachId));
      for (final id in [incline, machine, cable]) {
        all.addAll(e.inspectExercise(id));
        e.toggleWorkoutExercise(id);
      }
      all.addAll(e.validateWorkout().$2);
      all.addAll(e.completeTraining(incline, 4));
      all.addAll(e.interactWithNpc(coachId));
      all.addAll(e.drinkWater());
      all.addAll(e.useRecoveryMat());
      return all;
    }

    test('matches the canonical completed state', () {
      final events = playThrough(engine);
      final q = quest();
      expect(q.state, QuestState.completed);
      expect(q.rewardClaimed, isTrue);
      expect(engine.player.xp, 135); // 15 discovery + 20 training + 100 quest
      expect(engine.player.level, 2);
      expect(
        engine.player.condition,
        PlayerCondition(hydration: 92, fatigue: 7),
      );
      expect(engine.player.unlockedKnowledgeIds, {'chest_programming_1'});
      expect(engine.player.unlockedCodexIds, hasLength(3));
      expect(events.whereType<QuestCompleted>(), hasLength(1));
      expect(events.whereType<KnowledgeUnlocked>(), hasLength(1));
      expect(events.whereType<PlayerLeveledUp>().single.level, 2);
      expect(
        events
            .whereType<XPGranted>()
            .where((e) => e.source == 'quest')
            .single
            .amount,
        100,
      );
      expect(engine.currentObjective, isNull);
      expect(engine.coachDialogueId(), 'coach_completion');
    });

    test('quest reward is never granted twice', () {
      playThrough(engine);
      final xp = engine.player.xp;
      final again = [
        ...engine.interactWithNpc(coachId),
        ...engine.useRecoveryMat(),
        ...engine.drinkWater(),
        ...engine.validateWorkout().$2,
        ...engine.inspectExercise(incline),
      ];
      expect(again.whereType<QuestCompleted>(), isEmpty);
      expect(again.whereType<KnowledgeUnlocked>(), isEmpty);
      expect(again.whereType<XPGranted>(), isEmpty);
      expect(engine.player.xp, xp);
      expect(quest().rewardClaimed, isTrue);
    });

    test('reopening the engine on a completed save cannot re-award', () {
      playThrough(engine);
      final reopened = GameEngine(engine.content, engine.state);
      final events = [
        ...reopened.interactWithNpc(coachId),
        ...reopened.useRecoveryMat(),
      ];
      expect(events.whereType<QuestCompleted>(), isEmpty);
      expect(reopened.player.xp, 135);
    });
  });

  group('settings', () {
    test('updates settings and requests save', () {
      final events = engine.updateSettings(
        const GameSettings(reducedMotion: true, audioVolume: 0.3),
      );
      expect(events.first, isA<SettingsChanged>());
      expect(events.last, isA<SaveRequested>());
      expect(engine.state.settings.reducedMotion, isTrue);
      expect(engine.state.settings.audioVolume, 0.3);
    });
  });
}
