import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/transfer_model.dart';
import '../query/expense_filters.dart';
import 'account_repository.dart';

/// Repository for Expense and Transfer database operations
class ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;
  final AccountRepository _accountRepository;

  ExpenseRepository({
    DatabaseHelper? dbHelper,
    Uuid? uuid,
    AccountRepository? accountRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid(),
        _accountRepository =
            accountRepository ?? AccountRepository(dbHelper: dbHelper ?? DatabaseHelper.instance);

  static const String _expenseTable = 'expenses';
  static const String _transferTable = 'transfers';

  // ============ EXPENSE OPERATIONS ============

  /// Add new expense and deduct from account in one transaction.
  Future<Expense> addExpense({
    required double amount,
    required Category category,
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
    await _dbHelper.transaction((txn) async {
      await txn.insert(_expenseTable, expense.toMap());
      await _accountRepository.applyBalanceDeltaTxn(txn, accountId, -amount);
    });
    return expense;
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        e.*,
        c.id as categoryId,
        c.name as categoryName,
        c.iconCode as categoryIconCode,
        c.colorValue as categoryColorValue,
        c.isEnabled as categoryIsEnabled,
        c.isSystem as categoryIsSystem
      FROM $_expenseTable e
      LEFT JOIN categories c ON e.category = c.id OR (e.category = c.name COLLATE NOCASE) -- Handle legacy enum strings
      ORDER BY e.date DESC
    ''');
    
    return results.map((map) => Expense.fromMap(map)).toList();
  }

  static String _orderByClause(ExpenseSort sort) {
    switch (sort) {
      case ExpenseSort.dateNewestFirst:
        return 'e.date DESC';
      case ExpenseSort.dateOldestFirst:
        return 'e.date ASC';
      case ExpenseSort.amountHighFirst:
        return 'e.amount DESC, e.date DESC';
      case ExpenseSort.amountLowFirst:
        return 'e.amount ASC, e.date DESC';
    }
  }

  /// Expenses matching [filters] (search, dates, category, account, sort).
  Future<List<Expense>> getExpensesFiltered(ExpenseFilters filters) async {
    final db = await _dbHelper.database;

    final buffer = StringBuffer('''
      SELECT 
        e.*,
        c.id as categoryId,
        c.name as categoryName,
        c.iconCode as categoryIconCode,
        c.colorValue as categoryColorValue,
        c.isEnabled as categoryIsEnabled,
        c.isSystem as categoryIsSystem
      FROM $_expenseTable e
      LEFT JOIN categories c ON e.category = c.id OR (e.category = c.name COLLATE NOCASE)
      WHERE 1 = 1
    ''');

    final args = <Object?>[];

    if (filters.startDate != null) {
      buffer.write(' AND e.date >= ?');
      args.add(filters.startDate!.toIso8601String());
    }
    if (filters.endDate != null) {
      buffer.write(' AND e.date <= ?');
      args.add(filters.endDate!.toIso8601String());
    }
    if (filters.categoryId != null) {
      buffer.write(' AND e.category = ?');
      args.add(filters.categoryId);
    }
    if (filters.accountId != null) {
      buffer.write(' AND e.accountId = ?');
      args.add(filters.accountId);
    }

    final q = filters.searchQuery?.trim();
    if (q != null && q.isNotEmpty) {
      final pattern = '%$q%';
      buffer.write(
        ' AND (IFNULL(e.note, "") LIKE ? OR IFNULL(c.name, "") LIKE ? OR CAST(e.amount AS TEXT) LIKE ?)',
      );
      args.add(pattern);
      args.add(pattern);
      args.add(pattern);
    }

    buffer.write(' ORDER BY ${_orderByClause(filters.sort)}');

    final results = await db.rawQuery(buffer.toString(), args);
    return results.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expense by id
  Future<Expense?> getExpenseById(String id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        e.*,
        c.id as categoryId,
        c.name as categoryName,
        c.iconCode as categoryIconCode,
        c.colorValue as categoryColorValue,
        c.isEnabled as categoryIsEnabled,
        c.isSystem as categoryIsSystem
      FROM $_expenseTable e
      LEFT JOIN categories c ON e.category = c.id OR (e.category = c.name COLLATE NOCASE)
      WHERE e.id = ?
    ''', [id]);
    
    return results.isNotEmpty ? Expense.fromMap(results.first) : null;
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        e.*,
        c.id as categoryId,
        c.name as categoryName,
        c.iconCode as categoryIconCode,
        c.colorValue as categoryColorValue,
        c.isEnabled as categoryIsEnabled,
        c.isSystem as categoryIsSystem
      FROM $_expenseTable e
      LEFT JOIN categories c ON e.category = c.id OR (e.category = c.name COLLATE NOCASE)
      WHERE e.date >= ? AND e.date <= ?
      ORDER BY e.date DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return results.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(Category category) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT 
        e.*,
        c.id as categoryId,
        c.name as categoryName,
        c.iconCode as categoryIconCode,
        c.colorValue as categoryColorValue,
        c.isEnabled as categoryIsEnabled,
        c.isSystem as categoryIsSystem
      FROM $_expenseTable e
      LEFT JOIN categories c ON e.category = c.id OR (e.category = c.name COLLATE NOCASE)
      WHERE e.category = ?
      ORDER BY e.date DESC
    ''', [category.id]);

    return results.map((map) => Expense.fromMap(map)).toList();
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
  Future<Map<Category, double>> getExpensesByCategories(
    DateTime start,
    DateTime end,
  ) async {
    final expenses = await getExpensesByDateRange(start, end);
    final Map<Category, double> result = {};
    
    for (final expense in expenses) {
      // Use map key equality based on id (since Category overrides ==)
      final existingTotal = result[expense.category] ?? 0.0;
      result[expense.category] = existingTotal + expense.amount;
    }
    
    return result;
  }

  /// Revert ledger for [original], apply new amounts for [updated], persist row.
  Future<void> updateExpenseWithLedger(Expense original, Expense updated) async {
    await _dbHelper.transaction((txn) async {
      await _accountRepository.applyBalanceDeltaTxn(txn, original.accountId, original.amount);
      await _accountRepository.applyBalanceDeltaTxn(txn, updated.accountId, -updated.amount);
      await txn.update(
        _expenseTable,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );
    });
  }

  /// Delete expense row and credit balance back in one transaction.
  Future<void> deleteExpenseWithLedger(Expense expense) async {
    await _dbHelper.transaction((txn) async {
      await txn.delete(_expenseTable, where: 'id = ?', whereArgs: [expense.id]);
      await _accountRepository.applyBalanceDeltaTxn(txn, expense.accountId, expense.amount);
    });
  }

  // ============ TRANSFER OPERATIONS ============

  /// Insert transfer and update both account balances atomically.
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
    await _dbHelper.transaction((txn) async {
      await txn.insert(_transferTable, transfer.toMap());
      await _accountRepository.applyBalanceDeltaTxn(txn, fromAccountId, -amount);
      await _accountRepository.applyBalanceDeltaTxn(txn, toAccountId, amount);
    });
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
