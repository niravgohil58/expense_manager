import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../preferences/app_preferences.dart';
import 'purchase_constants.dart';

/// Low-level wrapper around [InAppPurchase].
///
/// Manages store connection, product queries, purchasing, restoring,
/// and persisting the "ads removed" flag into [AppPreferences].
class PurchaseService {
  PurchaseService({required AppPreferences appPreferences})
      : _prefs = appPreferences;

  final AppPreferences _prefs;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Resolved product from the store (null until [init] completes).
  ProductDetails? removeAdsProduct;

  /// Broadcast stream that fires `true` whenever ads are successfully removed.
  final StreamController<bool> _purchaseResultController =
      StreamController<bool>.broadcast();
  Stream<bool> get purchaseResultStream => _purchaseResultController.stream;

  /// Whether the store is available on this platform.
  bool _storeAvailable = false;
  bool get storeAvailable => _storeAvailable;

  /// Connect to the store and query the "remove_ads" product.
  ///
  /// Safe to call on unsupported platforms (desktop) — silently no-ops.
  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('[PurchaseService] init: unsupported platform, skipping.');
      return;
    }

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      debugPrint('[PurchaseService] init: store not available.');
      return;
    }

    // Listen to purchase updates.
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        debugPrint('[PurchaseService] purchaseStream error: $error');
      },
    );

    // Query product details.
    final response = await _iap.queryProductDetails(
      PurchaseConstants.productIds,
    );
    if (response.error != null) {
      debugPrint(
        '[PurchaseService] queryProductDetails error: ${response.error}',
      );
    }
    if (response.productDetails.isNotEmpty) {
      removeAdsProduct = response.productDetails.firstWhere(
        (p) => p.id == PurchaseConstants.removeAdsProductId,
        orElse: () => response.productDetails.first,
      );
      debugPrint(
        '[PurchaseService] product found: '
        '${removeAdsProduct!.id} — ${removeAdsProduct!.price}',
      );
    } else {
      debugPrint('[PurchaseService] no products found in store.');
    }
  }

  /// Initiate purchase of the "Remove Ads" product.
  Future<bool> buyRemoveAds() async {
    final product = removeAdsProduct;
    if (product == null) {
      debugPrint('[PurchaseService] buyRemoveAds: product not loaded.');
      return false;
    }

    final param = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('[PurchaseService] buyRemoveAds error: $e');
      return false;
    }
  }

  /// Trigger a restore of past purchases.
  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      debugPrint(
        '[PurchaseService] update: '
        'product=${purchase.productID} status=${purchase.status}',
      );

      if (purchase.productID != PurchaseConstants.removeAdsProductId) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint(
            '[PurchaseService] purchase error: ${purchase.error?.message}',
          );
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          debugPrint('[PurchaseService] purchase pending…');
          break;
        case PurchaseStatus.canceled:
          debugPrint('[PurchaseService] purchase cancelled.');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // Persist the ad-free state.
    await _prefs.setAdsRemoved(true);
    _purchaseResultController.add(true);
    debugPrint('[PurchaseService] ads removed — persisted.');

    // Complete the purchase with the store.
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /// Clean up subscriptions.
  void dispose() {
    _sub?.cancel();
    _purchaseResultController.close();
  }
}
