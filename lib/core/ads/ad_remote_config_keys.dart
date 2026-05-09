/// Firebase Remote Config parameter names for ads.
///
/// Create matching parameters in Firebase Console → Remote Config (same keys).
/// Types: Boolean for `ads_*_enabled` / `ads_use_google_sample_units`;
/// Number for `*_seconds` / `*_items`; String for `ad_unit_*` IDs.
///
/// When `ads_use_google_sample_units` is true, official Google sample unit IDs
/// are used and the `ad_unit_*` strings are ignored (good for QA).
/// Set it false in production and paste live AdMob unit IDs per platform.
abstract final class AdRemoteConfigKeys {
  static const String adsMasterEnabled = 'ads_master_enabled';

  static const String adsBannerEnabled = 'ads_banner_enabled';
  static const String adsInterstitialEnabled = 'ads_interstitial_enabled';
  static const String adsNativeEnabled = 'ads_native_enabled';
  static const String adsAppOpenEnabled = 'ads_app_open_enabled';

  /// When true, always use Google sample ad units (testing). When false, use
  /// [adUnit*] strings below (must be non-empty for each shown format).
  static const String adsUseGoogleSampleUnits = 'ads_use_google_sample_units';

  static const String adUnitBannerAndroid = 'ad_unit_banner_android';
  static const String adUnitBannerIos = 'ad_unit_banner_ios';
  static const String adUnitInterstitialAndroid = 'ad_unit_interstitial_android';
  static const String adUnitInterstitialIos = 'ad_unit_interstitial_ios';
  static const String adUnitNativeAndroid = 'ad_unit_native_android';
  static const String adUnitNativeIos = 'ad_unit_native_ios';
  static const String adUnitAppOpenAndroid = 'ad_unit_app_open_android';
  static const String adUnitAppOpenIos = 'ad_unit_app_open_ios';

  /// Minimum seconds between interstitial impressions (global throttle).
  static const String interstitialMinIntervalSeconds =
      'interstitial_min_interval_seconds';

  /// Minimum seconds between app-open impressions (foreground resumes).
  static const String appOpenMinIntervalSeconds =
      'app_open_min_interval_seconds';

  /// Insert native ad row after N real list items (expenses / incomes tabs).
  static const String nativeListInsertAfterItems =
      'native_list_insert_after_items';
}
