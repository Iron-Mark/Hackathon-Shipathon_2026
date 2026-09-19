// SaveGame <-> JSON. Persists IDs and progression only, never static content.
import 'dart:convert';

import '../domain/player.dart';

class SaveCorruptException implements Exception {
  SaveCorruptException(this.message);
  final String message;
  @override
  String toString() => 'Save could not be read: $message';
}

class SaveCodec {
  const SaveCodec();

  Map<String, dynamic> toJson(SaveGame save) {
    final p = save.player;
    return {
      'schemaVersion': save.schemaVersion,
      'player': {
        'playerId': p.playerId,
        'level': p.level,
        'xp': p.xp,
        'condition': {
          'hydration': p.condition.hydration,
          'fatigue': p.condition.fatigue,
        },
        'discoveredExerciseIds': p.discoveredExerciseIds.toList()..sort(),
        'unlockedCodexIds': p.unlockedCodexIds.toList()..sort(),
        'unlockedKnowledgeIds': p.unlockedKnowledgeIds.toList()..sort(),
        'questProgress': {
          for (final q in p.questProgress.values)
            q.questId: {
              'state': q.state.name,
              'objectiveProgress': q.objectiveProgress,
              'rewardClaimed': q.rewardClaimed,
            },
        },
      },
      'selection': save.selection.exerciseIds,
      'settings': {
        'audioVolume': save.settings.audioVolume,
        'reducedMotion': save.settings.reducedMotion,
        'graphicsQuality': save.settings.graphicsQuality,
        'controlHints': save.settings.controlHints,
        'textScale': save.settings.textScale,
      },
    };
  }

  String encode(SaveGame save) => jsonEncode(toJson(save));

  SaveGame decode(String source) {
    final Object? raw;
    try {
      raw = jsonDecode(source);
    } catch (e) {
      throw SaveCorruptException('invalid JSON');
    }
    if (raw is! Map<String, dynamic>) {
      throw SaveCorruptException('root is not an object');
    }
    return fromJson(raw);
  }

  SaveGame fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'];
    if (version is! int) throw SaveCorruptException('missing schemaVersion');
    if (version > SaveGame.currentSchemaVersion) {
      throw SaveCorruptException('schemaVersion $version is newer than app');
    }
    // Migrations for older versions go here; version 1 is the first schema.
    try {
      final p = json['player'] as Map<String, dynamic>;
      final c = p['condition'] as Map<String, dynamic>;
      final quests = (p['questProgress'] as Map<String, dynamic>? ?? {}).map((
        id,
        v,
      ) {
        final q = v as Map<String, dynamic>;
        return MapEntry(
          id,
          QuestProgress(
            questId: id,
            state: QuestState.values.byName(q['state'] as String),
            objectiveProgress: (q['objectiveProgress'] as Map<String, dynamic>)
                .map((k, v) => MapEntry(k, v as int)),
            rewardClaimed: q['rewardClaimed'] as bool,
          ),
        );
      });
      final s = json['settings'] as Map<String, dynamic>? ?? {};
      return SaveGame(
        schemaVersion: version,
        player: PlayerProfile(
          playerId: p['playerId'] as String? ?? 'local_player',
          xp: p['xp'] as int,
          condition: PlayerCondition(
            hydration: c['hydration'] as int,
            fatigue: c['fatigue'] as int,
          ),
          discoveredExerciseIds: _ids(p['discoveredExerciseIds']),
          unlockedCodexIds: _ids(p['unlockedCodexIds']),
          unlockedKnowledgeIds: _ids(p['unlockedKnowledgeIds']),
          questProgress: quests,
        ),
        selection: WorkoutSelection(
          (json['selection'] as List<dynamic>? ?? []).cast<String>(),
        ),
        settings: GameSettings(
          audioVolume: (s['audioVolume'] as num? ?? 1).toDouble(),
          reducedMotion: s['reducedMotion'] as bool? ?? false,
          graphicsQuality: s['graphicsQuality'] as String? ?? 'medium',
          controlHints: s['controlHints'] as bool? ?? true,
          textScale: (s['textScale'] as num? ?? 1).toDouble(),
        ),
      );
    } catch (e) {
      if (e is SaveCorruptException) rethrow;
      throw SaveCorruptException('$e');
    }
  }

  Set<String> _ids(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<String>().toSet();
}
