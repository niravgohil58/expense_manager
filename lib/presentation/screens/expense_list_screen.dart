import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../widgets/drawer_host.dart';
import '../../core/constants/text_styles.dart';
import '../../data/models/expense_model.dart';
import '../../data/query/expense_filters.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

/// Expense list with search, filters, and sort (Phase C).
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final expense = context.read<ExpenseProvider>();
      final categories = context.read<CategoryProvider>();
      await Future.wait([
        expense.loadExpenses(),
        categories.loadCategories(showLoading: false),
      ]);
      if (!mounted) return;
      final q = expense.expenseFilters.searchQuery;
      if (q != null && q.isNotEmpty) {
        _searchController.text = q;
      }
      await context.read<AccountProvider>().loadAccounts(showLoading: false);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  static String? _dropdownCategoryValue(
    String? id,
    CategoryProvider categoryProvider,
  ) {
    if (id == null) return null;
    final ok = categoryProvider.categories.any((c) => c.id == id);
    return ok ? id : null;
  }

  static String? _dropdownAccountValue(
    String? id,
    AccountProvider accountProvider,
  ) {
    if (id == null) return null;
    final ok = accountProvider.accounts.any((a) => a.id == id);
    return ok ? id : null;
  }

  void _onSearchChanged(String value, ExpenseProvider expenseProvider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final t = value.trim();
      if (t.isEmpty) {
        expenseProvider.setExpenseFilters(
          expenseProvider.expenseFilters.copyWith(clearSearch: true),
        );
      } else {
        expenseProvider.setExpenseFilters(
          expenseProvider.expenseFilters.copyWith(searchQuery: t),
        );
      }
    });
  }

  Future<void> _showFiltersSheet(BuildContext context) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final accountProvider = context.read<AccountProvider>();

    ExpenseFilters draft = expenseProvider.expenseFilters;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filters', style: AppTextStyles.heading4),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Date range', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All dates'),
                          selected:
                              draft.startDate == null && draft.endDate == null,
                          onSelected: (_) {
                            setModalState(() {
                              draft = draft.copyWith(
                                clearStartDate: true,
                                clearEndDate: true,
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('This month'),
                          selected: _isThisMonth(
                            draft.startDate,
                            draft.endDate,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              final now = DateTime.now();
                              draft = draft.copyWith(
                                startDate: DateTime(now.year, now.month, 1),
                                endDate: DateTime(
                                  now.year,
                                  now.month + 1,
                                  0,
                                  23,
                                  59,
                                  59,
                                ),
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Last 30 days'),
                          selected: _isLast30Days(
                            draft.startDate,
                            draft.endDate,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              final end = DateTime.now();
                              final start = end.subtract(
                                const Duration(days: 30),
                              );
                              draft = draft.copyWith(
                                startDate: DateTime(
                                  start.year,
                                  start.month,
                                  start.day,
                                ),
                                endDate: DateTime(
                                  end.year,
                                  end.month,
                                  end.day,
                                  23,
                                  59,
                                  59,
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              draft.startDate == null
                                  ? 'From'
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(draft.startDate!),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: draft.startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  draft = draft.copyWith(startDate: picked);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event, size: 18),
                            label: Text(
                              draft.endDate == null
                                  ? 'To'
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(draft.endDate!),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: draft.endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  draft = draft.copyWith(
                                    endDate: DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      23,
                                      59,
                                      59,
                                    ),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Category'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _dropdownCategoryValue(
                            draft.categoryId,
                            categoryProvider,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All categories'),
                            ),
                            ...categoryProvider.categories.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setModalState(() {
                              draft = draft.copyWith(
                                categoryId: v,
                                clearCategory: v == null,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Account'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _dropdownAccountValue(
                            draft.accountId,
                            accountProvider,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All accounts'),
                            ),
                            ...accountProvider.accounts.map(
                              (a) => DropdownMenuItem<String?>(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setModalState(() {
                              draft = draft.copyWith(
                                accountId: v,
                                clearAccount: v == null,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Sort'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ExpenseSort>(
                          isExpanded: true,
                          value: draft.sort,
                          items: const [
                            DropdownMenuItem(
                              value: ExpenseSort.dateNewestFirst,
                              child: Text('Date · newest'),
                            ),
                            DropdownMenuItem(
                              value: ExpenseSort.dateOldestFirst,
                              child: Text('Date · oldest'),
                            ),
                            DropdownMenuItem(
                              value: ExpenseSort.amountHighFirst,
                              child: Text('Amount · high'),
                            ),
                            DropdownMenuItem(
                              value: ExpenseSort.amountLowFirst,
                              child: Text('Amount · low'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(
                              () => draft = draft.copyWith(sort: v),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              _searchController.clear();
                              await expenseProvider.clearExpenseFilters();
                            },
                            child: const Text('Clear all'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await expenseProvider.setExpenseFilters(draft);
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, 1);
    final e = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return start.year == s.year &&
        start.month == s.month &&
        start.day == s.day &&
        end.year == e.year &&
        end.month == e.month &&
        end.day == e.day;
  }

  bool _isLast30Days(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final diff = end.difference(start).inDays;
    return diff >= 28 && diff <= 32;
  }

  Future<bool?> _confirmDeleteExpense(
    BuildContext context,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense'),
        content: Text(
          'Remove this expense from ${expense.category.name}? '
          'The amount will be added back to the account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    final provider = context.read<ExpenseProvider>();
    final ok = await provider.deleteExpense(expense.id);
    if (!context.mounted) return false;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not delete expense'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return ok;
  }

  Future<void> _refreshExpenseList(BuildContext context) async {
    final categories = context.read<CategoryProvider>();
    final accounts = context.read<AccountProvider>();
    final expenses = context.read<ExpenseProvider>();
    await categories.loadCategories(showLoading: false);
    await accounts.loadAccounts(showLoading: false);
    await expenses.loadExpenses(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: const Text('Expenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersSheet(context),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.expensesForList;
          final hasFilters = provider.expenseFilters.hasActiveFilters;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notes, category, amount…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setExpenseFilters(
                                provider.expenseFilters.copyWith(
                                  clearSearch: true,
                                ),
                              );
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (v) {
                    setState(() {});
                    _onSearchChanged(v, provider);
                  },
                  onSubmitted: (v) => _onSearchChanged(v, provider),
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (hasFilters || _searchController.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        _searchController.clear();
                        await provider.clearExpenseFilters();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear filters'),
                    ),
                  ),
                ),
              if (hasFilters)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            _filterSummary(provider.expenseFilters),
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshExpenseList(context),
                  child: list.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: _buildEmptyState(
                                  context,
                                  provider,
                                  hasFilters,
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: DesignConstants.screenPadding.copyWith(
                            top: 0,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final expense = list[index];
                            return Dismissible(
                              key: ValueKey<String>('exp_${expense.id}'),
                              direction: DismissDirection.endToStart,
                              background: _SwipeDeleteBackground(
                                alignment: Alignment.centerRight,
                              ),
                              confirmDismiss: (_) =>
                                  _confirmDeleteExpense(context, expense),
                              child: _ExpenseCard(expense: expense),
                            );
                          },
                        ),
                ),
              ),
            ],
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

  String _filterSummary(ExpenseFilters f) {
    final parts = <String>[];
    final q = f.searchQuery?.trim();
    if (q != null && q.isNotEmpty) {
      final short = q.length > 28 ? '${q.substring(0, 25)}…' : q;
      parts.add('“$short”');
    }
    if (f.startDate != null || f.endDate != null) {
      final a = f.startDate != null
          ? DateFormat('dd/MM').format(f.startDate!)
          : '…';
      final b = f.endDate != null
          ? DateFormat('dd/MM').format(f.endDate!)
          : '…';
      parts.add('Dates $a–$b');
    }
    if (f.categoryId != null) parts.add('Category');
    if (f.accountId != null) parts.add('Account');
    parts.add(_sortLabel(f.sort));
    return parts.join(' · ');
  }

  String _sortLabel(ExpenseSort s) {
    switch (s) {
      case ExpenseSort.dateNewestFirst:
        return 'Newest';
      case ExpenseSort.dateOldestFirst:
        return 'Oldest';
      case ExpenseSort.amountHighFirst:
        return 'Amount ↓';
      case ExpenseSort.amountLowFirst:
        return 'Amount ↑';
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    ExpenseProvider provider,
    bool hasFilters,
  ) {
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

    return Center(
      child: Padding(
        padding: DesignConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: AppColors.textHint),
            const SizedBox(height: DesignConstants.spacingMd),
            Text(
              hasFilters
                  ? 'No expenses match your filters'
                  : 'No expenses to show',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignConstants.spacingMd),
            FilledButton(
              onPressed: () async {
                _searchController.clear();
                await provider.clearExpenseFilters();
                setState(() {});
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: DesignConstants.borderRadiusMd,
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final formatter =
        AppCurrencyFormat(currencyCode).formatter();

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
              child: Icon(expense.category.icon, color: expense.category.color),
            ),
            const SizedBox(width: DesignConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category.name, style: AppTextStyles.labelMedium),
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
