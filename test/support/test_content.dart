// Loads the real bundled content files for tests without a Flutter binding.
import 'dart:convert';
import 'dart:io';

import 'package:iron_ascent/domain/content.dart';
import 'package:iron_ascent/domain/engine.dart';
import 'package:iron_ascent/domain/player.dart';

dynamic readJson(String path) => jsonDecode(File(path).readAsStringSync());

GameContent loadTestContent() => GameContent(
  exercises: (readJson('assets/data/exercises/chest.json') as List)
      .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
      .toList(),
  quest: QuestDefinition.fromJson(
    readJson('assets/data/quests/build_first_chest_day.json')
        as Map<String, dynamic>,
  ),
  district: DistrictDefinition.fromJson(
    readJson('assets/data/districts/hypertrophy_gym.json')
        as Map<String, dynamic>,
  ),
  coach: NPCDefinition.fromJson(
    readJson('assets/data/npcs/hypertrophy_coach.json') as Map<String, dynamic>,
  ),
  knowledge: KnowledgeUnlock.fromJson(
    readJson('assets/data/knowledge/chest_programming_1.json')
        as Map<String, dynamic>,
  ),
);

GameEngine newEngine([GameContent? content]) {
  final c = content ?? loadTestContent();
  return GameEngine(c, SaveGame.newGame(c.quest.id));
}

const incline = 'incline_dumbbell_press';
const machine = 'machine_chest_press';
const cable = 'cable_fly';
const coachId = 'hypertrophy_coach';
