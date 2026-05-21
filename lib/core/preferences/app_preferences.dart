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

  /// Morning expense reminder.
  static const String keyMorningReminderEnabled = 'reminder_morning_enabled';
  static const String keyMorningReminderHour = 'reminder_morning_hour';
  static const String keyMorningReminderMinute = 'reminder_morning_minute';

  /// Night expense reminder.
  static const String keyNightReminderEnabled = 'reminder_night_enabled';
  static const String keyNightReminderHour = 'reminder_night_hour';
  static const String keyNightReminderMinute = 'reminder_night_minute';

  /// Monthly income reminder (1st of every month).
  static const String keyMonthlyIncomeReminderEnabled = 'reminder_monthly_income_enabled';
  static const String keyMonthlyIncomeReminderHour = 'reminder_monthly_income_hour';
  static const String keyMonthlyIncomeReminderMinute = 'reminder_monthly_income_minute';

  /// Monthly report reminder.
  static const String keyMonthlyReportReminderEnabled = 'reminder_monthly_report_enabled';
  static const String keyMonthlyReportReminderDay = 'reminder_monthly_report_day';
  static const String keyMonthlyReportReminderHour = 'reminder_monthly_report_hour';
  static const String keyMonthlyReportReminderMinute = 'reminder_monthly_report_minute';

  /// Weekly summary reminder.
  static const String keyWeeklySummaryReminderEnabled = 'reminder_weekly_summary_enabled';
  static const String keyWeeklySummaryReminderWeekday = 'reminder_weekly_summary_weekday';
  static const String keyWeeklySummaryReminderHour = 'reminder_weekly_summary_hour';
  static const String keyWeeklySummaryReminderMinute = 'reminder_weekly_summary_minute';

  /// IOU pending reminder.
  static const String keyIouReminderEnabled = 'reminder_iou_enabled';
  static const String keyIouReminderWeekday = 'reminder_iou_weekday';
  static const String keyIouReminderHour = 'reminder_iou_hour';
  static const String keyIouReminderMinute = 'reminder_iou_minute';

  /// Budget exceeded alert.
  static const String keyBudgetAlertEnabled = 'reminder_budget_alert_enabled';

  /// Inactivity reminder.
  static const String keyInactivityReminderEnabled = 'reminder_inactivity_enabled';

  /// Flag to track if we've shown the home screen permission dialog.
  static const String keyHasRequestedNotificationPermission = 'has_requested_notification_permission';

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
      _prefs.getBool(keyRecurringReminderEnabled) ?? true;

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
      _prefs.getBool(keyBackupReminderEnabled) ?? true;

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

  // ── Reminders (Notifications) ───────────────────────────────────────

  bool get hasRequestedNotificationPermission =>
      _prefs.getBool(keyHasRequestedNotificationPermission) ?? false;

  Future<void> setHasRequestedNotificationPermission(bool value) async {
    await _prefs.setBool(keyHasRequestedNotificationPermission, value);
  }

  // ── Morning reminder ────────────────────────────────────────────────

  bool get morningReminderEnabled =>
      _prefs.getBool(keyMorningReminderEnabled) ?? true;

  Future<void> setMorningReminderEnabled(bool value) async {
    await _prefs.setBool(keyMorningReminderEnabled, value);
  }

  int get morningReminderHour =>
      _prefs.getInt(keyMorningReminderHour) ?? 9;

  int get morningReminderMinute =>
      _prefs.getInt(keyMorningReminderMinute) ?? 0;

  Future<void> setMorningReminderHour(int hour) async {
    await _prefs.setInt(keyMorningReminderHour, hour);
  }

  Future<void> setMorningReminderMinute(int minute) async {
    await _prefs.setInt(keyMorningReminderMinute, minute);
  }

  // ── Night reminder ──────────────────────────────────────────────────

  bool get nightReminderEnabled =>
      _prefs.getBool(keyNightReminderEnabled) ?? true;

  Future<void> setNightReminderEnabled(bool value) async {
    await _prefs.setBool(keyNightReminderEnabled, value);
  }

  int get nightReminderHour =>
      _prefs.getInt(keyNightReminderHour) ?? 21;

  int get nightReminderMinute =>
      _prefs.getInt(keyNightReminderMinute) ?? 0;

  Future<void> setNightReminderHour(int hour) async {
    await _prefs.setInt(keyNightReminderHour, hour);
  }

  Future<void> setNightReminderMinute(int minute) async {
    await _prefs.setInt(keyNightReminderMinute, minute);
  }

  // ── Monthly income reminder ─────────────────────────────────────────

  bool get monthlyIncomeReminderEnabled =>
      _prefs.getBool(keyMonthlyIncomeReminderEnabled) ?? true;

  Future<void> setMonthlyIncomeReminderEnabled(bool value) async {
    await _prefs.setBool(keyMonthlyIncomeReminderEnabled, value);
  }

  int get monthlyIncomeReminderHour =>
      _prefs.getInt(keyMonthlyIncomeReminderHour) ?? 10;

  int get monthlyIncomeReminderMinute =>
      _prefs.getInt(keyMonthlyIncomeReminderMinute) ?? 0;

  Future<void> setMonthlyIncomeReminderHour(int hour) async {
    await _prefs.setInt(keyMonthlyIncomeReminderHour, hour);
  }

  Future<void> setMonthlyIncomeReminderMinute(int minute) async {
    await _prefs.setInt(keyMonthlyIncomeReminderMinute, minute);
  }

  // ── Monthly report reminder ─────────────────────────────────────────

  bool get monthlyReportReminderEnabled =>
      _prefs.getBool(keyMonthlyReportReminderEnabled) ?? true;

  Future<void> setMonthlyReportReminderEnabled(bool value) async {
    await _prefs.setBool(keyMonthlyReportReminderEnabled, value);
  }

  int get monthlyReportReminderDay =>
      _prefs.getInt(keyMonthlyReportReminderDay) ?? 28;

  Future<void> setMonthlyReportReminderDay(int day) async {
    await _prefs.setInt(keyMonthlyReportReminderDay, day);
  }

  int get monthlyReportReminderHour =>
      _prefs.getInt(keyMonthlyReportReminderHour) ?? 18;

  int get monthlyReportReminderMinute =>
      _prefs.getInt(keyMonthlyReportReminderMinute) ?? 0;

  Future<void> setMonthlyReportReminderHour(int hour) async {
    await _prefs.setInt(keyMonthlyReportReminderHour, hour);
  }

  Future<void> setMonthlyReportReminderMinute(int minute) async {
    await _prefs.setInt(keyMonthlyReportReminderMinute, minute);
  }

  // ── Weekly summary reminder ─────────────────────────────────────────

  bool get weeklySummaryReminderEnabled =>
      _prefs.getBool(keyWeeklySummaryReminderEnabled) ?? true;

  Future<void> setWeeklySummaryReminderEnabled(bool value) async {
    await _prefs.setBool(keyWeeklySummaryReminderEnabled, value);
  }

  int get weeklySummaryReminderWeekday =>
      _prefs.getInt(keyWeeklySummaryReminderWeekday) ?? DateTime.sunday;

  Future<void> setWeeklySummaryReminderWeekday(int weekday) async {
    await _prefs.setInt(keyWeeklySummaryReminderWeekday, weekday);
  }

  int get weeklySummaryReminderHour =>
      _prefs.getInt(keyWeeklySummaryReminderHour) ?? 19;

  int get weeklySummaryReminderMinute =>
      _prefs.getInt(keyWeeklySummaryReminderMinute) ?? 0;

  Future<void> setWeeklySummaryReminderHour(int hour) async {
    await _prefs.setInt(keyWeeklySummaryReminderHour, hour);
  }

  Future<void> setWeeklySummaryReminderMinute(int minute) async {
    await _prefs.setInt(keyWeeklySummaryReminderMinute, minute);
  }

  // ── IOU pending reminder ────────────────────────────────────────────

  bool get iouReminderEnabled =>
      _prefs.getBool(keyIouReminderEnabled) ?? true;

  Future<void> setIouReminderEnabled(bool value) async {
    await _prefs.setBool(keyIouReminderEnabled, value);
  }

  int get iouReminderWeekday =>
      _prefs.getInt(keyIouReminderWeekday) ?? DateTime.saturday;

  Future<void> setIouReminderWeekday(int weekday) async {
    await _prefs.setInt(keyIouReminderWeekday, weekday);
  }

  int get iouReminderHour =>
      _prefs.getInt(keyIouReminderHour) ?? 11;

  int get iouReminderMinute =>
      _prefs.getInt(keyIouReminderMinute) ?? 0;

  Future<void> setIouReminderHour(int hour) async {
    await _prefs.setInt(keyIouReminderHour, hour);
  }

  Future<void> setIouReminderMinute(int minute) async {
    await _prefs.setInt(keyIouReminderMinute, minute);
  }

  // ── Budget exceeded alert ───────────────────────────────────────────

  bool get budgetAlertEnabled =>
      _prefs.getBool(keyBudgetAlertEnabled) ?? true;

  Future<void> setBudgetAlertEnabled(bool value) async {
    await _prefs.setBool(keyBudgetAlertEnabled, value);
  }

  // ── Inactivity reminder ─────────────────────────────────────────────

  bool get inactivityReminderEnabled =>
      _prefs.getBool(keyInactivityReminderEnabled) ?? true;

  Future<void> setInactivityReminderEnabled(bool value) async {
    await _prefs.setBool(keyInactivityReminderEnabled, value);
  }

  /// Emergency fallback when permission is denied or revoked.
  Future<void> disableAllReminders() async {
    await setMorningReminderEnabled(false);
    await setNightReminderEnabled(false);
    await setMonthlyIncomeReminderEnabled(false);
    await setMonthlyReportReminderEnabled(false);
    await setWeeklySummaryReminderEnabled(false);
    await setRecurringReminderEnabled(false);
    await setBackupReminderEnabled(false);
    await setIouReminderEnabled(false);
    await setBudgetAlertEnabled(false);
    await setInactivityReminderEnabled(false);
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
