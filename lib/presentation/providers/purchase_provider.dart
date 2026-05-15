import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/ads/ads_controller.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/purchase/purchase_service.dart';

/// Purchase state for the Remove Ads flow.
enum PurchaseState { idle, loading, purchased, error }

/// State management for in-app purchases (specifically "Remove Ads").
class PurchaseProvider extends ChangeNotifier {
  PurchaseProvider({
    required PurchaseService service,
    required AppPreferences prefs,
    required AdsController adsController,
  })  : _service = service,
        _prefs = prefs,
        _adsController = adsController {
    _adsRemoved = _prefs.adsRemoved;
    _purchaseState = _adsRemoved ? PurchaseState.purchased : PurchaseState.idle;

    // Listen for purchase results from the service.
    _sub = _service.purchaseResultStream.listen((success) {
      if (success) {
        _adsRemoved = true;
        _purchaseState = PurchaseState.purchased;
        _adsController.disableAllAds();
        notifyListeners();
      }
    });
  }

  final PurchaseService _service;
  final AppPreferences _prefs;
  final AdsController _adsController;
  StreamSubscription<bool>? _sub;

  bool _adsRemoved = false;
  PurchaseState _purchaseState = PurchaseState.idle;
  String? _errorMessage;

  /// Whether ads have been permanently removed.
  bool get adsRemoved => _adsRemoved;

  /// Current state of the purchase flow.
  PurchaseState get purchaseState => _purchaseState;

  /// Error message from the last failed purchase, if any.
  String? get errorMessage => _errorMessage;

  /// Store product details (price, title). Null if not yet loaded or unavailable.
  ProductDetails? get removeAdsProduct => _service.removeAdsProduct;

  /// Whether the store is available and the feature is usable.
  bool get isAvailable =>
      (Platform.isAndroid || Platform.isIOS) && _service.storeAvailable;

  /// Initiate a purchase of the "Remove Ads" product.
  Future<void> buyRemoveAds() async {
    if (_adsRemoved) return;

    _purchaseState = PurchaseState.loading;
    _errorMessage = null;
    notifyListeners();

    final started = await _service.buyRemoveAds();
    if (!started) {
      _purchaseState = PurchaseState.error;
      _errorMessage = 'Could not start the purchase. '
          'Please check that the product is available in the store.';
      notifyListeners();
    }
    // If started successfully, the result arrives via purchaseResultStream
    // which we handle in the constructor listener.
  }

  /// Restore past purchases (e.g. after reinstall).
  Future<void> restorePurchases() async {
    _purchaseState = PurchaseState.loading;
    _errorMessage = null;
    notifyListeners();

    await _service.restorePurchases();

    // Give the store stream a moment to deliver results.
    await Future.delayed(const Duration(seconds: 2));

    if (!_adsRemoved) {
      _purchaseState = PurchaseState.idle;
      notifyListeners();
    }
  }

  /// Clear a transient error state (e.g. after showing a SnackBar).
  void clearError() {
    _errorMessage = null;
    _purchaseState = _adsRemoved ? PurchaseState.purchased : PurchaseState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
