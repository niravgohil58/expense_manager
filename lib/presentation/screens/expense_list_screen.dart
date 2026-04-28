import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';

/// Expense list screen showing all expenses
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  Text(
                    'No expenses yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingXs),
                  Text(
                    'Tap + to add your first expense',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: DesignConstants.screenPadding,
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return _ExpenseCard(expense: expense);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: DesignConstants.currencySymbol,
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: () {
        context.push('/add-expense', extra: expense);
      },
      borderRadius: DesignConstants.borderRadiusMd,
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
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
                color: expense.category.color.withValues(alpha: 0.1),
                borderRadius: DesignConstants.borderRadiusSm,
              ),
              child: Icon(
                expense.category.icon,
                color: expense.category.color,
              ),
            ),
            const SizedBox(width: DesignConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category.name,
                    style: AppTextStyles.labelMedium,
                  ),
                  Text(
                    dateFormatter.format(expense.date),
                    style: AppTextStyles.caption,
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Text(
                      expense.note!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              '- ${formatter.format(expense.amount)}',
              style: AppTextStyles.amountSmall.copyWith(
                color: AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
