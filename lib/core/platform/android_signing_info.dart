import 'package:flutter/services.dart';

/// Reads the installed APK signing certificate from Android (Play re-signs the app).
class AndroidSigningInfo {
  static const MethodChannel _channel =
      MethodChannel('com.expenseincome.app/signing');

  static Future<String?> getSigningSha1() async {
    try {
      return await _channel.invokeMethod<String>('getSigningSha1');
    } on PlatformException {
      return null;
    }
  }

  static Future<String?> getSigningSha256() async {
    try {
      return await _channel.invokeMethod<String>('getSigningSha256');
    } on PlatformException {
      return null;
    }
  }
}
