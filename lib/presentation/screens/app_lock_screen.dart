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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _controller.text.trim();
    if (pin.length < 4) {
      setState(() => _error = AppLocalizations.of(context)!.lockEnterDigits);
      return;
    }
    final ok = await context.read<LockProvider>().verifyPin(pin);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _error = AppLocalizations.of(context)!.lockIncorrectPin;
        _controller.clear();
      });
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
                  onPressed: _submit,
                  child: Text(AppLocalizations.of(context)!.lockUnlock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
