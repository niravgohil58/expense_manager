import 'package:flutter/material.dart';
import '../../core/preferences/app_preferences.dart';

/// App-wide settings backed by [AppPreferences] (theme, currency placeholder, lock placeholder).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _themeMode = _prefs.themeMode;
    _currencyCode = _prefs.currencyCode;
    _appLockEnabled = _prefs.appLockEnabled;
  }

  final AppPreferences _prefs;

  late ThemeMode _themeMode;
  late String _currencyCode;
  late bool _appLockEnabled;

  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  bool get appLockEnabled => _appLockEnabled;

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

  Future<void> reloadFromPrefs() async {
    _themeMode = _prefs.themeMode;
    _currencyCode = _prefs.currencyCode;
    _appLockEnabled = _prefs.appLockEnabled;
    notifyListeners();
  }
}
