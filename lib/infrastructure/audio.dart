// Audio adapter. Maps domain events to the generated cue set and respects
// the audio volume setting. Every failure is swallowed: audio never blocks
// gameplay (autoplay policies, missing codecs, headless environments).
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../application/game_session.dart';
import '../domain/events.dart';

enum GameSound {
  uiConfirm('ui_confirm'),
  discovery('discovery'),
  repClean('rep_clean'),
  repGood('rep_good'),
  repRough('rep_rough'),
  repMiss('rep_miss'),
  water('water'),
  recover('recover'),
  questComplete('quest_complete');

  const GameSound(this.file);
  final String file;
  String get asset => 'audio/$file.wav';
}

class AudioService {
  AudioService({double Function()? volume}) : _volume = volume ?? (() => 1.0);

  final double Function() _volume;
  final List<AudioPlayer> _pool = [];
  AudioPlayer? _ambience;
  StreamSubscription<GameEvent>? _events;
  bool _disabled = false;

  /// Plays cues for the events a session emits.
  void bind(GameSession session) {
    _events?.cancel();
    _events = session.events.listen(_onEvent);
  }

  void _onEvent(GameEvent event) {
    switch (event) {
      case ExerciseDiscovered():
        play(GameSound.discovery);
      case QuestCompleted():
        play(GameSound.questComplete);
      case QuestStarted():
      case QuestObjectiveCompleted():
      case NPCInteracted():
        play(GameSound.uiConfirm);
      case WaterConsumed():
        play(GameSound.water);
      case RecoveryPerformed():
        play(GameSound.recover);
      default:
        break;
    }
  }

  Future<void> play(GameSound sound) async {
    final volume = _volume();
    if (_disabled || volume <= 0) return;
    try {
      final player = _pool.length < 6
          ? (AudioPlayer()..setReleaseMode(ReleaseMode.stop))
          : _pool.removeAt(0);
      _pool.add(player);
      await player.stop();
      await player.play(AssetSource(sound.asset), volume: volume * 0.8);
    } catch (e) {
      debugPrint('audio unavailable: $e');
      _disabled = true;
    }
  }

  Future<void> startAmbience() async {
    final volume = _volume();
    if (_disabled || volume <= 0 || _ambience != null) return;
    try {
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
      _ambience = player;
      await player.play(
        AssetSource('audio/ambience.wav'),
        volume: volume * 0.35,
      );
    } catch (e) {
      debugPrint('ambience unavailable: $e');
      _ambience = null;
    }
  }

  Future<void> stopAmbience() async {
    final player = _ambience;
    _ambience = null;
    try {
      await player?.stop();
      await player?.dispose();
    } catch (_) {}
  }

  /// Applies a volume change to the running ambience loop.
  Future<void> refreshVolume() async {
    try {
      await _ambience?.setVolume(_volume() * 0.35);
    } catch (_) {}
  }

  void dispose() {
    _events?.cancel();
    stopAmbience();
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
  }
}
