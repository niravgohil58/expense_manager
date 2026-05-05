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
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an account')),
      );
      return;
    }
    if (_expense && _cat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a category')),
      );
      return;
    }
    if (!_expense && _incomeCategory.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter income category label')),
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
        title: const Text('New template'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: ListView(
        padding: DesignConstants.screenPadding,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Expense'), icon: Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: false, label: Text('Income'), icon: Icon(Icons.add_circle_outline)),
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
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_expense)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: cats.isEmpty ? null : (v) => setState(() => _cat = v),
                ),
              ),
            )
          else
            TextField(
              controller: _incomeCategory,
              decoration: const InputDecoration(
                labelText: 'Category label (e.g. Salary)',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _frequency,
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => setState(() => _frequency = v ?? 'monthly'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Saving…' : 'Save template'),
          ),
        ],
      ),
    );
  }
}
