import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'application/game_session.dart';
import 'data/content_repository.dart';
import 'data/save_repositories.dart';
import 'domain/events.dart';
import 'infrastructure/audio.dart';
import 'infrastructure/host_bridge.dart';
import 'infrastructure/monetization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('IRON ASCENT error: ${details.exceptionAsString()}');
  };

  final session = GameSession(
    contentRepository: ContentRepository(),
    saveRepository: SharedPreferencesSaveRepository(),
  );
  final monetization = createMonetizationService();
  final audio = AudioService(volume: () => session.settings.audioVolume)
    ..bind(session);

  // Embedded hosts (FlutterFlow WebView, iframe) load `?embed=1` and receive
  // lifecycle messages through the bridge.
  final embed = EmbedConfig.fromUri(Uri.base);
  final bridge = createHostBridge();
  session.events.listen((event) {
    if (event is QuestCompleted) bridge.questCompleted(event.questId);
    if (event is SaveRequested && session.isPlaying) {
      bridge.progress(level: session.player.level, xp: session.player.xp);
    }
  });

  // Content and save load in parallel with the first frame; the menu shows a
  // loading state until the session is ready. Store initialization never
  // blocks startup and its failures stay inside the service.
  unawaited(session.initialize().then((_) => bridge.ready()));
  unawaited(monetization.initialize());

  runApp(
    IronAscentApp(
      session: session,
      monetization: monetization,
      audio: audio,
      embed: embed,
      bridge: bridge,
    ),
  );
}
