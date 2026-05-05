import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/recurring_template_model.dart';
import '../../l10n/app_localizations.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/recurring_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/drawer_host.dart';

class RecurringTemplatesScreen extends StatefulWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  State<RecurringTemplatesScreen> createState() => _RecurringTemplatesScreenState();
}

class _RecurringTemplatesScreenState extends State<RecurringTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurringProvider>().load();
    });
  }

  Future<void> _post(BuildContext context, RecurringTemplate t) async {
    final rec = context.read<RecurringProvider>();
    final expenseProv = context.read<ExpenseProvider>();
    final incomeProv = context.read<IncomeProvider>();
    final accountProv = context.read<AccountProvider>();
    final ok = await rec.postNow(t);
    if (!context.mounted) return;
    if (ok) {
      await expenseProv.loadExpenses(showLoading: false);
      await incomeProv.loadIncomes(showLoading: false);
      await accountProv.loadAccounts(showLoading: false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rec.error ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cc = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(cc);
    final rec = context.watch<RecurringProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: Text(l10n.recurringTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recurring-templates/add'),
        child: const Icon(Icons.add),
      ),
      body: rec.isLoading && rec.templates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: DesignConstants.screenPadding,
                  child: Text(
                    l10n.recurringSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: DesignConstants.screenPadding,
                    itemCount: rec.templates.length,
                    itemBuilder: (context, i) {
                      final t = rec.templates[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            t.kindExpense ? Icons.arrow_circle_down : Icons.arrow_circle_up,
                            color: t.kindExpense ? AppColors.expense : AppColors.income,
                          ),
                          title: Text(
                            '${t.kindExpense ? l10n.recurringKindExpense : l10n.recurringKindIncome} · ${cf.format(t.amount)}',
                          ),
                          subtitle: Text(
                            '${t.frequency} · ${t.categoryRef}${t.note != null ? '\n${t.note}' : ''}',
                          ),
                          isThreeLine: t.note != null,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'post') await _post(context, t);
                              if (v == 'del') {
                                await rec.deleteTemplate(t.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Removed')),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'post', child: Text(l10n.recurringPostNow)),
                              const PopupMenuItem(value: 'del', child: Text('Delete')),
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
