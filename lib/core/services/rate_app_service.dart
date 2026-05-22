import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around [InAppReview] with Android-only guard.
///
/// • [requestInAppReview] – shows the native Play Store review dialog (quota-limited by Google).
/// • [openStoreListing] – always opens the Play Store page (no quota).
/// • [incrementAndCheckAutoPrompt] – increments saved-expense counter and
///   returns `true` when the user hits [_kAutoPromptThreshold] saves.
class RateAppService {
  RateAppService._();
  static final RateAppService instance = RateAppService._();

  final InAppReview _inAppReview = InAppReview.instance;

  /// Number of expense saves after which we auto-prompt for a review.
  /// 7 is a sweet spot: user has formed an opinion but hasn't been
  /// annoyed by too many interactions yet.
  static const int _kAutoPromptThreshold = 7;

  static const String _keyExpenseSaveCount = 'rate_expense_save_count';
  static const String _keyHasAutoPrompted = 'rate_has_auto_prompted';

  /// Whether the current platform supports in-app review.
  bool get isSupported => Platform.isAndroid;

  /// Show the native Google Play in-app review dialog.
  ///
  /// Google controls how often this actually appears — calling it multiple
  /// times may not show anything. Use [openStoreListing] as a reliable
  /// fallback (e.g. from a Settings button).
  Future<void> requestInAppReview() async {
    if (!Platform.isAndroid) return;
    try {
      final available = await _inAppReview.isAvailable();
      if (available) {
        await _inAppReview.requestReview();
      } else {
        // Fallback if the native dialog isn't available
        await openStoreListing();
      }
    } catch (e) {
      debugPrint('[RateApp] requestInAppReview error: $e');
    }
  }

  /// Opens the Google Play Store listing for the app. No quota limit.
  /// Perfect for a "Rate Us" button in Settings.
  Future<void> openStoreListing() async {
    if (!Platform.isAndroid) return;
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '', // Not needed for Android
      );
    } catch (e) {
      debugPrint('[RateApp] openStoreListing error: $e');
    }
  }

  /// Call after every successful expense save.
  ///
  /// Returns `true` exactly once — when the user crosses [_kAutoPromptThreshold].
  /// After that, auto-prompt is marked done and this always returns `false`.
  Future<bool> incrementAndCheckAutoPrompt() async {
    if (!Platform.isAndroid) return false;

    final prefs = await SharedPreferences.getInstance();
    final alreadyPrompted = prefs.getBool(_keyHasAutoPrompted) ?? false;
    if (alreadyPrompted) return false;

    final count = (prefs.getInt(_keyExpenseSaveCount) ?? 0) + 1;
    await prefs.setInt(_keyExpenseSaveCount, count);

    if (count >= _kAutoPromptThreshold) {
      await prefs.setBool(_keyHasAutoPrompted, true);
      return true;
    }
    return false;
  }
}
