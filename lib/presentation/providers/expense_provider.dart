import 'package:flutter/foundation.dart' hide Category;
import '../../core/errors/app_exceptions.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transfer_model.dart';
import '../../data/query/expense_filters.dart';
import '../../data/repositories/expense_repository.dart';
import 'account_provider.dart';

/// Provider for managing expense and transfer state
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;
  final AccountProvider _accountProvider;

  ExpenseProvider({
    ExpenseRepository? repository,
    required AccountProvider accountProvider,
  })  : _repository = repository ?? ExpenseRepository(),
        _accountProvider = accountProvider;

  List<Expense> _expenses = [];
  /// Rows matching [ExpenseFilters] for the Expenses tab list only.
  List<Expense> _expensesForList = [];
  List<Transfer> _transfers = [];
  bool _isLoading = false;
  String? _error;
  ExpenseFilters _expenseListFilters = ExpenseFilters.none;

  // Getters
  /// Full DB snapshot (home totals, edit/delete lookups).
  List<Expense> get expenses => _expenses;

  /// Filtered view for [ExpenseListScreen].
  List<Expense> get expensesForList => _expensesForList;

  List<Transfer> get transfers => _transfers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ExpenseFilters get expenseFilters => _expenseListFilters;

  /// Get recent expenses (last 10)
  List<Expense> get recentExpenses =>
      _expenses.take(10).toList();

  /// Get expenses for current month
  List<Expense> get currentMonthExpenses {
    final now = DateTime.now();
    return _expenses.where((e) =>
      e.date.month == now.month && e.date.year == now.year
    ).toList();
  }

  /// Get total for current month
  double get currentMonthTotal {
    double total = 0.0;
    for (final expense in currentMonthExpenses) {
      total += expense.amount;
    }
    return total;
  }

  /// Replace expense list filters and reload list query (home/report unaffected).
  Future<void> setExpenseFilters(ExpenseFilters filters) async {
    _expenseListFilters = filters;
    try {
      _expensesForList =
          await _repository.getExpensesFiltered(_expenseListFilters);
    } catch (e) {
      _error = 'Failed to filter expenses: $e';
    }
    notifyListeners();
  }

  /// Clear expense list filters.
  Future<void> clearExpenseFilters() async {
    await setExpenseFilters(ExpenseFilters.none);
  }

  Future<void> _reloadExpenseListQuery() async {
    _expensesForList =
        await _repository.getExpensesFiltered(_expenseListFilters);
  }

  /// Load all expenses
  Future<void> loadExpenses({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _error = null;
    }

    try {
      _expenses = await _repository.getAllExpenses();
      await _reloadExpenseListQuery();
    } catch (e) {
      _error = 'Failed to load expenses: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Load all transfers
  Future<void> loadTransfers({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _error = null;
    }

    try {
      _transfers = await _repository.getAllTransfers();
    } catch (e) {
      _error = 'Failed to load transfers: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Load all data
  Future<void> loadAll({bool showLoading = true}) async {
    await loadExpenses(showLoading: showLoading);
    await loadTransfers(showLoading: showLoading);
  }

  /// Add new expense
  Future<bool> addExpense({
    required double amount,
    required Category category,
    required String accountId,
    required DateTime date,
    String? note,
    String? attachmentPath,
  }) async {
    try {
      await _repository.addExpense(
        amount: amount,
        category: category,
        accountId: accountId,
        date: date,
        note: note,
        attachmentPath: attachmentPath,
      );
      await loadExpenses(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update expense
  Future<bool> updateExpense(Expense updatedExpense) async {
    try {
      final originalExpense =
          _expenses.firstWhere((e) => e.id == updatedExpense.id);

      await _repository.updateExpenseWithLedger(originalExpense, updatedExpense);

      await loadExpenses(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      final expense = _expenses.firstWhere((e) => e.id == id);
      await _repository.deleteExpenseWithLedger(expense);
      await loadExpenses(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add new transfer
  Future<bool> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    if (fromAccountId == toAccountId) {
      _error = 'Cannot transfer to the same account';
      notifyListeners();
      return false;
    }

    try {
      await _repository.addTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        date: date,
        note: note,
      );
      await loadTransfers(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add transfer: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getExpensesByDateRange(start, end);
  }

  /// Get expenses for a specific month
  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    return await _repository.getExpensesForMonth(year, month);
  }

  /// Get total expenses for date range
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    return await _repository.getTotalExpenses(start, end);
  }

  /// Get expenses grouped by category
  Future<Map<Category, double>> getExpensesByCategories(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getExpensesByCategories(start, end);
  }

  /// Sum loaded expenses for [categoryId] in inclusive [start]–[end] range.
  double totalExpenseForCategoryInRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) {
    double sum = 0;
    for (final e in _expenses) {
      if (e.category.id != categoryId) continue;
      final d = e.date;
      if (!d.isBefore(start) && !d.isAfter(end)) sum += e.amount;
    }
    return sum;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
