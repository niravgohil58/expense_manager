import 'package:flutter/foundation.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/transfer_model.dart';
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
  List<Transfer> _transfers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Expense> get expenses => _expenses;
  List<Transfer> get transfers => _transfers;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  /// Load all expenses
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAllExpenses();
    } catch (e) {
      _error = 'Failed to load expenses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all transfers
  Future<void> loadTransfers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transfers = await _repository.getAllTransfers();
    } catch (e) {
      _error = 'Failed to load transfers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all data
  Future<void> loadAll() async {
    await loadExpenses();
    await loadTransfers();
  }

  /// Add new expense
  Future<bool> addExpense({
    required double amount,
    required ExpenseCategory category,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    try {
      await _repository.addExpense(
        amount: amount,
        category: category,
        accountId: accountId,
        date: date,
        note: note,
      );
      // Deduct from account balance
      await _accountProvider.subtractFromBalance(accountId, amount);
      await loadExpenses();
      return true;
    } catch (e) {
      _error = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      final expense = _expenses.firstWhere((e) => e.id == id);
      await _repository.deleteExpense(id);
      // Add back to account balance
      await _accountProvider.addToBalance(expense.accountId, expense.amount);
      await loadExpenses();
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
      // Update account balances
      await _accountProvider.transferBetweenAccounts(
        fromAccountId,
        toAccountId,
        amount,
      );
      await loadTransfers();
      return true;
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
  Future<Map<ExpenseCategory, double>> getExpensesByCategories(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getExpensesByCategories(start, end);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
