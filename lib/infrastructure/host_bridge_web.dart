import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'host_bridge.dart';

/// Posts messages to the embedding page (iframe parent or WebView host).
/// A FlutterFlow / native WebView receives them through a JavaScript channel
/// named `IronAscent`; a plain iframe host listens with
/// `window.addEventListener('message', ...)`.
class _WebHostBridge extends HostBridge {
  @override
  void post(String type, [Map<String, Object?> data = const {}]) {
    final payload = jsonEncode({
      'source': 'iron-ascent',
      'type': type,
      ...data,
    });
    try {
      final parent = web.window.parent;
      if (parent != null && parent != web.window) {
        parent.postMessage(payload.toJS, '*'.toJS);
      }
      final channel = web.window.getProperty<JSAny?>('IronAscent'.toJS);
      if (channel != null && channel.isA<JSObject>()) {
        (channel as JSObject).callMethod('postMessage'.toJS, payload.toJS);
      }
    } catch (e) {
      debugPrint('host bridge unavailable: $e');
    }
  }
}

HostBridge createPlatformHostBridge() => _WebHostBridge();
