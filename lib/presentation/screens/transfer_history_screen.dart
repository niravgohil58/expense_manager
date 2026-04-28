import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transfer_model.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

/// Lists recorded transfers (sorted newest first).
class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({super.key});

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ExpenseProvider>().loadTransfers();
    });
  }

  String? _accountName(List<Account> accounts, String id) {
    for (final a in accounts) {
      if (a.id == id) return a.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final cf = AppCurrencyFormat(currencyCode);
    final formatter = cf.formatter();
    final dateFmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transfer History'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer2<ExpenseProvider, AccountProvider>(
        builder: (context, expense, accounts, _) {
          if (expense.isLoading && expense.transfers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = List<Transfer>.from(expense.transfers)
            ..sort((a, b) => b.date.compareTo(a.date));

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ExpenseProvider>().loadTransfers(showLoading: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: DesignConstants.screenPadding,
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Center(
                    child: Text(
                      'No transfers yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<ExpenseProvider>().loadTransfers(showLoading: false),
                context.read<AccountProvider>().loadAccounts(showLoading: false),
              ]);
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: DesignConstants.screenPadding,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final t = items[index];
                final from = _accountName(accounts.accounts, t.fromAccountId) ??
                    t.fromAccountId;
                final to = _accountName(accounts.accounts, t.toAccountId) ??
                    t.toAccountId;

                return Container(
                  margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
                  padding: DesignConstants.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: DesignConstants.borderRadiusMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatter.format(t.amount),
                        style: AppTextStyles.amountMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: DesignConstants.spacingXs),
                      Text(
                        '$from → $to',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        dateFmt.format(t.date),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (t.note != null && t.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: DesignConstants.spacingXs),
                          child: Text(t.note!, style: AppTextStyles.bodySmall),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
