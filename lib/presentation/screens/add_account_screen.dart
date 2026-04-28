import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';

/// Screen for adding a new account
class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedType = AccountType.bank;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await context.read<AccountProvider>().addAccount(
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: double.parse(_balanceController.text),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final error = context.read<AccountProvider>().error;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(currencyCode);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Account'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: DesignConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              Text('Account Name', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. HDFC Bank, SBI Savings',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  prefixIcon: Icon(
                    Icons.account_balance,
                    color: AppColors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Account Type
              Text('Account Type', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              DropdownButtonFormField<AccountType>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                  ),
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == AccountType.cash
                              ? Icons.wallet
                              : Icons.account_balance,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: DesignConstants.spacingSm),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Initial Balance
              Text('Initial Balance', style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: cf.prefix,
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                  ),
                ),
                style: AppTextStyles.amountMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initial balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignConstants.spacingXl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: DesignConstants.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: DesignConstants.borderRadiusMd,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text('Create Account', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
