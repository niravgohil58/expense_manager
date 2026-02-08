import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/expense_model.dart';
import '../models/transfer_model.dart';

/// Repository for Expense and Transfer database operations
class ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;

  ExpenseRepository({DatabaseHelper? dbHelper, Uuid? uuid})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  static const String _expenseTable = 'expenses';
  static const String _transferTable = 'transfers';

  // ============ EXPENSE OPERATIONS ============

  /// Add new expense
  Future<Expense> addExpense({
    required double amount,
    required ExpenseCategory category,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      accountId: accountId,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );
    await _dbHelper.insert(_expenseTable, expense.toMap());
    return expense;
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final maps = await _dbHelper.queryAll(_expenseTable);
    return maps.map((map) => Expense.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expense by id
  Future<Expense?> getExpenseById(String id) async {
    final map = await _dbHelper.queryById(_expenseTable, id);
    return map != null ? Expense.fromMap(map) : null;
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final maps = await _dbHelper.getExpensesByDateRange(start, end);
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final maps = await _dbHelper.queryWhere(
      _expenseTable,
      'category = ?',
      [category.name],
    );
    return maps.map((map) => Expense.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get expenses for a specific month
  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return getExpensesByDateRange(start, end);
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    double total = 0.0;
    for (final expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  /// Get expenses grouped by category for a date range
  Future<Map<ExpenseCategory, double>> getExpensesByCategories(
    DateTime start,
    DateTime end,
  ) async {
    final expenses = await getExpensesByDateRange(start, end);
    final Map<ExpenseCategory, double> result = {};
    
    for (final expense in expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    
    return result;
  }

  /// Update expense
  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.update(_expenseTable, expense.toMap(), expense.id);
  }

  /// Delete expense
  Future<void> deleteExpense(String id) async {
    await _dbHelper.delete(_expenseTable, id);
  }

  // ============ TRANSFER OPERATIONS ============

  /// Add new transfer
  Future<Transfer> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final transfer = Transfer(
      id: _uuid.v4(),
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );
    await _dbHelper.insert(_transferTable, transfer.toMap());
    return transfer;
  }

  /// Get all transfers
  Future<List<Transfer>> getAllTransfers() async {
    final maps = await _dbHelper.queryAll(_transferTable);
    return maps.map((map) => Transfer.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transfer by id
  Future<Transfer?> getTransferById(String id) async {
    final map = await _dbHelper.queryById(_transferTable, id);
    return map != null ? Transfer.fromMap(map) : null;
  }

  /// Delete transfer
  Future<void> deleteTransfer(String id) async {
    await _dbHelper.delete(_transferTable, id);
  }
}
