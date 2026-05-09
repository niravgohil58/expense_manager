import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/recurring_provider.dart';
import '../providers/udhar_provider.dart';

/// Reload in-memory providers after SQLite was wiped or replaced.
Future<void> refreshAllLocalDataCaches(BuildContext context) async {
  final now = DateTime.now();
  await Future.wait([
    context.read<AccountProvider>().loadAccounts(showLoading: false),
    context.read<CategoryProvider>().loadCategories(showLoading: false),
    context.read<ExpenseProvider>().loadAll(showLoading: false),
    context.read<IncomeProvider>().loadIncomes(showLoading: false),
    context.read<UdharProvider>().loadUdhar(showLoading: false),
    context.read<RecurringProvider>().load(),
    context.read<BudgetProvider>().loadMonth(now.year, now.month),
  ]);
}
