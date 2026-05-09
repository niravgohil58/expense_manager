import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'ad_remote_config_keys.dart';
import 'google_sample_ad_units.dart';
import 'remote_config_parsing.dart';

/// Parsed Remote Config values + resolved AdMob unit IDs for the current OS.
class AdsRemoteSnapshot {
  const AdsRemoteSnapshot({
    required this.masterEnabled,
    required this.bannerEnabled,
    required this.interstitialEnabled,
    required this.nativeEnabled,
    required this.appOpenEnabled,
    required this.useGoogleSampleUnits,
    required this.interstitialMinIntervalSeconds,
    required this.appOpenMinIntervalSeconds,
    required this.nativeListInsertAfterItems,
    required this.bannerUnitId,
    required this.interstitialUnitId,
    required this.nativeUnitId,
    required this.appOpenUnitId,
  });

  final bool masterEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final bool nativeEnabled;
  final bool appOpenEnabled;
  final bool useGoogleSampleUnits;

  final int interstitialMinIntervalSeconds;
  final int appOpenMinIntervalSeconds;
  final int nativeListInsertAfterItems;

  /// Empty string means “do not show this format”.
  final String bannerUnitId;
  final String interstitialUnitId;
  final String nativeUnitId;
  final String appOpenUnitId;

  bool get showBanner =>
      masterEnabled && bannerEnabled && bannerUnitId.isNotEmpty;

  bool get showInterstitial =>
      masterEnabled && interstitialEnabled && interstitialUnitId.isNotEmpty;

  bool get showNative =>
      masterEnabled && nativeEnabled && nativeUnitId.isNotEmpty;

  bool get showAppOpen =>
      masterEnabled && appOpenEnabled && appOpenUnitId.isNotEmpty;

  static Map<String, dynamic> firebaseDefaults() => {
        AdRemoteConfigKeys.adsMasterEnabled: true,
        AdRemoteConfigKeys.adsBannerEnabled: true,
        AdRemoteConfigKeys.adsInterstitialEnabled: true,
        AdRemoteConfigKeys.adsNativeEnabled: true,
        AdRemoteConfigKeys.adsAppOpenEnabled: true,
        AdRemoteConfigKeys.adsUseGoogleSampleUnits: true,
        AdRemoteConfigKeys.adUnitBannerAndroid: '',
        AdRemoteConfigKeys.adUnitBannerIos: '',
        AdRemoteConfigKeys.adUnitInterstitialAndroid: '',
        AdRemoteConfigKeys.adUnitInterstitialIos: '',
        AdRemoteConfigKeys.adUnitNativeAndroid: '',
        AdRemoteConfigKeys.adUnitNativeIos: '',
        AdRemoteConfigKeys.adUnitAppOpenAndroid: '',
        AdRemoteConfigKeys.adUnitAppOpenIos: '',
        AdRemoteConfigKeys.interstitialMinIntervalSeconds: 120,
        AdRemoteConfigKeys.appOpenMinIntervalSeconds: 14400,
        AdRemoteConfigKeys.nativeListInsertAfterItems: 6,
      };

  /// Used when ads are not supported (desktop) or Firebase never initialises.
  factory AdsRemoteSnapshot.disabled() => const AdsRemoteSnapshot(
        masterEnabled: false,
        bannerEnabled: false,
        interstitialEnabled: false,
        nativeEnabled: false,
        appOpenEnabled: false,
        useGoogleSampleUnits: true,
        interstitialMinIntervalSeconds: 999999,
        appOpenMinIntervalSeconds: 999999,
        nativeListInsertAfterItems: 999,
        bannerUnitId: '',
        interstitialUnitId: '',
        nativeUnitId: '',
        appOpenUnitId: '',
      );

