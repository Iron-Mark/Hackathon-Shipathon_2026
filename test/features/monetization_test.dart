import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/infrastructure/monetization.dart';

void main() {
  group('anti-monetization store', () {
    test('refuses every payment and never grants premium', () async {
      final store = UnconfiguredMonetizationService();
      var notified = 0;
      store.addListener(() => notified++);
      await store.initialize();
      expect(store.state.configured, isFalse);
      expect(store.state.purchaseSupported, isTrue);
      await store.purchaseSupporter();
      await store.purchaseSupporter();
      expect(store.state.refusedPurchases, 2);
      expect(store.state.premium, isFalse);
      expect(store.state.error, contains('does not take money'));
      await store.restorePurchases();
      expect(store.state.error, contains('Nothing to restore'));
      expect(notified, 3);
    });

    test('hosting cost accrues from launch while earnings stay zero', () {
      final launch = DateTime.utc(2026, 9, 19);
      final store = UnconfiguredMonetizationService(launchedAt: launch);
      expect(store.runningCostPhp(launch), 0);
      expect(store.runningCostPhp(launch.subtract(const Duration(days: 1))), 0);
      final month = store.runningCostPhp(launch.add(const Duration(days: 30)));
      expect(
        month,
        closeTo(UnconfiguredMonetizationService.monthlyCostPhp, 1e-6),
      );
    });
  });
}
