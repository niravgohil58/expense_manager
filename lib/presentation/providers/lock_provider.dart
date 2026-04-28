import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/preferences/app_preferences.dart';

const _kPinSha256 = 'app_pin_sha256_b64';

/// Stores a salted PIN hash in secure storage and manages lock lifecycle.
class LockProvider extends ChangeNotifier with WidgetsBindingObserver {
  LockProvider(this._prefs) {
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  final AppPreferences _prefs;
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  bool _bootstrapDone = false;
  bool _sessionUnlocked = true;
  bool _lockOnResume = false;

  /// Whether PIN hash exists in secure storage.
  bool _hasStoredPin = false;

  bool get sessionUnlocked => _sessionUnlocked;
  bool get needsLockOverlay =>
      _bootstrapDone &&
      _prefs.appLockEnabled &&
      _hasStoredPin &&
      !_sessionUnlocked;

  Future<void> _bootstrap() async {
    try {
      final v = await _secure.read(key: _kPinSha256);
      _hasStoredPin = v != null && v.isNotEmpty;
      if (_prefs.appLockEnabled && _hasStoredPin) {
        _sessionUnlocked = false;
      }
    } finally {
      _bootstrapDone = true;
      notifyListeners();
    }
  }

  Future<bool> hasStoredPin() async {
    final v = await _secure.read(key: _kPinSha256);
    _hasStoredPin = v != null && v.isNotEmpty;
    return _hasStoredPin;
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4) throw ArgumentError('PIN too short');
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    await _secure.write(key: _kPinSha256, value: base64Encode(digest.bytes));
    await _prefs.setAppLockEnabled(true);
    _hasStoredPin = true;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<void> clearPinAndDisable() async {
    await _secure.delete(key: _kPinSha256);
    await _prefs.setAppLockEnabled(false);
    _hasStoredPin = false;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _kPinSha256);
    if (stored == null || stored.isEmpty) return false;
    final digest = sha256.convert(utf8.encode(pin));
    final matches = base64Encode(digest.bytes) == stored;
    if (matches) {
      _sessionUnlocked = true;
      _lockOnResume = false;
      notifyListeners();
    }
    return matches;
  }

  void lockNow() {
    if (_prefs.appLockEnabled && _hasStoredPin) {
      _sessionUnlocked = false;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_prefs.appLockEnabled || !_hasStoredPin) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lockOnResume = true;
    }
    if (state == AppLifecycleState.resumed && _lockOnResume) {
      _sessionUnlocked = false;
      _lockOnResume = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
