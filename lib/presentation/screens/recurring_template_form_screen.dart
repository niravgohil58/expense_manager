import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/recurring_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization/l10n_helpers.dart';


/// Form for creating a recurring template (manual “Post now” from list).
class RecurringTemplateFormScreen extends StatefulWidget {
  const RecurringTemplateFormScreen({super.key});

  @override
  State<RecurringTemplateFormScreen> createState() =>
      _RecurringTemplateFormScreenState();
}

class _RecurringTemplateFormScreenState extends State<RecurringTemplateFormScreen> {
  final _amount = TextEditingController();
  final _incomeCategory = TextEditingController();
  final _note = TextEditingController();
  bool _expense = true;
  Category? _cat;
  String? _accountId;
  String _frequency = 'monthly';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final catProv = context.read<CategoryProvider>();
      final acc = context.read<AccountProvider>();
      await catProv.loadCategories(showLoading: false);
      await acc.loadAccounts(showLoading: false);
      if (!mounted) return;
      final cats = catProv.enabledCategories;
      setState(() {
        _accountId = acc.accounts.isNotEmpty ? acc.accounts.first.id : null;
        _cat = cats.isNotEmpty ? cats.first : null;
      });
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _incomeCategory.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amt = double.tryParse(_amount.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recurringEnterValidAmount)),
      );
      return;
    }
    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recurringSelectAccount)),
      );
      return;
    }
    if (_expense && _cat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recurringSelectCategory)),
      );
      return;
    }
    if (!_expense && _incomeCategory.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recurringEnterIncomeCategoryLabel)),
      );
      return;
    }

    setState(() => _busy = true);
    final rec = context.read<RecurringProvider>();
    final ok = await rec.addTemplate(
      kindExpense: _expense,
      amount: amt,
      categoryRef: _expense ? _cat!.id : _incomeCategory.text.trim(),
      accountId: _accountId!,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      frequency: _frequency,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rec.error ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>().enabledCategories;
    final accounts = context.watch<AccountProvider>().accounts;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleAddTemplate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: DesignConstants.screenPadding,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(AppLocalizations.of(context)!.recurringKindExpense), icon: const Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: false, label: Text(AppLocalizations.of(context)!.recurringKindIncome), icon: const Icon(Icons.add_circle_outline)),
            ],
            selected: {_expense},
            onSelectionChanged: (s) => setState(() => _expense = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.formAmount,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_expense)
            InputDecorator(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formCategory,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  isExpanded: true,
                  value: cats.isEmpty
                      ? null
                      : (_cat != null && cats.any((c) => c.id == _cat!.id))
                          ? cats.firstWhere((c) => c.id == _cat!.id)
                          : cats.first,
                  items: cats
                      .map((c) => DropdownMenuItem(value: c, child: Text(getCategoryName(context, c))))
                      .toList(),
                  onChanged: cats.isEmpty ? null : (v) => setState(() => _cat = v),
                ),
              ),
            )
          else
            TextField(
              controller: _incomeCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.recurringCategoryLabelHint,
                border: const OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.listAccountLabel,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _accountId != null && accounts.any((a) => a.id == _accountId)
                    ? _accountId
                    : (accounts.isNotEmpty ? accounts.first.id : null),
                items: accounts
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: accounts.isEmpty ? null : (v) => setState(() => _accountId = v),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.recurringFrequency,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _frequency,
                items: [
                  DropdownMenuItem(value: 'monthly', child: Text(AppLocalizations.of(context)!.frequencyMonthly)),
                  DropdownMenuItem(value: 'weekly', child: Text(AppLocalizations.of(context)!.frequencyWeekly)),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? 'monthly'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.formNoteOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? AppLocalizations.of(context)!.recurringSaving : AppLocalizations.of(context)!.recurringSaveTemplate),
          ),
        ],
      ),
      ),
    );
  }
}
