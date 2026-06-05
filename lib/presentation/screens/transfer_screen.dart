import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ads/ads_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';


/// Transfer screen for moving money between accounts
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final accounts = context.read<AccountProvider>().accounts;
      if (accounts.length >= 2) {
        setState(() {
          _fromAccountId = accounts[0].id;
          _toAccountId = accounts[1].id;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.transferSelectBoth)),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.transferSameAccount)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<ExpenseProvider>().addTransfer(
      fromAccountId: _fromAccountId!,
      toAccountId: _toAccountId!,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.transferSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      await context.read<AdsController>().presentInterstitialIfEligible();
      if (!mounted) return;
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ExpenseProvider>().error ?? AppLocalizations.of(context)!.transferFailed,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshAccounts(BuildContext context) async {
    await Future.wait([
      context.read<AccountProvider>().loadAccounts(showLoading: false),
      context.read<ExpenseProvider>().loadTransfers(showLoading: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(currencyCode);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleTransferBalance),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.titleTransferHistory,
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/transfer-history'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Form(
        key: _formKey,
        child: RefreshIndicator(
          onRefresh: () => _refreshAccounts(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: DesignConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Field
                Text(AppLocalizations.of(context)!.formAmount, style: AppTextStyles.labelMedium),
                const SizedBox(height: DesignConstants.spacingXs),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    prefixText: cf.prefix,
                    hintText: '0.00',
                  ),
                  style: AppTextStyles.amountMedium,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.formEnterAmount;
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return AppLocalizations.of(context)!.formEnterValidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignConstants.spacingLg),

                // From Account
                Text(AppLocalizations.of(context)!.transferFromAccount, style: AppTextStyles.labelMedium),
                const SizedBox(height: DesignConstants.spacingXs),
                Consumer<AccountProvider>(
                  builder: (context, provider, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: _fromAccountId,
                      decoration: const InputDecoration(),
                      items: provider.accounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _fromAccountId = value),
                    );
                  },
                ),
                const SizedBox(height: DesignConstants.spacingMd),

                // Arrow Icon
                Center(
                  child: Icon(
                    Icons.arrow_downward,
                    color: AppColors.primary,
                    size: DesignConstants.iconSizeLg,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingMd),

                // To Account
                Text(AppLocalizations.of(context)!.transferToAccount, style: AppTextStyles.labelMedium),
                const SizedBox(height: DesignConstants.spacingXs),
                Consumer<AccountProvider>(
                  builder: (context, provider, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: _toAccountId,
                      decoration: const InputDecoration(),
                      items: provider.accounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _toAccountId = value),
                    );
                  },
                ),
                const SizedBox(height: DesignConstants.spacingLg),

                // Date Selection
                Text(AppLocalizations.of(context)!.formDate, style: AppTextStyles.labelMedium),
                const SizedBox(height: DesignConstants.spacingXs),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: DesignConstants.borderRadiusMd,
                  child: Container(
                    width: double.infinity,
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: DesignConstants.spacingMd),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingLg),

                // Note Field
                Text(AppLocalizations.of(context)!.formNoteOptional, style: AppTextStyles.labelMedium),
                const SizedBox(height: DesignConstants.spacingXs),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.formAddNoteHint,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingXl),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: DesignConstants.buttonHeightLg,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransfer,
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
                        : Text(AppLocalizations.of(context)!.transferButton, style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
