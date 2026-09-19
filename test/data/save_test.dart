import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/data/save_codec.dart';
import 'package:iron_ascent/data/save_repositories.dart';
import 'package:iron_ascent/domain/engine.dart';
import 'package:iron_ascent/domain/player.dart';

import '../support/test_content.dart';

void main() {
  const codec = SaveCodec();
  final content = loadTestContent();

  GameEngine playedEngine() {
    final e = newEngine(content);
    e.interactWithNpc(coachId);
    e.inspectExercise(incline);
    e.inspectExercise(cable);
    e.toggleWorkoutExercise(incline);
    e.completeTraining(incline, 4);
    e.updateSettings(const GameSettings(reducedMotion: true, textScale: 1.25));
    return e;
  }

  group('save serialization', () {
    test('round-trips every persisted field', () {
      final original = playedEngine().state;
      final restored = codec.decode(codec.encode(original));
      expect(restored.schemaVersion, 1);
      expect(restored.player.xp, original.player.xp);
      expect(restored.player.level, original.player.level);
      expect(restored.player.condition, original.player.condition);
      expect(
        restored.player.discoveredExerciseIds,
        original.player.discoveredExerciseIds,
      );
      expect(
        restored.player.unlockedCodexIds,
        original.player.unlockedCodexIds,
      );
      expect(
        restored.player.unlockedKnowledgeIds,
        original.player.unlockedKnowledgeIds,
      );
      final q = restored.player.questProgress[content.quest.id]!;
      final oq = original.player.questProgress[content.quest.id]!;
      expect(q.state, QuestState.active);
      expect(q.objectiveProgress, oq.objectiveProgress);
      expect(q.rewardClaimed, oq.rewardClaimed);
      expect(restored.selection.exerciseIds, [incline]);
      expect(restored.settings.reducedMotion, isTrue);
      expect(restored.settings.textScale, 1.25);
      expect(codec.encode(restored), codec.encode(original));
    });

    test('JSON includes schemaVersion and level but no static content', () {
      final json = codec.toJson(playedEngine().state);
      expect(json['schemaVersion'], 1);
      expect((json['player'] as Map)['level'], 1);
      expect(json.toString(), isNot(contains('techniqueNotes')));
      expect(json.toString(), isNot(contains('fatigueCost')));
    });

    test('completed quest round-trips with reward flag', () {
      final e = playedEngine();
      e.inspectExercise(machine);
      e.toggleWorkoutExercise(machine);
      e.toggleWorkoutExercise(cable);
      e.validateWorkout();
      e.completeTraining(incline, 4);
      e.interactWithNpc(coachId);
      e.useRecoveryMat();
      final restored = codec.decode(codec.encode(e.state));
      final q = restored.player.questProgress[content.quest.id]!;
      expect(q.state, QuestState.completed);
      expect(q.rewardClaimed, isTrue);
      expect(restored.player.unlockedKnowledgeIds, {'chest_programming_1'});
      expect(restored.player.level, 2);
    });

    test('corrupt or future saves fail with a controlled exception', () {
      expect(
        () => codec.decode('not json'),
        throwsA(isA<SaveCorruptException>()),
      );
      expect(() => codec.decode('[]'), throwsA(isA<SaveCorruptException>()));
      expect(
        () => codec.decode('{"schemaVersion":99,"player":{}}'),
        throwsA(isA<SaveCorruptException>()),
      );
      expect(
        () => codec.decode('{"schemaVersion":1,"player":{"xp":"x"}}'),
        throwsA(isA<SaveCorruptException>()),
      );
    });
  });

  group('save repository', () {
    test('save -> destroy state -> load -> compare', () async {
      final repo = InMemorySaveRepository();
      final engine = playedEngine();
      await repo.save(engine.state);
      final snapshot = codec.encode(engine.state);

      // Simulate a fresh process: brand-new engine from the loaded save.
      final loaded = await repo.load();
      expect(loaded, isNotNull);
      final fresh = GameEngine(content, loaded!);
      expect(codec.encode(fresh.state), snapshot);
      expect(fresh.player.discoveredExerciseIds, {incline, cable});
      expect(
        fresh.player.condition,
        PlayerCondition(hydration: 77, fatigue: 22),
      );
      expect(fresh.questProgress.isActive, isTrue);
    });

    test('missing save loads as null (no existing game)', () async {
      expect(await InMemorySaveRepository().load(), isNull);
    });

    test('reset clears gameplay progress', () async {
      final repo = InMemorySaveRepository();
      await repo.save(playedEngine().state);
      await repo.clear();
      expect(await repo.load(), isNull);
      final fresh = SaveGame.newGame(content.quest.id);
      expect(fresh.player.xp, 0);
      expect(fresh.player.discoveredExerciseIds, isEmpty);
      expect(
        fresh.player.questProgress[content.quest.id]!.state,
        QuestState.available,
      );
    });
  });
}
