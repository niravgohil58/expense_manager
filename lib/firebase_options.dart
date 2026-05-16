// Generated placeholder — replace by running: dart pub global activate flutterfire_cli && flutterfire configure
//
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Android & iOS. Replace with real keys from Firebase Console.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web Firebase options are not configured. Run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is only wired for Android and iOS in this project.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME_ANDROID_API_KEY',
    appId: 'REPLACE_ME_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_ME_SENDER_ID',
    projectId: 'REPLACE_ME_PROJECT_ID',
    storageBucket: 'REPLACE_ME_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_IOS_API_KEY',
    appId: 'REPLACE_ME_IOS_APP_ID',
    messagingSenderId: 'REPLACE_ME_SENDER_ID',
    projectId: 'REPLACE_ME_PROJECT_ID',
    storageBucket: 'REPLACE_ME_PROJECT_ID.appspot.com',
    iosBundleId: 'com.expenseincome.app',
  );
}
