import 'package:flutter/material.dart';

import '../../core/notifications/local_notification_service.dart';
import '../../core/preferences/app_preferences.dart';

/// App-wide settings backed by [AppPreferences] (theme, currency, security, reminders).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _syncFromPrefs();
  }

  final AppPreferences _prefs;

  late ThemeMode _themeMode;
  late String _currencyCode;
  late bool _appLockEnabled;

  late bool _recurringReminderEnabled;
  late int _recurringReminderWeekday;
  late int _recurringReminderHour;
  late int _recurringReminderMinute;
  late bool _backupReminderEnabled;
  late int _backupReminderWeekday;
  late int _backupReminderHour;
  late int _backupReminderMinute;

  late bool _iouScreenTipsVisible;

  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  bool get appLockEnabled => _appLockEnabled;

  bool get recurringReminderEnabled => _recurringReminderEnabled;
  int get recurringReminderWeekday => _recurringReminderWeekday;
  int get recurringReminderHour => _recurringReminderHour;
  int get recurringReminderMinute => _recurringReminderMinute;

  bool get backupReminderEnabled => _backupReminderEnabled;
  int get backupReminderWeekday => _backupReminderWeekday;
  int get backupReminderHour => _backupReminderHour;
  int get backupReminderMinute => _backupReminderMinute;

  bool get iouScreenTipsVisible => _iouScreenTipsVisible;

  void _syncFromPrefs() {
    _themeMode = _prefs.themeMode;
    _currencyCode = _prefs.currencyCode;
    _appLockEnabled = _prefs.appLockEnabled;
    _recurringReminderEnabled = _prefs.recurringReminderEnabled;
    _recurringReminderWeekday = _prefs.recurringReminderWeekday;
    _recurringReminderHour = _prefs.recurringReminderHour;
    _recurringReminderMinute = _prefs.recurringReminderMinute;
    _backupReminderEnabled = _prefs.backupReminderEnabled;
    _backupReminderWeekday = _prefs.backupReminderWeekday;
    _backupReminderHour = _prefs.backupReminderHour;
    _backupReminderMinute = _prefs.backupReminderMinute;
    _iouScreenTipsVisible = _prefs.iouScreenTipsVisible;
  }

  Future<void> _rescheduleNotifications() async {
    await LocalNotificationService.instance.rescheduleFromPrefs(_prefs);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setCurrencyCode(String code) async {
    await _prefs.setCurrencyCode(code);
    _currencyCode = code;
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _prefs.setAppLockEnabled(enabled);
    _appLockEnabled = enabled;
    notifyListeners();
  }

  Future<void> setRecurringReminderEnabled(bool enabled) async {
    await _prefs.setRecurringReminderEnabled(enabled);
    _recurringReminderEnabled = enabled;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setRecurringReminderWeekday(int weekday) async {
    await _prefs.setRecurringReminderWeekday(weekday);
    _recurringReminderWeekday = weekday;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setRecurringReminderTime(int hour, int minute) async {
    await _prefs.setRecurringReminderHour(hour);
    await _prefs.setRecurringReminderMinute(minute);
    _recurringReminderHour = hour;
    _recurringReminderMinute = minute;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setBackupReminderEnabled(bool enabled) async {
    await _prefs.setBackupReminderEnabled(enabled);
    _backupReminderEnabled = enabled;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setBackupReminderWeekday(int weekday) async {
    await _prefs.setBackupReminderWeekday(weekday);
    _backupReminderWeekday = weekday;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setBackupReminderTime(int hour, int minute) async {
    await _prefs.setBackupReminderHour(hour);
    await _prefs.setBackupReminderMinute(minute);
    _backupReminderHour = hour;
    _backupReminderMinute = minute;
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> reloadFromPrefs() async {
    _syncFromPrefs();
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> setIouScreenTipsVisible(bool visible) async {
    await _prefs.setIouScreenTipsVisible(visible);
    _iouScreenTipsVisible = visible;
    notifyListeners();
  }
}
