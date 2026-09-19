// MonetizationService boundary. Gameplay only asks whether an entitlement
// exists; the RevenueCat SDK never leaks past this file.
//
// Configuration (never hardcoded):
//   flutter run --dart-define=REVENUECAT_API_KEY=<public sdk key>
//                --dart-define=REVENUECAT_ENTITLEMENT=supporter
// Without a key the service reports a safe unconfigured state and the game
// stays fully playable.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntitlementState {
  const EntitlementState({
    this.premium = false,
    this.loading = false,
    this.configured = false,
    this.purchaseSupported = false,
    this.error,
    this.offeringTitle,
    this.offeringPrice,
    this.refusedPurchases = 0,
  });

  final bool premium, loading, configured, purchaseSupported;
  final String? error, offeringTitle, offeringPrice;

  /// Payment attempts the anti-monetization store has turned away.
  final int refusedPurchases;

  EntitlementState copyWith({
    bool? premium,
    bool? loading,
    bool? configured,
    bool? purchaseSupported,
    String? error,
    bool clearError = false,
    String? offeringTitle,
    String? offeringPrice,
    int? refusedPurchases,
  }) => EntitlementState(
    premium: premium ?? this.premium,
    loading: loading ?? this.loading,
    configured: configured ?? this.configured,
    purchaseSupported: purchaseSupported ?? this.purchaseSupported,
    error: clearError ? null : error ?? this.error,
    offeringTitle: offeringTitle ?? this.offeringTitle,
    offeringPrice: offeringPrice ?? this.offeringPrice,
    refusedPurchases: refusedPurchases ?? this.refusedPurchases,
  );
}

abstract class MonetizationService extends ChangeNotifier {
  EntitlementState get state;

  /// Never throws; failures land in [EntitlementState.error].
  Future<void> initialize();
  Future<void> refresh();
  Future<void> purchaseSupporter();
  Future<void> restorePurchases();

  static const unavailableMessage =
      'Store unavailable right now. Core gameplay is still available.';
}

/// Used when no RevenueCat key is configured for this build: the
/// anti-monetization store. It looks like a store, keeps the full
/// MonetizationService contract, and refuses every payment while showing what
/// hosting has cost so far. (Hackathon category: "Help Apps Lose Money".)
class UnconfiguredMonetizationService extends MonetizationService {
  UnconfiguredMonetizationService({
    this.cachedPremium = false,
    DateTime? launchedAt,
  }) : launchedAt = launchedAt ?? defaultLaunch;

  /// First production deployment on Vercel.
  static final defaultLaunch = DateTime.utc(2026, 9, 19, 4, 58);

  /// Vercel Pro seat, USD 20 / month, at roughly PHP 56.5 per USD.
  static const monthlyCostPhp = 20 * 56.5;

  final bool cachedPremium;
  final DateTime launchedAt;
  EntitlementState _state = const EntitlementState();

  @override
  EntitlementState get state => _state.copyWith(
    premium: cachedPremium,
    configured: false,
    purchaseSupported: true,
  );

  /// Hosting cost accrued since launch, in PHP. Earnings stay at zero.
  double runningCostPhp([DateTime? now]) {
    final elapsed = (now ?? DateTime.now().toUtc()).difference(launchedAt);
    final seconds = elapsed.inMilliseconds / 1000;
    return seconds <= 0 ? 0 : monthlyCostPhp * seconds / (30 * 24 * 3600);
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> refresh() async {}

  /// Declines the payment. Nothing is charged; core gameplay was never gated.
  @override
  Future<void> purchaseSupporter() async {
    _state = _state.copyWith(
      refusedPurchases: _state.refusedPurchases + 1,
      error: 'Payment declined by IRON ASCENT. This app does not take money.',
    );
    notifyListeners();
  }

  @override
  Future<void> restorePurchases() async {
    _state = _state.copyWith(
      error: 'Nothing to restore: nobody has ever been charged.',
    );
    notifyListeners();
  }
}

class RevenueCatMonetizationService extends MonetizationService {
  RevenueCatMonetizationService({
    required this.apiKey,
    this.entitlementId = 'supporter',
    SharedPreferencesAsync? preferences,
  }) : _prefs = preferences ?? SharedPreferencesAsync();

