import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/udhar_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/udhar_provider.dart';
import '../../l10n/app_localizations.dart';


/// Add udhar screen with form
class AddUdharScreen extends StatefulWidget {
  const AddUdharScreen({super.key});

  @override
  State<AddUdharScreen> createState() => _AddUdharScreenState();
}

class _AddUdharScreenState extends State<AddUdharScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  UdharType _selectedType = UdharType.dena;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final accounts = context.read<AccountProvider>().accounts;
      if (accounts.isNotEmpty) {
        setState(() => _selectedAccountId = accounts.first.id);
      }
    });
  }

  @override
  void dispose() {
    _personNameController.dispose();
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

  Future<void> _saveUdhar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.formSelectAccount)));
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<UdharProvider>().addUdhar(
      personName: _personNameController.text.trim(),
      type: _selectedType,
      amount: double.parse(_amountController.text),
      accountId: _selectedAccountId!,
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.udharSaved),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<UdharProvider>().error ?? 'Failed'),
          backgroundColor: AppColors.error,
        ),
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
        title: Text(AppLocalizations.of(context)!.titleAddIou),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: DesignConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selection
              Text(AppLocalizations.of(context)!.formTypeLabel, style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: AppLocalizations.of(context)!.udharLentLabel,
                      subtitle: AppLocalizations.of(context)!.udharMoneyGave,
                      isSelected: _selectedType == UdharType.dena,
                      color: AppColors.udharDena,
                      onTap: () =>
                          setState(() => _selectedType = UdharType.dena),
                    ),
                  ),
                  const SizedBox(width: DesignConstants.spacingSm),
                  Expanded(
                    child: _TypeButton(
                      label: AppLocalizations.of(context)!.udharBorrowedLabel,
                      subtitle: AppLocalizations.of(context)!.udharMoneyTook,
                      isSelected: _selectedType == UdharType.lena,
                      color: AppColors.udharLena,
                      onTap: () =>
                          setState(() => _selectedType = UdharType.lena),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Person Name
              Text(AppLocalizations.of(context)!.udharPersonNameLabel, style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _personNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.udharEnterNameHint,
                  prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.udharPersonNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Amount
              Text(AppLocalizations.of(context)!.formAmount, style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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

              // Account Selection
              Text(AppLocalizations.of(context)!.listAccountLabel, style: AppTextStyles.labelMedium),
              const SizedBox(height: DesignConstants.spacingXs),
              Consumer<AccountProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: const InputDecoration(),
                    items: provider.accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedAccountId = value),
                  );
                },
              ),
              const SizedBox(height: DesignConstants.spacingLg),

              // Date
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

              // Note
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
                  onPressed: _isLoading ? null : _saveUdhar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == UdharType.dena
                        ? AppColors.udharDena
                        : AppColors.udharLena,
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
                      : Text(AppLocalizations.of(context)!.udharSaveIou, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: DesignConstants.borderRadiusMd,
      child: Container(
        padding: DesignConstants.paddingMd,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
          borderRadius: DesignConstants.borderRadiusMd,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
