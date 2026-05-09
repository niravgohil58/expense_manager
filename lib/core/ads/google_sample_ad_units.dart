import 'dart:io';

/// Official Google sample IDs for development / policy-safe testing.
///
/// Application IDs (manifest / Info.plist) must also use sample values until
/// you publish with your AdMob app IDs.
abstract final class GoogleSampleAdUnits {
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static String banner(bool isAndroid) => isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String interstitial(bool isAndroid) => isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static String nativeAdvanced(bool isAndroid) => isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  static String appOpen(bool isAndroid) => isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/5575463023';

  static bool get runningOnAndroid => Platform.isAndroid;
}