  static const cacheKey = 'iron_ascent.entitlement.premium';

  final String apiKey;
  final String entitlementId;
  final SharedPreferencesAsync _prefs;
  EntitlementState _state = const EntitlementState(loading: true);
  Package? _package;

  @override
  EntitlementState get state => _state;

  void _set(EntitlementState next) {
    _state = next;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    final cached = await _readCache();
    _set(_state.copyWith(premium: cached, loading: true));
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _set(
        _state.copyWith(
          configured: true,
          purchaseSupported: true,
          loading: true,
        ),
      );
      await refresh();
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
      _set(
        _state.copyWith(
          loading: false,
          configured: false,
          purchaseSupported: false,
          error: MonetizationService.unavailableMessage,
        ),
      );
    }
  }

  @override
  Future<void> refresh() async {
    if (!_state.configured) return;
    _set(_state.copyWith(loading: true, clearError: true));
    try {
      final info = await Purchases.getCustomerInfo();
      final premium = info.entitlements.active.containsKey(entitlementId);
      await _writeCache(premium);
      String? title, price;
      try {
        final offerings = await Purchases.getOfferings();
        _package = offerings.current?.availablePackages.firstOrNull;
        title = _package?.storeProduct.title;
        price = _package?.storeProduct.priceString;
      } catch (e) {
        debugPrint('RevenueCat offerings unavailable: $e');
      }
      _set(
        _state.copyWith(
          premium: premium,
          loading: false,
          purchaseSupported: _package != null,
          offeringTitle: title,
          offeringPrice: price,
        ),
      );
    } catch (e) {
      debugPrint('RevenueCat refresh failed: $e');
      _set(
        _state.copyWith(
          loading: false,
          error: MonetizationService.unavailableMessage,
        ),
      );
    }
  }

  @override
  Future<void> purchaseSupporter() async {
    final package = _package;
    if (!_state.configured || package == null) {
      _set(_state.copyWith(error: MonetizationService.unavailableMessage));
      return;
    }
    _set(_state.copyWith(loading: true, clearError: true));
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      final premium = result.customerInfo.entitlements.active.containsKey(
        entitlementId,
      );
      await _writeCache(premium);
      _set(_state.copyWith(premium: premium, loading: false));
    } catch (e) {
      debugPrint('RevenueCat purchase failed: $e');
      _set(
        _state.copyWith(
          loading: false,
          error: 'Purchase could not be completed. Nothing was charged.',
        ),
      );
    }
  }

  @override
  Future<void> restorePurchases() async {
    if (!_state.configured) {
      _set(_state.copyWith(error: MonetizationService.unavailableMessage));
      return;
    }
    _set(_state.copyWith(loading: true, clearError: true));
    try {
      final info = await Purchases.restorePurchases();
      final premium = info.entitlements.active.containsKey(entitlementId);
      await _writeCache(premium);
      _set(_state.copyWith(premium: premium, loading: false));
    } catch (e) {
      debugPrint('RevenueCat restore failed: $e');
      _set(
        _state.copyWith(
          loading: false,
          error: 'Restore did not find a supporter purchase.',
        ),
      );
    }
  }

  Future<bool> _readCache() async {
    try {
      return await _prefs.getBool(cacheKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _writeCache(bool premium) async {
    try {
      await _prefs.setBool(cacheKey, premium);
    } catch (_) {}
  }
}

/// Builds the service for this build's configuration.
MonetizationService createMonetizationService() {
  const apiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  const entitlement = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT',
    defaultValue: 'supporter',
  );
  if (apiKey.isEmpty) return UnconfiguredMonetizationService();
  return RevenueCatMonetizationService(
    apiKey: apiKey,
    entitlementId: entitlement,
  );
}
