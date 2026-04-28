import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';

/// Home screen with account balances and quick actions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final accountProvider = context.read<AccountProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    await accountProvider.loadAccounts();
    await expenseProvider.loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expense Manager'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: DesignConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Card
              _buildTotalBalanceCard(),
              const SizedBox(height: DesignConstants.spacingLg),

              // Account Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Accounts', style: AppTextStyles.heading4),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening Add Account Screen...'), duration: Duration(milliseconds: 500)),
                        );
                        context.push('/add-account');
                      },
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      label: Text('ADD ACCOUNT', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignConstants.spacingSm),
              _buildAccountCards(),
              const SizedBox(height: DesignConstants.spacingLg),

              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.heading4),
              const SizedBox(height: DesignConstants.spacingSm),
              _buildQuickActions(),
              const SizedBox(height: DesignConstants.spacingLg),

              // This Month Summary
              Text('This Month', style: AppTextStyles.heading4),
              const SizedBox(height: DesignConstants.spacingSm),
              _buildMonthSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final formatter = NumberFormat.currency(
          locale: 'en_IN',
          symbol: DesignConstants.currencySymbol,
          decimalDigits: 2,
        );

        return Container(
          width: double.infinity,
          padding: DesignConstants.paddingLg,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: DesignConstants.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: DesignConstants.spacingXs),
              Text(
                formatter.format(provider.totalBalance),
                style: AppTextStyles.amountLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCards() {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: provider.accounts.map((account) {
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
              child: _AccountCard(
                account: account,
                onTap: (a) => _showAccountOptions(context, a),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Income',
            color: AppColors.success,
            onTap: () => context.push('/add-income'),
          ),
        ),
        const SizedBox(width: DesignConstants.spacingXs),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.remove_circle_outline,
            label: 'Expense',
            color: AppColors.expense,
            onTap: () => context.push('/add-expense'),
          ),
        ),
        const SizedBox(width: DesignConstants.spacingXs),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            color: AppColors.primary,
            onTap: () => context.push('/transfer'),
          ),
        ),
        const SizedBox(width: DesignConstants.spacingXs),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.people,
            label: 'Udhar',
            color: AppColors.udharDena,
            onTap: () => context.push('/add-udhar'),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSummary() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final formatter = NumberFormat.currency(
          locale: 'en_IN',
          symbol: DesignConstants.currencySymbol,
          decimalDigits: 2,
        );

        return Container(
          width: double.infinity,
          padding: DesignConstants.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: DesignConstants.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: DesignConstants.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: DesignConstants.borderRadiusSm,
                ),
                child: Icon(
                  Icons.trending_down,
                  color: AppColors.expense,
                  size: DesignConstants.iconSizeLg,
                ),
              ),
              const SizedBox(width: DesignConstants.spacingMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Spent', style: AppTextStyles.labelSmall),
                  Text(
                    formatter.format(provider.currentMonthTotal),
                    style: AppTextStyles.amountMedium.copyWith(
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountOptions(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(account.name, style: AppTextStyles.heading4),
                subtitle: Text(account.type.displayName),
                trailing: Text(
                  NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: DesignConstants.currencySymbol,
                    decimalDigits: 2,
                  ).format(account.balance),
                  style: AppTextStyles.amountMedium,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Rename Account'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, account);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_card, color: AppColors.success),
                title: const Text('Add Money'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddMoneyDialog(context, account);
                },
              ),
              const SizedBox(height: DesignConstants.spacingMd),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, Account account) {
    final controller = TextEditingController(text: account.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Account'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              hintText: 'e.g. HDFC Bank',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await context.read<AccountProvider>().renameAccount(
                        account.id,
                        controller.text.trim(),
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMoneyDialog(BuildContext context, Account account) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add balance to ${account.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  await context.read<AccountProvider>().addToBalance(
                        account.id,
                        amount,
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final Function(Account) onTap;

  const _AccountCard({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: DesignConstants.currencySymbol,
      decimalDigits: 2,
    );

    final isCash = account.type == AccountType.cash;
    final color = isCash ? AppColors.cash : AppColors.bank;
    final icon = isCash ? Icons.wallet : Icons.account_balance;

    return InkWell(
      onTap: () => onTap(account),
      borderRadius: DesignConstants.borderRadiusMd,
      child: Container(
        padding: DesignConstants.paddingMd,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DesignConstants.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
          Container(
            padding: DesignConstants.paddingSm,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: DesignConstants.borderRadiusSm,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: DesignConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: AppTextStyles.labelMedium),
                Text(
                  account.type.displayName,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            formatter.format(account.balance),
            style: AppTextStyles.amountSmall.copyWith(
              color: account.balance >= 0 ? AppColors.income : AppColors.expense,
            ),
          ),

        ],
      ),
    ));
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
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
          color: color.withValues(alpha: 0.1),
          borderRadius: DesignConstants.borderRadiusMd,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: DesignConstants.iconSizeLg),
            const SizedBox(height: DesignConstants.spacingXs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
