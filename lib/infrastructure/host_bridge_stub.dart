import 'host_bridge.dart';

class _NoopHostBridge extends HostBridge {
  @override
  void post(String type, [Map<String, Object?> data = const {}]) {}
}

HostBridge createPlatformHostBridge() => _NoopHostBridge();
