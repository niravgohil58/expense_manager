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

  /// Local weekly reminders (flutter_local_notifications).
  static const String keyRecurringReminderEnabled = 'reminder_recurring_enabled';
  static const String keyRecurringReminderWeekday = 'reminder_recurring_weekday';
  static const String keyRecurringReminderHour = 'reminder_recurring_hour';
  static const String keyRecurringReminderMinute = 'reminder_recurring_minute';
  static const String keyBackupReminderEnabled = 'reminder_backup_enabled';
  static const String keyBackupReminderWeekday = 'reminder_backup_weekday';
  static const String keyBackupReminderHour = 'reminder_backup_hour';
  static const String keyBackupReminderMinute = 'reminder_backup_minute';

  /// IOUs home screen intro panel (user can hide once understood).
  static const String keyIouScreenTipsVisible = 'iou_screen_tips_visible';

  /// User accepted Terms & Privacy (required to finish onboarding).
  static const String keyLegalTermsAccepted = 'legal_terms_accepted_v1';

  /// One-time: existing installs already past onboarding before legal consent existed.
  static const String keyLegalTermsGrandfatherDone =
      'legal_terms_grandfather_v1';

  /// Firebase UID whose offline SQLite data is currently stored on this device.
  static const String keyBoundLocalDataFirebaseUid =
      'bound_local_data_firebase_uid';

  /// User purchased "Remove Ads" in-app product.
  static const String keyAdsRemoved = 'ads_removed';

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

  /// Call on every cold start after [migrateInstallPrefs].
  static Future<void> migrateLegalTermsGrandfather(SharedPreferences p) async {
    if (p.getBool(keyLegalTermsGrandfatherDone) == true) return;
    final onboardDone = p.getBool(keyOnboardingCompleted) ?? false;
    final hasLegalKey = p.containsKey(keyLegalTermsAccepted);
    if (onboardDone && !hasLegalKey) {
      await p.setBool(keyLegalTermsAccepted, true);
    }
    await p.setBool(keyLegalTermsGrandfatherDone, true);
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

  /// [weekday] matches [DateTime.weekday] (Monday = 1 … Sunday = 7).
  bool get recurringReminderEnabled =>
      _prefs.getBool(keyRecurringReminderEnabled) ?? false;

  Future<void> setRecurringReminderEnabled(bool value) async {
    await _prefs.setBool(keyRecurringReminderEnabled, value);
  }

  int get recurringReminderWeekday =>
      _prefs.getInt(keyRecurringReminderWeekday) ?? DateTime.sunday;

  Future<void> setRecurringReminderWeekday(int weekday) async {
    await _prefs.setInt(keyRecurringReminderWeekday, weekday);
  }

  int get recurringReminderHour =>
      _prefs.getInt(keyRecurringReminderHour) ?? 10;

  Future<void> setRecurringReminderHour(int hour) async {
    await _prefs.setInt(keyRecurringReminderHour, hour);
  }

  int get recurringReminderMinute =>
      _prefs.getInt(keyRecurringReminderMinute) ?? 0;

  Future<void> setRecurringReminderMinute(int minute) async {
    await _prefs.setInt(keyRecurringReminderMinute, minute);
  }

  bool get backupReminderEnabled =>
      _prefs.getBool(keyBackupReminderEnabled) ?? false;

  Future<void> setBackupReminderEnabled(bool value) async {
    await _prefs.setBool(keyBackupReminderEnabled, value);
  }

  int get backupReminderWeekday =>
      _prefs.getInt(keyBackupReminderWeekday) ?? DateTime.saturday;

  Future<void> setBackupReminderWeekday(int weekday) async {
    await _prefs.setInt(keyBackupReminderWeekday, weekday);
  }

  int get backupReminderHour =>
      _prefs.getInt(keyBackupReminderHour) ?? 18;

  Future<void> setBackupReminderHour(int hour) async {
    await _prefs.setInt(keyBackupReminderHour, hour);
  }

  int get backupReminderMinute =>
      _prefs.getInt(keyBackupReminderMinute) ?? 0;

  Future<void> setBackupReminderMinute(int minute) async {
    await _prefs.setInt(keyBackupReminderMinute, minute);
  }

  bool get iouScreenTipsVisible =>
      _prefs.getBool(keyIouScreenTipsVisible) ?? true;

  Future<void> setIouScreenTipsVisible(bool visible) async {
    await _prefs.setBool(keyIouScreenTipsVisible, visible);
  }

  bool get legalTermsAccepted =>
      _prefs.getBool(keyLegalTermsAccepted) ?? false;

  Future<void> setLegalTermsAccepted(bool value) async {
    await _prefs.setBool(keyLegalTermsAccepted, value);
  }

  /// Last Firebase account whose ledger rows live in local SQLite (used when switching accounts).
  String? get boundLocalDataFirebaseUid =>
      _prefs.getString(keyBoundLocalDataFirebaseUid);

  Future<void> setBoundLocalDataFirebaseUid(String uid) async {
    await _prefs.setString(keyBoundLocalDataFirebaseUid, uid);
  }

  /// Whether the user has purchased "Remove Ads".
  bool get adsRemoved => _prefs.getBool(keyAdsRemoved) ?? false;

  Future<void> setAdsRemoved(bool value) async {
    await _prefs.setBool(keyAdsRemoved, value);
  }
}
