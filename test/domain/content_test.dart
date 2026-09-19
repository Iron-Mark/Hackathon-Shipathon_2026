import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/domain/content.dart';

import '../support/test_content.dart';

void main() {
  group('content parsing', () {
    final content = loadTestContent();

    test('loads the three canonical chest exercises with spec values', () {
      expect(content.exercises.keys, containsAll([incline, machine, cable]));
      final e = content.exercises[incline]!;
      expect(e.name, 'Incline Dumbbell Press');
      expect(e.movementRole, MovementRole.press);
      expect(e.primaryMuscles, ['chest']);
      expect(e.secondaryMuscles, ['triceps', 'anterior_deltoids']);
      expect(e.emphasis, ['upper_chest']);
      expect(e.fatigueCost, 12);
      expect(e.hydrationCost, 3);
      expect(e.xpReward, 20);
      expect(e.techniqueDifficulty, 2);
      expect(e.codexUnlock, isTrue);
      expect(e.techniqueNotes, hasLength(3));
      final m = content.exercises[machine]!;
      expect((m.fatigueCost, m.hydrationCost, m.xpReward), (10, 2, 18));
      final c = content.exercises[cable]!;
      expect(c.movementRole, MovementRole.isolation);
      expect((c.fatigueCost, c.hydrationCost, c.xpReward), (8, 2, 16));
      expect(c.secondaryMuscles, isEmpty);
    });

    test('loads the chest-day quest with eight ordered objectives', () {
      final q = content.quest;
      expect(q.id, 'build_first_chest_day');
      expect(q.title, 'Build Your First Chest Day');
      expect(q.districtId, 'hypertrophy_gym');
      expect(q.objectives.map((o) => o.id), [
        'talk_to_coach',
        'discover_three_chest_exercises',
        'inspect_press',
        'inspect_isolation',
        'build_three_exercise_session',
        'complete_working_set',
        'return_to_coach',
        'recover',
      ]);
      expect(q.objectives[1].targetCount, 3);
      expect(q.rewardXp, 100);
      expect(q.knowledgeIds, ['chest_programming_1']);
    });

    test('loads district, coach and knowledge with canonical IDs', () {
      expect(content.district.id, 'hypertrophy_gym');
      expect(content.district.spawn.x, 2.5);
      expect(content.district.spawn.z, 8.0);
      expect(content.district.stationIds, hasLength(5));
      expect(content.district.npcIds, [coachId]);
      expect(content.coach.id, coachId);
      expect(
        content.coach.dialogue['coach_intro'],
        startsWith("Don't collect exercises. Build a session."),
      );
      expect(content.coach.dialogueIds, hasLength(4));
      expect(content.knowledge.id, 'chest_programming_1');
      expect(content.knowledge.name, 'Chest Programming I');
    });

    test('district previews and leagues match the MVP product surfaces', () {
      expect(content.district.previews.map((p) => p['name']), [
        'Hypertrophy District',
        'Strength Yard',
        'Cardio Run',
        'Mobility Temple',
        'Recovery House',
        'Macro Market',
        'Arena',
      ]);
      expect(content.district.leagues, [
        'Physique',
        'Strength',
        'Endurance',
        'Hybrid',
      ]);
    });
  });

  group('content validation', () {
    Map<String, dynamic> exerciseJson({
      String id = 'x',
      String role = 'press',
      int fatigue = 1,
    }) => {
      'id': id,
      'name': 'X',
      'category': 'hypertrophy',
      'movementRole': role,
      'primaryMuscles': ['chest'],
      'secondaryMuscles': <String>[],
      'emphasis': <String>[],
      'equipment': <String>[],
      'fatigueCost': fatigue,
      'hydrationCost': 1,
      'xpReward': 1,
      'techniqueDifficulty': 1,
      'codexUnlock': true,
      'summary': 's',
      'techniqueNotes': <String>[],
    };

    test('rejects unknown movement role', () {
      expect(
        () => Exercise.fromJson(exerciseJson(role: 'curl')),
        throwsFormatException,
      );
    });

    test('rejects negative costs and invalid ids', () {
      expect(
        () => Exercise.fromJson(exerciseJson(fatigue: -1)),
        throwsFormatException,
      );
      expect(
        () => Exercise.fromJson(exerciseJson(id: 'Bad Id')),
        throwsFormatException,
      );
    });

    test('rejects unknown objective type and duplicate objective ids', () {
      final quest = readJson(
        'assets/data/quests/build_first_chest_day.json',
      ) as Map<String, dynamic>;
      final bad = Map<String, dynamic>.from(quest);
      bad['objectives'] = [
        Map<String, dynamic>.from((quest['objectives'] as List).first as Map)
          ..['type'] = 'nope',
      ];
      expect(() => QuestDefinition.fromJson(bad), throwsFormatException);
      final dup = Map<String, dynamic>.from(quest);
      final first = (quest['objectives'] as List).first;
      dup['objectives'] = [first, first];
      expect(() => QuestDefinition.fromJson(dup), throwsFormatException);
    });

    test('rejects district referencing a missing station', () {
      final d = readJson(
        'assets/data/districts/hypertrophy_gym.json',
      ) as Map<String, dynamic>;
      final bad = Map<String, dynamic>.from(d);
      bad['stationIds'] = ['ghost_station'];
      expect(() => DistrictDefinition.fromJson(bad), throwsFormatException);
    });

    test('rejects broken cross references between content files', () {
      final content = loadTestContent();
      expect(
        () => GameContent(
          exercises: content.exercises.values
              .where((e) => e.id != cable)
              .toList(),
          quest: content.quest,
          district: content.district,
          coach: content.coach,
          knowledge: content.knowledge,
        ),
        throwsFormatException,
      );
    });
  });
}
