import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_remote_snapshot.dart';

/// Single entry point for AdMob + Remote Config driven behaviour.
///
/// Create via [bootstrap] on Android/iOS after [Firebase.initializeApp].
/// Desktop/tests should use [AdsController.disabled] without calling bootstrap.
class AdsController extends ChangeNotifier {
  AdsController._({required bool supported}) : _supported = supported;

  factory AdsController.mobile() => AdsController._(supported: true);

  /// No-op controller for unsupported platforms (desktop / tests).
  factory AdsController.disabled() {
    final c = AdsController._(supported: false);
    c._snapshot = AdsRemoteSnapshot.disabled();
    return c;
  }

  final bool _supported;
  bool _adsRemoved = false;

  AdsRemoteSnapshot _snapshot = AdsRemoteSnapshot.disabled();
  InterstitialAd? _interstitial;
  AppOpenAd? _appOpen;

  DateTime? _lastInterstitialShownAt;
  DateTime? _lastAppOpenShownAt;

  bool _interstitialLoading = false;
  bool _appOpenLoading = false;

  AdsRemoteSnapshot get snapshot => _snapshot;

  bool get isSupported => _supported;

  /// Whether the user has purchased "Remove Ads".
  bool get adsRemoved => _adsRemoved;

  /// Called by [PurchaseProvider] when the user buys "Remove Ads".
  void disableAllAds() {
    _adsRemoved = true;
    _interstitial?.dispose();
    _interstitial = null;
    _appOpen?.dispose();
    _appOpen = null;
    notifyListeners();
  }

  /// Adaptive banner slot reads this.
  String? get bannerUnitIdOrNull =>
      (_adsRemoved || !_snapshot.showBanner) ? null : _snapshot.bannerUnitId;

  String? get nativeUnitIdOrNull =>
      (_adsRemoved || !_snapshot.showNative) ? null : _snapshot.nativeUnitId;

  int get nativeInsertAfterItems => _snapshot.nativeListInsertAfterItems;

