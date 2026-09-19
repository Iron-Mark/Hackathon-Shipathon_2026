import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'application/game_session.dart';
import 'data/content_repository.dart';
import 'data/save_repositories.dart';
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

  // Content and save load in parallel with the first frame; the menu shows a
  // loading state until the session is ready. Store initialization never
  // blocks startup and its failures stay inside the service.
  unawaited(session.initialize());
  unawaited(monetization.initialize());

  runApp(IronAscentApp(session: session, monetization: monetization));
}
