import 'package:flutter/foundation.dart';

import 'gpu_watchdog.dart';

class _NoopGpuWatchdog extends GpuWatchdog {
  @override
  final ValueNotifier<bool> contextLost = ValueNotifier(false);

  @override
  void install() {}

  @override
  void recover() {}
}

GpuWatchdog createPlatformGpuWatchdog() => _NoopGpuWatchdog();