  Future<void> bootstrap() async {
    if (!_supported) {
      notifyListeners();
      return;
    }

    debugPrint('[ExpenseAds] bootstrap() start');
    try {
      final app = Firebase.app();
      debugPrint(
        '[ExpenseAds] Firebase default app OK — ${app.name} '
        'projectId=${app.options.projectId}',
      );
    } catch (e, st) {
      debugPrint('[ExpenseAds] Firebase.defaultApp missing: $e\n$st');
      _snapshot = AdsRemoteSnapshot.disabled();
      notifyListeners();
      return;
    }

    final rc = FirebaseRemoteConfig.instance;
    try {
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 12),
        ),
      );
      await rc.setDefaults(AdsRemoteSnapshot.firebaseDefaults());
      try {
        await rc.fetchAndActivate();
      } catch (e) {
        debugPrint('[ExpenseAds] Remote Config fetch failed (defaults apply): $e');
      }
      _snapshot = AdsRemoteSnapshot.fromRemoteConfig(
        rc,
        isAndroid: Platform.isAndroid,
      );
      debugPrint(
        '[ExpenseAds] RC resolved → master=${_snapshot.masterEnabled} '
        'use_sample_units=${_snapshot.useGoogleSampleUnits} '
        'banner=${_snapshot.bannerEnabled}(${_snapshot.bannerUnitId.isNotEmpty}, '
        '${_snapshot.bannerUnitId.length}c) '
        'interstitial=${_snapshot.interstitialEnabled}'
        '(${_snapshot.interstitialUnitId.isNotEmpty}) '
        'native=${_snapshot.nativeEnabled}(${_snapshot.nativeUnitId.isNotEmpty}) '
        'app_open=${_snapshot.appOpenEnabled}(${_snapshot.appOpenUnitId.isNotEmpty})',
      );
    } catch (e, st) {
      debugPrint('[ExpenseAds] Remote Config setup failed: $e\n$st');
      _snapshot = AdsRemoteSnapshot.disabled();
    }

    try {
      final initResponse = await MobileAds.instance.initialize();
      debugPrint(
        '[ExpenseAds] MobileAds.initialize OK — '
        'ads_master=${_snapshot.masterEnabled} '
        'sample_units=${_snapshot.useGoogleSampleUnits}',
      );
      initResponse.adapterStatuses.forEach((adapter, status) {
        debugPrint(
          '[ExpenseAds] adapter "$adapter" → '
          'state=${status.state} ${status.description}',
        );
      });
    } catch (e, st) {
      debugPrint('[ExpenseAds] MobileAds init failed: $e\n$st');
      _snapshot = AdsRemoteSnapshot.disabled();
      notifyListeners();
      return;
    }

    notifyListeners();
    unawaited(preloadInterstitial());
    unawaited(loadAppOpenAd());
  }

  /// Pull latest Remote Config (respects minimum fetch interval outside debug).
  Future<void> refreshRemoteConfig() async {
    if (!_supported) return;
    try {
      await FirebaseRemoteConfig.instance.fetchAndActivate();
      _snapshot = AdsRemoteSnapshot.fromRemoteConfig(
        FirebaseRemoteConfig.instance,
        isAndroid: Platform.isAndroid,
      );
      notifyListeners();
      unawaited(preloadInterstitial());
      unawaited(loadAppOpenAd());
    } catch (e) {
      debugPrint('[ExpenseAds] refreshRemoteConfig: $e');
    }
  }

  Future<void> preloadInterstitial() async {
    if (!_supported || !_snapshot.showInterstitial) {
      _interstitial?.dispose();
      _interstitial = null;
      return;
    }
    if (_interstitial != null || _interstitialLoading) return;
    final id = _snapshot.interstitialUnitId;
    if (id.isEmpty) return;

    _interstitialLoading = true;
    await InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[ExpenseAds] Interstitial load failed: $error');
          _interstitialLoading = false;
          _interstitial = null;
        },
      ),
    );
  }

  /// Call after successful user actions (save expense, export, etc.).
  Future<void> presentInterstitialIfEligible() async {
    if (!_supported || _adsRemoved || !_snapshot.showInterstitial) return;

    final last = _lastInterstitialShownAt;
    final minSec = _snapshot.interstitialMinIntervalSeconds;
    if (last != null &&
        DateTime.now().difference(last).inSeconds < minSec) {
      return;
    }

    var ad = _interstitial;
    if (ad == null) {
      await preloadInterstitial();
      ad = _interstitial;
    }
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (disposed) {
        disposed.dispose();
        _interstitial = null;
        _lastInterstitialShownAt = DateTime.now();
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (disposed, err) {
        debugPrint('[ExpenseAds] Interstitial show failed: $err');
        disposed.dispose();
        _interstitial = null;
        unawaited(preloadInterstitial());
      },
    );

    await ad.show();
  }

  Future<void> loadAppOpenAd() async {
    if (!_supported || !_snapshot.showAppOpen) {
      _appOpen?.dispose();
      _appOpen = null;
      return;
    }
    if (_appOpen != null || _appOpenLoading) return;
    final id = _snapshot.appOpenUnitId;
    if (id.isEmpty) return;

    _appOpenLoading = true;
    await AppOpenAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpen = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[ExpenseAds] AppOpen load failed: $error');
          _appOpenLoading = false;
          _appOpen = null;
        },
      ),
    );
  }

  bool shouldDeferAppOpenForRoute(String path) {
    const blocked = {
      '/login',
      '/onboarding',
      '/terms',
      '/privacy',
    };
    return blocked.contains(path);
  }

  Future<void> maybeShowAppOpen({
    required String routePath,
    required bool lockBlocking,
  }) async {
    if (!_supported || _adsRemoved || !_snapshot.showAppOpen || lockBlocking) return;
    if (shouldDeferAppOpenForRoute(routePath)) return;

    final last = _lastAppOpenShownAt;
    final minSec = _snapshot.appOpenMinIntervalSeconds;
    if (last != null &&
        DateTime.now().difference(last).inSeconds < minSec) {
      return;
    }

    if (_appOpen == null) {
      await loadAppOpenAd();
    }
    final ad = _appOpen;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (disposed) {
        disposed.dispose();
        _lastAppOpenShownAt = DateTime.now();
        unawaited(loadAppOpenAd());
      },
      onAdFailedToShowFullScreenContent: (disposed, err) {
        debugPrint('[ExpenseAds] AppOpen show failed: $err');
        disposed.dispose();
        _appOpen = null;
        unawaited(loadAppOpenAd());
      },
    );

    await ad.show();
    _appOpen = null;
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    _appOpen?.dispose();
    super.dispose();
  }
}
