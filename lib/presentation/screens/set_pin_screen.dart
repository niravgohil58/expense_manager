import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../providers/lock_provider.dart';
import '../../l10n/app_localizations.dart';


/// First-time or change PIN: saves SHA-256 hash via [LockProvider.setPin].
class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final a = _pin.text.trim();
    final b = _confirm.text.trim();
    if (a.length < 4 || b.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pinAtLeast4Digits)),
      );
      return;
    }
    if (a != b) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pinDoNotMatch)),
      );
      return;
    }
    setState(() => _busy = true);
    final lock = context.read<LockProvider>();
    try {
      await lock.setPin(a);
      await lock.verifyPin(a);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleAppSecurityPin),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
        padding: DesignConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.pinDescription,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignConstants.spacingLg),
            TextField(
              controller: _pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.pinLabel,
                border: OutlineInputBorder(
                  borderRadius: DesignConstants.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: DesignConstants.spacingMd),
            TextField(
              controller: _confirm,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.pinConfirmLabel,
                border: OutlineInputBorder(
                  borderRadius: DesignConstants.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: DesignConstants.spacingLg),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(
                _busy
                    ? AppLocalizations.of(context)!.pinSaving
                    : AppLocalizations.of(context)!.pinSave,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
