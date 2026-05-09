import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_app/core/preferences/app_preferences.dart';

void main() {
  group('AppPreferences', () {
    test('defaults theme to system when unset', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.themeMode, ThemeMode.system);
    });

    test('persists and reads theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final raw = await SharedPreferences.getInstance();
      final prefs = AppPreferences(raw);

      await prefs.setThemeMode(ThemeMode.dark);
      expect(raw.getString(AppPreferences.keyThemeMode), AppPreferences.themeDark);
      expect(prefs.themeMode, ThemeMode.dark);

      await prefs.setThemeMode(ThemeMode.light);
      expect(prefs.themeMode, ThemeMode.light);
    });

    test('currency defaults to INR', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.currencyCode, AppPreferences.defaultCurrencyCode);
    });

    test('iou screen tips visible defaults true and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.iouScreenTipsVisible, true);
      await prefs.setIouScreenTipsVisible(false);
      expect(prefs.iouScreenTipsVisible, false);
      await prefs.setIouScreenTipsVisible(true);
      expect(prefs.iouScreenTipsVisible, true);
    });

    test('grandfather grants legal acceptance when onboarding already completed',
        () async {
      SharedPreferences.setMockInitialValues({
        AppPreferences.keyOnboardingCompleted: true,
      });
      final raw = await SharedPreferences.getInstance();
      await AppPreferences.migrateLegalTermsGrandfather(raw);

      final prefs = AppPreferences(raw);
      expect(prefs.legalTermsAccepted, true);

      await AppPreferences.migrateLegalTermsGrandfather(raw);
      expect(prefs.legalTermsAccepted, true);
    });

    test('app lock defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      expect(prefs.appLockEnabled, false);
    });
  });
}
