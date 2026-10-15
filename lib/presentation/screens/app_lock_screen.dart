import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../providers/lock_provider.dart';
import '../../l10n/app_localizations.dart';

/// Full-screen PIN gate shown when [LockProvider.needsLockOverlay].
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _controller = TextEditingController();
  String? _error;
  int _failedAttempts = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startLockoutTimer() {
    setState(() {
      _lockoutSeconds = 30;
      _error = 'Too many incorrect attempts. Please wait 30s.';
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_lockoutSeconds > 1) {
          _lockoutSeconds--;
          _error = 'Too many incorrect attempts. Please wait ${_lockoutSeconds}s.';
        } else {
          _lockoutSeconds = 0;
          _error = null;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _submit() async {
    if (_lockoutSeconds > 0) return;
    final pin = _controller.text.trim();
    if (pin.length < 4) {
      setState(() => _error = AppLocalizations.of(context)!.lockEnterDigits);
      return;
    }
    final ok = await context.read<LockProvider>().verifyPin(pin);
    if (!mounted) return;
    if (!ok) {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _startLockoutTimer();
      } else {
        setState(() {
          final remaining = 5 - _failedAttempts;
          _error = '${AppLocalizations.of(context)!.lockIncorrectPin} ($remaining attempts left)';
          _controller.clear();
        });
      }
    } else {
      _failedAttempts = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: DesignConstants.screenPadding,
          child: Column(
            children: [
              const SizedBox(height: DesignConstants.spacingXl),
              Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
              const SizedBox(height: DesignConstants.spacingMd),
              Text(
                AppLocalizations.of(context)!.lockAppLocked,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: DesignConstants.spacingSm),
              Text(
                AppLocalizations.of(context)!.lockEnterPinToContinue,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: DesignConstants.spacingLg),
              TextField(
                controller: _controller,
                enabled: _lockoutSeconds == 0,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.pinLabel,
                  errorText: _error,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: DesignConstants.spacingMd),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _lockoutSeconds > 0 ? null : _submit,
                  child: Text(
                    _lockoutSeconds > 0
                        ? 'Wait ${_lockoutSeconds}s'
                        : AppLocalizations.of(context)!.lockUnlock,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
