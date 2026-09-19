// Widget-test harness: a session backed by the real content files and an
// in-memory save, wrapped in the app scope and theme.
import 'package:flutter/material.dart';
import 'package:iron_ascent/app/app.dart';
import 'package:iron_ascent/app/theme.dart';
import 'package:iron_ascent/application/game_session.dart';
import 'package:iron_ascent/data/content_repository.dart';
import 'package:iron_ascent/data/save_repositories.dart';
import 'package:iron_ascent/domain/content.dart';
import 'package:iron_ascent/infrastructure/audio.dart';
import 'package:iron_ascent/infrastructure/host_bridge.dart';
import 'package:iron_ascent/infrastructure/monetization.dart';

import 'test_content.dart';

// Content is read synchronously from disk (real I/O never completes inside
// the fake-async zone of testWidgets).
final GameContent testContent = loadTestContent();

Future<GameSession> buildTestSession({bool newGame = true}) async {
  final session = GameSession(
    contentRepository: ContentRepository.preloaded(testContent),
    saveRepository: InMemorySaveRepository(),
  );
  await session.initialize();
  if (newGame) session.startNewGame();
  return session;
}

Widget wrap(
  GameSession session,
  Widget child, {
  Size size = const Size(1280, 800),
}) {
  return GameScope(
    session: session,
    monetization: UnconfiguredMonetizationService(),
    audio: AudioService(volume: () => 0),
    embed: const EmbedConfig(),
    bridge: RecordingHostBridge(),
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(theme: buildIronTheme(), home: child),
    ),
  );
}

class RecordingHostBridge extends HostBridge {
  final List<String> types = [];
  @override
  void post(String type, [Map<String, Object?> data = const {}]) =>
      types.add(type);
}
