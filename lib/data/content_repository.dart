// Loads and validates the bundled structured content once, then caches it.
import 'dart:convert';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/content.dart';

/// Where each content definition lives. Single source for content paths.
class ContentPaths {
  static const exercises = 'assets/data/exercises/chest.json';
  static const quest = 'assets/data/quests/build_first_chest_day.json';
  static const district = 'assets/data/districts/hypertrophy_gym.json';
  static const coach = 'assets/data/npcs/hypertrophy_coach.json';
  static const knowledge = 'assets/data/knowledge/chest_programming_1.json';
}

/// Thrown when bundled content is missing or fails validation. The caller
/// shows a controlled error instead of crashing.
class ContentLoadException implements Exception {
  ContentLoadException(this.path, this.cause);
  final String path;
  final Object cause;
  @override
  String toString() => 'Content unavailable ($path): $cause';
}

class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// A repository that already holds validated content (tests, tools).
  ContentRepository.preloaded(GameContent content)
    : _bundle = rootBundle,
      _cached = SynchronousFuture(content);

  final AssetBundle _bundle;
  Future<GameContent>? _cached;

  /// Parses static content once; later calls return the cached future.
  Future<GameContent> load() => _cached ??= _load().onError((e, s) {
    _cached = null;
    throw e!;
  });

  Future<T> _json<T>(String path) async {
    try {
      return jsonDecode(await _bundle.loadString(path)) as T;
    } catch (e) {
      throw ContentLoadException(path, e);
    }
  }

  Future<GameContent> _load() async {
    final exercises = await _json<List<dynamic>>(ContentPaths.exercises);
    final quest = await _json<Map<String, dynamic>>(ContentPaths.quest);
    final district = await _json<Map<String, dynamic>>(ContentPaths.district);
    final coach = await _json<Map<String, dynamic>>(ContentPaths.coach);
    final knowledge = await _json<Map<String, dynamic>>(ContentPaths.knowledge);
    try {
      return GameContent(
        exercises: exercises
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        quest: QuestDefinition.fromJson(quest),
        district: DistrictDefinition.fromJson(district),
        coach: NPCDefinition.fromJson(coach),
        knowledge: KnowledgeUnlock.fromJson(knowledge),
      );
    } catch (e) {
      throw ContentLoadException('assets/data', e);
    }
  }
}
