import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/ads/ads_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/income_model.dart';
import '../providers/account_provider.dart';
import '../providers/income_provider.dart';
import '../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization/l10n_helpers.dart';

/// Add or edit income.
class AddIncomeScreen extends StatefulWidget {
  final Income? income;
  final double? preFilledAmount;
  final String? preFilledCategory;
  final String? preFilledAccountId;
  final String? preFilledNote;

  const AddIncomeScreen({
    super.key,
    this.income,
    this.preFilledAmount,
    this.preFilledCategory,
    this.preFilledAccountId,
    this.preFilledNote,
  });

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedAccountId;
  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    final inc = widget.income;
    if (inc != null) {
      _amountController.text = inc.amount.toString();
      _categoryController.text = inc.category;
      _noteController.text = inc.note ?? '';
      _selectedDate = inc.date;
      _selectedAccountId = inc.accountId;
    } else {
      if (widget.preFilledAmount != null) {
        _amountController.text = widget.preFilledAmount.toString();
      }
      if (widget.preFilledCategory != null) {
        _categoryController.text = widget.preFilledCategory!;
      }
      if (widget.preFilledNote != null) {
        _noteController.text = widget.preFilledNote!;
      }
      _selectedDate = DateTime.now();
      if (widget.preFilledAccountId != null) {
        _selectedAccountId = widget.preFilledAccountId;
      } else {
        final accountProvider = context.read<AccountProvider>();
        if (accountProvider.accounts.isNotEmpty) {
          _selectedAccountId = accountProvider.accounts.first.id;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<AccountProvider>().loadAccounts(showLoading: false);
      if (!mounted) return;
      final accounts = context.read<AccountProvider>().accounts;
      if (_selectedAccountId != null &&
          !accounts.any((a) => a.id == _selectedAccountId)) {
        setState(() {
          _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
        });
      } else if (_selectedAccountId == null && accounts.isNotEmpty) {
        setState(() => _selectedAccountId = accounts.first.id);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.formSelectAccount),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<IncomeProvider>();
    final amount = double.parse(_amountController.text);
    final trimmedCategory = _categoryController.text.trim();
    final trimmedNote = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    late final bool ok;
    if (_isEditing) {
      ok = await provider.updateIncome(
        widget.income!.copyWith(
          amount: amount,
          category: trimmedCategory,
          accountId: _selectedAccountId!,
          date: _selectedDate,
          note: trimmedNote,
        ),
      );
    } else {
      ok = await provider.addIncome(
        amount: amount,
        category: trimmedCategory,
        accountId: _selectedAccountId!,
        date: _selectedDate,
        note: trimmedNote,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    final message =
        provider.error ??
        (!_isEditing
            ? AppLocalizations.of(context)!.formIncomeAddFailed
            : AppLocalizations.of(context)!.formIncomeUpdateFailed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_isEditing
                    ? AppLocalizations.of(context)!.formIncomeUpdated
                    : AppLocalizations.of(context)!.formIncomeAdded)
              : message,
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) {
      await context.read<AdsController>().presentInterstitialIfEligible();
      if (!mounted) return;
      context.pop();
    }
  }

  Future<void> _deleteIncome() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.formDeleteIncomeTitle),
        content: Text(AppLocalizations.of(context)!.formDeleteIncomeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context)!.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted || widget.income == null) return;

    setState(() => _isLoading = true);
    final ok = await context.read<IncomeProvider>().deleteIncome(
      widget.income!.id,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    final err = context.read<IncomeProvider>().error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? AppLocalizations.of(context)!.listIncomeDeleted
              : (err ?? AppLocalizations.of(context)!.listIncomeDeleteFailed),
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(currencyCode);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppLocalizations.of(context)!.titleEditIncome
              : AppLocalizations.of(context)!.titleAddIncome,
        ),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _isLoading ? null : _deleteIncome,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            if (accountProvider.isLoading && accountProvider.accounts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: DesignConstants.screenPadding,
                children: [
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
                      labelText: AppLocalizations.of(context)!.formAmount,
                      prefixText: cf.prefix,
                      border: const OutlineInputBorder(),
                    ),
                    style: AppTextStyles.amountLarge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.formEnterAmount;
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.formEnterValidAmount;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  TextFormField(
                    controller: _categoryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.formCategory,
                      hintText: AppLocalizations.of(context)!.formCategoryHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.formEnterCategory;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.listAccountLabel,
                      border: const OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            _selectedAccountId != null &&
                                accountProvider.accounts.any(
                                  (a) => a.id == _selectedAccountId,
                                )
                            ? _selectedAccountId
                            : null,
                        hint: Text(
                          AppLocalizations.of(context)!.formSelectAccount,
                        ),
                        items: accountProvider.accounts.map((account) {
                          return DropdownMenuItem(
                            value: account.id,
                            child: Text(
                              '${account.name} (${getAccountTypeDisplayName(context, account.type)})',
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _selectedAccountId = value);
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  InkWell(
                    onTap: _isLoading ? null : () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.formDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  TextFormField(
                    controller: _noteController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.formNoteOptional,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditing
                            ? AppLocalizations.of(
                                context,
                              )!.formUpdateIncome.toUpperCase()
                            : AppLocalizations.of(
                                context,
                              )!.formSaveIncome.toUpperCase(),
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
