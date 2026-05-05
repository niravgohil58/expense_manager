import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys and typed access for app-wide preferences (theme, currency, security).
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String keyThemeMode = 'app_theme_mode';
  static const String keyCurrencyCode = 'app_currency_code';
  static const String keyAppLockEnabled = 'app_lock_enabled';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyPrefsSchema = 'prefs_schema_v4';

  /// Run once after [SharedPreferences.getInstance] before constructing [AppPreferences].
  static Future<void> migrateInstallPrefs(SharedPreferences p) async {
    if (p.getBool(keyPrefsSchema) == true) return;
    final upgradingUser = p.containsKey(keyThemeMode) ||
        p.containsKey(keyCurrencyCode);
    if (upgradingUser) {
      await p.setBool(keyOnboardingCompleted, true);
    }
    await p.setBool(keyPrefsSchema, true);
  }

  static const String themeSystem = 'system';
  static const String themeLight = 'light';
  static const String themeDark = 'dark';

  static const String defaultCurrencyCode = 'INR';

  ThemeMode get themeMode {
    switch (_prefs.getString(keyThemeMode)) {
      case themeLight:
        return ThemeMode.light;
      case themeDark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => themeLight,
      ThemeMode.dark => themeDark,
      ThemeMode.system => themeSystem,
    };
    await _prefs.setString(keyThemeMode, value);
  }

  String get currencyCode =>
      _prefs.getString(keyCurrencyCode) ?? defaultCurrencyCode;

  Future<void> setCurrencyCode(String code) async {
    await _prefs.setString(keyCurrencyCode, code);
  }

  bool get appLockEnabled => _prefs.getBool(keyAppLockEnabled) ?? false;

  Future<void> setAppLockEnabled(bool enabled) async {
    await _prefs.setBool(keyAppLockEnabled, enabled);
  }

  bool get onboardingCompleted =>
      _prefs.getBool(keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(keyOnboardingCompleted, value);
  }
}
