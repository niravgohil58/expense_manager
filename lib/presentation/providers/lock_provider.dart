import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/preferences/app_preferences.dart';

const _kPinSha256 = 'app_pin_sha256_b64';
const _kPinSalt = 'app_pin_salt_b64';

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
  bool _temporarilySuppressed = false;

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

  /// Temporarily suppress lock on pause/resume (e.g. system camera, gallery, file picker, Google sign-in).
  void suppressLockForExternalIntent() {
    _temporarilySuppressed = true;
  }

  /// Re-enable normal lock lifecycle.
  void clearLockSuppression() {
    _temporarilySuppressed = false;
  }

  String _hashWithSalt(String pin, String saltB64) {
    final saltBytes = base64Decode(saltB64);
    final pinBytes = utf8.encode(pin);
    final combined = [...saltBytes, ...pinBytes];
    return base64Encode(sha256.convert(combined).bytes);
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4) throw ArgumentError('PIN too short');
    final rng = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => rng.nextInt(256));
    final saltB64 = base64Encode(saltBytes);

    final hashB64 = _hashWithSalt(pin, saltB64);
    await _secure.write(key: _kPinSalt, value: saltB64);
    await _secure.write(key: _kPinSha256, value: hashB64);
    await _prefs.setAppLockEnabled(true);
    _hasStoredPin = true;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<void> clearPinAndDisable() async {
    await _secure.delete(key: _kPinSha256);
    await _secure.delete(key: _kPinSalt);
    await _prefs.setAppLockEnabled(false);
    _hasStoredPin = false;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secure.read(key: _kPinSha256);
    if (storedHash == null || storedHash.isEmpty) return false;

    final storedSalt = await _secure.read(key: _kPinSalt);
    bool matches = false;

    if (storedSalt != null && storedSalt.isNotEmpty) {
      matches = _hashWithSalt(pin, storedSalt) == storedHash;
    } else {
      // Legacy unsalted hash: verify and seamlessly upgrade to salted hash
      final legacyDigest = sha256.convert(utf8.encode(pin));
      matches = base64Encode(legacyDigest.bytes) == storedHash;
      if (matches) {
        // Upgrade legacy hash in background
        await setPin(pin);
      }
    }

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

    if (_temporarilySuppressed) {
      if (state == AppLifecycleState.resumed) {
        _temporarilySuppressed = false;
      }
      return;
    }

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
