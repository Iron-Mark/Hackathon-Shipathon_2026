// Watches the renderer's GPU context. Mobile browsers and WebViews drop the
// WebGL context under memory pressure or a GPU reset; the 3D engine keeps
// running but every frame renders empty, which the player sees as the scene
// vanishing behind the backdrop. The only reliable recovery is to reload the
// page and resume the saved game, which this does for web builds. Native
// builds never lose their context, so the watchdog is a no-op there.
import 'package:flutter/foundation.dart';

import 'gpu_watchdog_stub.dart'
    if (dart.library.js_interop) 'gpu_watchdog_web.dart';

abstract class GpuWatchdog {
  /// True once the rendering context has been lost.
  ValueListenable<bool> get contextLost;

  /// Starts listening. Safe to call more than once.
  void install();

  /// Restarts the app straight back into the saved game.
  void recover();
}

GpuWatchdog createGpuWatchdog() => createPlatformGpuWatchdog();
