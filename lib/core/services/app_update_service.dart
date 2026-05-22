import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Wrapper around Google Play Core In-App Update API (Android only).
///
/// • [checkForUpdate] – checks Play Store for a newer version.
/// • [showUpdateDialogIfAvailable] – shows a Material dialog and starts
///   a flexible (background) download if the user taps "Update Now".
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  /// Prevents showing the update dialog more than once per app session.
  bool _hasCheckedThisSession = false;

  /// Whether the platform supports in-app updates.
  bool get isSupported => Platform.isAndroid;

  /// Reset session flag (useful for manual "Check for update" from Settings).
  void resetSessionFlag() => _hasCheckedThisSession = false;

  /// Check whether an update is available on Play Store.
  ///
  /// Returns the [AppUpdateInfo] if an update exists, or `null` if not
  /// (or if we're not on Android / there was an error).
  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!Platform.isAndroid) return null;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        return info;
      }
    } catch (e) {
      debugPrint('[AppUpdate] checkForUpdate error: $e');
    }
    return null;
  }

  /// Auto-check on home screen entry: shows a dialog if an update is
  /// available, but only once per session.
  Future<void> checkAndPromptIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    if (_hasCheckedThisSession) return;
    _hasCheckedThisSession = true;

    final info = await checkForUpdate();
    if (info == null) return;
    if (!context.mounted) return;

    _showUpdateDialog(context);
  }

  /// Manual check from Settings — always checks, shows result via SnackBar
  /// or dialog.
  Future<void> manualCheckForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final info = await checkForUpdate();
    if (!context.mounted) return;

    if (info != null) {
      _showUpdateDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re on the latest version! ✓'),
        ),
      );
    }
  }

  /// Shows a Material dialog asking the user to update.
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.system_update_rounded, size: 40),
        title: const Text('Update Available'),
        content: const Text(
          'A new version of Expense Manager is available. '
          'Update now for the latest features, improvements, and bug fixes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _startFlexibleUpdate(context);
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  /// Starts a flexible update (downloads in the background).
  /// When download completes, shows a SnackBar asking user to restart.
  Future<void> _startFlexibleUpdate(BuildContext context) async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Update downloaded. Restart to apply.'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Restart',
            onPressed: () {
              InAppUpdate.completeFlexibleUpdate();
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('[AppUpdate] startFlexibleUpdate error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }
}
