import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/formatting/app_currency.dart';
import '../../l10n/app_localizations.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/drawer_host.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cats = context.read<CategoryProvider>();
      final exp = context.read<ExpenseProvider>();
      final b = context.read<BudgetProvider>();
      await cats.loadCategories(showLoading: false);
      await exp.loadExpenses(showLoading: false);
      final now = DateTime.now();
      await b.loadMonth(now.year, now.month);
      if (!mounted) return;
      _syncControllers(cats);
    });
  }

  void _syncControllers(CategoryProvider cats) {
    final budget = context.read<BudgetProvider>();
    for (final c in cats.enabledCategories) {
      _controllers.putIfAbsent(c.id, () => TextEditingController());
      final lim = budget.limits[c.id];
      _controllers[c.id]!.text = lim != null && lim > 0 ? lim.toStringAsFixed(0) : '';
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _shiftMonth(int delta) async {
    final b = context.read<BudgetProvider>();
    final d = DateTime(b.year, b.month + delta);
    await b.loadMonth(d.year, d.month);
    if (!mounted) return;
    _syncControllers(context.read<CategoryProvider>());
    setState(() {});
  }

  Future<void> _saveAll() async {
    final b = context.read<BudgetProvider>();
    final cats = context.read<CategoryProvider>();
    for (final c in cats.enabledCategories) {
      final text = _controllers[c.id]?.text.trim() ?? '';
      final v = double.tryParse(text) ?? 0;
      await b.saveLimit(c.id, v);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.budgetsSave)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cc = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(cc);
    final budget = context.watch<BudgetProvider>();
    final cats = context.watch<CategoryProvider>();
    final expenseProv = context.watch<ExpenseProvider>();

    final monthLabel =
        MaterialLocalizations.of(context).formatMonthYear(DateTime(budget.year, budget.month));

    return Scaffold(
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: Text(l10n.budgetsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            tooltip: l10n.budgetsSave,
            icon: const Icon(Icons.save_outlined),
            onPressed: budget.isLoading ? null : _saveAll,
          ),
        ],
      ),
      body: budget.isLoading && cats.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: DesignConstants.screenPadding,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _shiftMonth(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          monthLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading4,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _shiftMonth(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignConstants.spacingMd),
                  child: Text(
                    l10n.budgetsMonthHint,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: DesignConstants.screenPadding,
                    itemCount: cats.enabledCategories.length,
                    itemBuilder: (context, i) {
                      final cat = cats.enabledCategories[i];
                      _controllers.putIfAbsent(cat.id, () => TextEditingController());
                      final lim = budget.limits[cat.id];
                      final start = DateTime(budget.year, budget.month, 1);
                      final end = DateTime(budget.year, budget.month + 1, 0, 23, 59, 59);
                      final spent = expenseProv.totalExpenseForCategoryInRange(cat.id, start, end);

                      return Card(
                        margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
                        child: Padding(
                          padding: DesignConstants.paddingMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(cat.name, style: AppTextStyles.labelLarge)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controllers[cat.id],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: 'Limit (${cf.prefix.trim()})',
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (lim != null && lim > 0) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (spent / lim).clamp(0.0, 1.0),
                                  backgroundColor: AppColors.border,
                                  color: spent > lim ? AppColors.error : AppColors.primary,
                                ),
                                Text(
                                  'Spent ${cf.format(spent)} / ${cf.format(lim)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
