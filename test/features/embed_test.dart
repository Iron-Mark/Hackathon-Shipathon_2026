import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/infrastructure/host_bridge.dart';

void main() {
  group('embed config', () {
    test('reads ?embed=1 from the page URL, before the hash route', () {
      expect(
        EmbedConfig.fromUri(
          Uri.parse('https://iron-ascent-three.vercel.app/?embed=1#/game'),
        ).embedded,
        isTrue,
      );
      expect(
        EmbedConfig.fromUri(Uri.parse('https://x.test/?embed=true')).embedded,
        isTrue,
      );
      expect(
        EmbedConfig.fromUri(Uri.parse('https://x.test/#/game')).embedded,
        isFalse,
      );
      expect(EmbedConfig.fromUri(Uri.parse('file:///app')).embedded, isFalse);
    });

    test('?resume=1 auto-continues without treating the page as embedded', () {
      final resumed = EmbedConfig.fromUri(
        Uri.parse('https://x.test/?resume=1'),
      );
      expect(resumed.autoResume, isTrue);
      expect(resumed.embedded, isFalse);

      final embedded = EmbedConfig.fromUri(
        Uri.parse('https://x.test/?embed=1'),
      );
      expect(embedded.autoResume, isTrue);

      expect(
        EmbedConfig.fromUri(Uri.parse('https://x.test/')).autoResume,
        isFalse,
      );
    });
  });

  group('host bridge', () {
    test('messages carry a stable source and type', () {
      final bridge = _Capture();
      bridge.ready();
      bridge.questCompleted('build_first_chest_day');
      bridge.progress(level: 2, xp: 129);
      bridge.exit();
      expect(bridge.log, [
        'ready {}',
        'quest_complete {"questId":"build_first_chest_day"}',
        'progress {"level":2,"xp":129}',
        'exit {}',
      ]);
    });
  });
}

class _Capture extends HostBridge {
  final log = <String>[];
  @override
  void post(String type, [Map<String, Object?> data = const {}]) =>
      log.add('$type ${jsonEncode(data)}');
}
