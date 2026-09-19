// Host-app bridge for embedded builds (e.g. a FlutterFlow WebView / iframe).
// On the web it posts small JSON messages to the parent window; elsewhere it
// is a no-op. Gameplay never depends on it.
import 'host_bridge_stub.dart'
    if (dart.library.js_interop) 'host_bridge_web.dart';

class EmbedConfig {
  const EmbedConfig({this.embedded = false});

  /// Reads `?embed=1` from the page URL (query string, before the `#` route).
  factory EmbedConfig.fromUri(Uri uri) {
    final value = uri.queryParameters['embed'];
    return EmbedConfig(embedded: value == '1' || value == 'true');
  }

  final bool embedded;
}

abstract class HostBridge {
  /// Emits `{"source":"iron-ascent","type":...}` to the host if one exists.
  void post(String type, [Map<String, Object?> data = const {}]);

  void ready() => post('ready');
  void exit() => post('exit');
  void questCompleted(String questId) =>
      post('quest_complete', {'questId': questId});
  void progress({required int level, required int xp}) =>
      post('progress', {'level': level, 'xp': xp});
}

HostBridge createHostBridge() => createPlatformHostBridge();