  factory AdsRemoteSnapshot.fromRemoteConfig(
    FirebaseRemoteConfig rc, {
    required bool isAndroid,
  }) {
    bool flag(String k, {bool fallback = false}) =>
        rcReadBool(rc, k, fallback);

    int num(String k, int fallback) => rcReadInt(rc, k, fallback);

    String str(String k) {
      try {
        return rc.getString(k).trim();
      } catch (_) {
        return '';
      }
    }

    final master = flag(AdRemoteConfigKeys.adsMasterEnabled, fallback: true);
    final bannerOn = flag(AdRemoteConfigKeys.adsBannerEnabled, fallback: true);
    final interstitialOn =
        flag(AdRemoteConfigKeys.adsInterstitialEnabled, fallback: true);
    final nativeOn = flag(AdRemoteConfigKeys.adsNativeEnabled, fallback: true);
    final appOpenOn =
        flag(AdRemoteConfigKeys.adsAppOpenEnabled, fallback: true);
    final useSample =
        flag(AdRemoteConfigKeys.adsUseGoogleSampleUnits, fallback: true);

    final minInterstitial = num(
      AdRemoteConfigKeys.interstitialMinIntervalSeconds,
      120,
    ).clamp(30, 86400);
    final minAppOpen = num(
      AdRemoteConfigKeys.appOpenMinIntervalSeconds,
      14400,
    ).clamp(60, 864000);
    final nativeAfter = num(
      AdRemoteConfigKeys.nativeListInsertAfterItems,
      6,
    ).clamp(1, 100);

    String resolveUnit({
      required bool formatEnabled,
      required String androidKey,
      required String iosKey,
      required String Function(bool isAndroid) sampleId,
      required String debugLabel,
    }) {
      if (!master || !formatEnabled) return '';
      if (useSample) return sampleId(isAndroid);

      var id = isAndroid ? str(androidKey) : str(iosKey);
      if (id.isEmpty) {
        debugPrint(
          'Ads RC: "$debugLabel" unit ID empty while '
          'ads_use_google_sample_units=false — using Google sample ID.',
        );
        id = sampleId(isAndroid);
      }
      return id;
    }

    final bannerId = resolveUnit(
      formatEnabled: bannerOn,
      androidKey: AdRemoteConfigKeys.adUnitBannerAndroid,
      iosKey: AdRemoteConfigKeys.adUnitBannerIos,
      sampleId: GoogleSampleAdUnits.banner,
      debugLabel: 'banner',
    );
    final interstitialId = resolveUnit(
      formatEnabled: interstitialOn,
      androidKey: AdRemoteConfigKeys.adUnitInterstitialAndroid,
      iosKey: AdRemoteConfigKeys.adUnitInterstitialIos,
      sampleId: GoogleSampleAdUnits.interstitial,
      debugLabel: 'interstitial',
    );
    final nativeId = resolveUnit(
      formatEnabled: nativeOn,
      androidKey: AdRemoteConfigKeys.adUnitNativeAndroid,
      iosKey: AdRemoteConfigKeys.adUnitNativeIos,
      sampleId: GoogleSampleAdUnits.nativeAdvanced,
      debugLabel: 'native',
    );
    final appOpenId = resolveUnit(
      formatEnabled: appOpenOn,
      androidKey: AdRemoteConfigKeys.adUnitAppOpenAndroid,
      iosKey: AdRemoteConfigKeys.adUnitAppOpenIos,
      sampleId: GoogleSampleAdUnits.appOpen,
      debugLabel: 'app_open',
    );

    return AdsRemoteSnapshot(
      masterEnabled: master,
      bannerEnabled: bannerOn,
      interstitialEnabled: interstitialOn,
      nativeEnabled: nativeOn,
      appOpenEnabled: appOpenOn,
      useGoogleSampleUnits: useSample,
      interstitialMinIntervalSeconds: minInterstitial,
      appOpenMinIntervalSeconds: minAppOpen,
      nativeListInsertAfterItems: nativeAfter,
      bannerUnitId: bannerId,
      interstitialUnitId: interstitialId,
      nativeUnitId: nativeId,
      appOpenUnitId: appOpenId,
    );
  }
}
