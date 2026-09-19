// Flutter product shell: dependency scope, routing, theme, text scaling.
import 'package:flutter/material.dart';

import '../application/game_session.dart';
import '../features/codex/codex_screen.dart';
import '../features/competition/competition_preview_screen.dart';
import '../features/game/game_screen.dart';
import '../features/map/map_preview_screen.dart';
import '../features/menu/main_menu_screen.dart';
import '../features/monetization/support_screen.dart';
import '../features/quests/quest_log_screen.dart';
import '../features/session/session_builder_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/training/training_screen.dart';
import '../infrastructure/audio.dart';
import '../infrastructure/gpu_watchdog.dart';
import '../infrastructure/host_bridge.dart';
import '../infrastructure/monetization.dart';
import 'theme.dart';

class Routes {
  static const menu = '/';
  static const game = '/game';
  static const codex = '/codex';
  static const quests = '/quests';
  static const session = '/session';
  static const training = '/training';
  static const map = '/map';
  static const arena = '/arena';
  static const settings = '/settings';
  static const support = '/support';
}

/// Provides the application services to the widget tree.
class GameScope extends InheritedWidget {
  const GameScope({
    super.key,
    required this.session,
    required this.monetization,
    required this.audio,
    required this.embed,
    required this.bridge,
    required this.watchdog,
    required super.child,
  });

  final GameSession session;
  final MonetizationService monetization;
  final AudioService audio;
  final EmbedConfig embed;
  final HostBridge bridge;
  final GpuWatchdog watchdog;

  static GameScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameScope>()!;

  static GameSession sessionOf(BuildContext context) => of(context).session;

  @override
  bool updateShouldNotify(GameScope old) =>
      old.session != session || old.monetization != monetization;
}

class IronAscentApp extends StatelessWidget {
  IronAscentApp({
    super.key,
    required this.session,
    required this.monetization,
    required this.audio,
    this.embed = const EmbedConfig(),
    HostBridge? bridge,
    GpuWatchdog? watchdog,
  }) : bridge = bridge ?? _NoBridge(),
       watchdog = watchdog ?? createGpuWatchdog();
  final GameSession session;
  final MonetizationService monetization;
  final AudioService audio;
  final EmbedConfig embed;
  final HostBridge bridge;
  final GpuWatchdog watchdog;

  @override
  Widget build(BuildContext context) {
    return GameScope(
      session: session,
      monetization: monetization,
      audio: audio,
      embed: embed,
      bridge: bridge,
      watchdog: watchdog,
      child: ListenableBuilder(
        listenable: session,
        builder: (context, _) => MaterialApp(
          title: 'IRON ASCENT',
          debugShowCheckedModeBanner: false,
          theme: buildIronTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(session.settings.textScale),
            ),
            child: child!,
          ),
          initialRoute: Routes.menu,
          routes: {
            Routes.menu: (_) => const MainMenuScreen(),
            Routes.game: (_) => const GameScreen(),
            Routes.codex: (_) => const CodexScreen(),
            Routes.quests: (_) => const QuestLogScreen(),
            Routes.session: (_) => const SessionBuilderScreen(),
            Routes.map: (_) => const MapPreviewScreen(),
            Routes.arena: (_) => const CompetitionPreviewScreen(),
            Routes.settings: (_) => const SettingsScreen(),
            Routes.support: (_) => const SupportScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == Routes.training) {
              final exerciseId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => TrainingScreen(exerciseId: exerciseId),
                settings: settings,
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

class _NoBridge extends HostBridge {
  @override
  void post(String type, [Map<String, Object?> data = const {}]) {}
}
