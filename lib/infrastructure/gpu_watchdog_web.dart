import 'dart:js_interop';

import 'package:flutter/foundation.dart';
// The engine keeps its WebGL2 context on a private OffscreenCanvas and has no
// recovery path when the browser drops it; reaching into the shim is the only
// place the loss event can be observed.
// ignore: implementation_imports
import 'package:flutter_scene/src/gpu/web/_gpu.dart' show gpuContext;
import 'package:web/web.dart' as web;

import 'gpu_watchdog.dart';

class _WebGpuWatchdog extends GpuWatchdog {
  @override
  final ValueNotifier<bool> contextLost = ValueNotifier(false);

  bool _installed = false;

  @override
  void install() {
    if (_installed) return;
    _installed = true;
    try {
      final canvas = gpuContext.canvas;
      canvas.addEventListener(
        'webglcontextlost',
        ((web.Event event) {
          event.preventDefault();
          debugPrint('IRON ASCENT: WebGL context lost');
          contextLost.value = true;
        }).toJS,
      );
      canvas.addEventListener(
        'webglcontextrestored',
        ((web.Event event) {
          // Restored contexts come back with no shaders or textures; the
          // reload scheduled by the game screen is still the fix.
          debugPrint('IRON ASCENT: WebGL context restored');
        }).toJS,
      );
    } catch (e) {
      debugPrint('gpu watchdog unavailable: $e');
    }
  }

  @override
  void recover() {
    final current = Uri.parse(web.window.location.href);
    final params = Map<String, String>.from(current.queryParameters)
      ..['resume'] = '1';
    // Drop the route fragment so the menu owns the auto-continue.
    final target = current.replace(queryParameters: params, fragment: '');
    web.window.location.replace(target.toString());
  }
}

GpuWatchdog createPlatformGpuWatchdog() => _WebGpuWatchdog();
