import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/domain/player.dart';
import 'package:iron_ascent/features/codex/codex_screen.dart';
import 'package:iron_ascent/features/game/hud.dart';
import 'package:iron_ascent/features/quests/quest_log_screen.dart';
import 'package:iron_ascent/features/session/session_builder_screen.dart';
import 'package:iron_ascent/features/settings/settings_screen.dart';
import 'package:iron_ascent/features/training/training_screen.dart';

import '../support/test_app.dart';
import '../support/test_content.dart';

void main() {
  group('HUD', () {
    testWidgets('displays player condition, level and XP with labels', (
      tester,
    ) async {
      final session = await buildTestSession();
      session.inspectExercise(incline); // +5 XP
      await tester.pumpWidget(
        wrap(
          session,
          Scaffold(
            body: ConditionPanel(
              condition: session.condition,
              level: session.player.level,
              xp: session.player.xp,
              onMenu: () {},
            ),
          ),
        ),
      );
      expect(find.text('HYDRATION'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('FATIGUE'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('LEVEL 1   5 XP'), findsOneWidget);
    });

    testWidgets('quest tracker shows the current objective and progress', (
      tester,
    ) async {
      final session = await buildTestSession();
      session.interactWithCoach();
      session.inspectExercise(incline);
      await tester.pumpWidget(
        wrap(
          session,
          Scaffold(
            body: QuestTracker(session: session, onOpenSessionBuilder: () {}),
          ),
        ),
      );
      expect(find.text('BUILD YOUR FIRST CHEST DAY'), findsOneWidget);
      expect(find.text('Discover 3 chest exercises'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('interaction prompt shows one contextual action', (
      tester,
    ) async {
      final session = await buildTestSession();
      final coach = session.content.district.interactables.first;
      await tester.pumpWidget(
        wrap(
          session,
          Scaffold(
            body: InteractionPrompt(
              target: coach,
              discovered: false,
              controlHints: true,
              touch: false,
            ),
          ),
        ),
      );
      expect(find.text('HYPERTROPHY COACH'), findsOneWidget);
      expect(find.text('Talk'), findsOneWidget);
    });
  });

  group('Quest Log', () {
    testWidgets('displays objective states', (tester) async {
      final session = await buildTestSession();
      session.interactWithCoach();
      session.inspectExercise(incline);
      await tester.pumpWidget(wrap(session, const QuestLogScreen()));
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('Talk to the Hypertrophy Coach'), findsOneWidget);
      expect(find.text('Inspect a pressing movement'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp('Completed: Talk to the Hypertrophy Coach'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Open: Recover on the Recovery Mat')),
        findsOneWidget,
      );
    });
  });

  group('Codex', () {
    testWidgets('shows locked entries as ??? and unlocked entries by name', (
      tester,
    ) async {
      final session = await buildTestSession();
      session.inspectExercise(cable);
      await tester.pumpWidget(wrap(session, const CodexScreen()));
      expect(find.text('Cable Fly'), findsOneWidget);
      expect(find.text('???'), findsNWidgets(3)); // two exercises + knowledge
      expect(find.text('1 / 3 exercises discovered'), findsOneWidget);
      expect(find.text('PRESSING'), findsOneWidget);
      expect(find.text('ISOLATION'), findsWidgets);
    });

    testWidgets('shows Chest Programming I after the quest completes', (
      tester,
    ) async {
      final session = await buildTestSession();
      session.interactWithCoach();
      for (final id in [incline, machine, cable]) {
        session.inspectExercise(id);
        session.toggleWorkoutExercise(id);
      }
      session.validateWorkout();
      session.completeTraining(incline, 5);
      session.interactWithCoach();
      session.useRecoveryMat();
      await tester.pumpWidget(wrap(session, const CodexScreen()));
      expect(find.text('CHEST PROGRAMMING I'), findsOneWidget);
      expect(find.text('???'), findsNothing);
      expect(find.text('3 / 3 exercises discovered'), findsOneWidget);
    });
  });

  group('Session Builder', () {
    testWidgets('enforces discovered-only, max three, and explains structure', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final session = await buildTestSession();
      session.interactWithCoach();
      session.inspectExercise(incline);
      session.inspectExercise(machine);
      await tester.pumpWidget(wrap(session, const SessionBuilderScreen()));

      // Undiscovered cable fly is locked out.
      expect(find.text('???'), findsOneWidget);
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3));
      expect(tester.widget<Checkbox>(checkboxes.at(2)).onChanged, isNull);

      await tester.tap(find.text('Incline Dumbbell Press'));
      await tester.pump();
      await tester.tap(find.text('Machine Chest Press'));
      await tester.pump();
      expect(find.text('Exercise count  2 / 3'), findsOneWidget);

      await tester.ensureVisible(find.text('VALIDATE SESSION'));
      await tester.tap(find.text('VALIDATE SESSION'));
      await tester.pump();
      expect(find.text('SESSION NEEDS ADJUSTMENT'), findsOneWidget);
      expect(find.textContaining('Select exactly three'), findsOneWidget);
      expect(find.textContaining('heavily press-focused'), findsOneWidget);
      expect(session.engine.sessionBuilt, isFalse);

      // Discover the isolation movement and complete the canonical session.
      session.inspectExercise(cable);
      await tester.pump();
      await tester.ensureVisible(find.text('Cable Fly'));
      await tester.tap(find.text('Cable Fly'));
      await tester.pump();
      expect(find.text('Exercise count  3 / 3'), findsOneWidget);
      await tester.ensureVisible(find.text('VALIDATE SESSION'));
      await tester.tap(find.text('VALIDATE SESSION'));
      await tester.pump();
      expect(find.text('SESSION APPROVED'), findsOneWidget);
      expect(session.engine.sessionBuilt, isTrue);
      expect(session.selection.exerciseIds, [incline, machine, cable]);
    });
  });

  group('Settings', () {
    testWidgets('loads current settings and updates them', (tester) async {
      final session = await buildTestSession();
      await tester.pumpWidget(wrap(session, const SettingsScreen()));
      expect(find.text('Reduced motion'), findsOneWidget);
      expect(find.text('Control hints'), findsOneWidget);
      expect(find.text('100%'), findsNWidgets(2));
      expect(find.text('RESET SAVE'), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pump();
      expect(session.settings.reducedMotion, isTrue);
      expect(session.engine.state.settings.reducedMotion, isTrue);
    });
  });

  group('Training scoring', () {
    test('rates reps by distance from the control zone', () {
      expect(rateRep(0.5, 0.5, 0.1), RepRating.clean);
      expect(rateRep(0.54, 0.5, 0.1), RepRating.clean);
      expect(rateRep(0.58, 0.5, 0.1), RepRating.good);
      expect(rateRep(0.65, 0.5, 0.1), RepRating.rough);
      expect(rateRep(0.9, 0.5, 0.1), RepRating.miss);
      expect(RepRating.good.countsAsClean, isTrue);
      expect(RepRating.rough.countsAsClean, isFalse);
    });

    test('new game selection defaults are empty', () async {
      final session = await buildTestSession();
      expect(session.selection.exerciseIds, isEmpty);
      expect(session.questProgress.state, QuestState.available);
    });
  });
}
