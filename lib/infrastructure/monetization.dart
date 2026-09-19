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
  });

  final bool premium, loading, configured, purchaseSupported;
  final String? error, offeringTitle, offeringPrice;

  EntitlementState copyWith({
    bool? premium,
    bool? loading,
    bool? configured,
    bool? purchaseSupported,
    String? error,
    bool clearError = false,
    String? offeringTitle,
    String? offeringPrice,
  }) => EntitlementState(
    premium: premium ?? this.premium,
    loading: loading ?? this.loading,
    configured: configured ?? this.configured,
    purchaseSupported: purchaseSupported ?? this.purchaseSupported,
    error: clearError ? null : error ?? this.error,
    offeringTitle: offeringTitle ?? this.offeringTitle,
    offeringPrice: offeringPrice ?? this.offeringPrice,
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

/// Used when no RevenueCat key is configured for this build.
class UnconfiguredMonetizationService extends MonetizationService {
  UnconfiguredMonetizationService({this.cachedPremium = false});
  final bool cachedPremium;

  @override
  EntitlementState get state => EntitlementState(
    premium: cachedPremium,
    configured: false,
    error: 'Store not configured for this build.',
  );

  @override
  Future<void> initialize() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> purchaseSupporter() async {}
  @override
  Future<void> restorePurchases() async {}
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
