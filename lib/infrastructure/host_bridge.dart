// Host-app bridge for embedded builds (e.g. a FlutterFlow WebView / iframe).
// On the web it posts small JSON messages to the parent window; elsewhere it
// is a no-op. Gameplay never depends on it.
import 'host_bridge_stub.dart'
    if (dart.library.js_interop) 'host_bridge_web.dart';

class EmbedConfig {
  const EmbedConfig({this.embedded = false, bool resume = false})
    : _resume = resume; // ignore: prefer_initializing_formals

  /// Reads `?embed=1` and `?resume=1` from the page URL (query string, before
  /// the `#` route). `resume` is set by the GPU watchdog when it reloads the
  /// page after a lost rendering context.
  factory EmbedConfig.fromUri(Uri uri) {
    bool flag(String key) {
      final value = uri.queryParameters[key];
      return value == '1' || value == 'true';
    }

    return EmbedConfig(embedded: flag('embed'), resume: flag('resume'));
  }

  final bool embedded;
  final bool _resume;

  /// Skip the title screen and continue the save (or start fresh) at once.
  bool get autoResume => embedded || _resume;
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
