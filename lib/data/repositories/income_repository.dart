import '../models/income_model.dart';
import '../query/income_filters.dart';
import '../../core/database/database_helper.dart';
import 'account_repository.dart';

/// Repository for Income operations
class IncomeRepository {
  final DatabaseHelper _databaseHelper;
  final AccountRepository _accountRepository;

  static const String _incomeTable = 'incomes';

  IncomeRepository({
    DatabaseHelper? databaseHelper,
    AccountRepository? accountRepository,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _accountRepository = accountRepository ??
            AccountRepository(dbHelper: databaseHelper ?? DatabaseHelper.instance);

  /// Get all incomes
  Future<List<Income>> getAllIncomes() async {
    final result = await _databaseHelper.queryAll(_incomeTable);
    return result.map((map) => Income.fromMap(map)).toList();
  }

  static String _orderByClause(IncomeSort sort) {
    switch (sort) {
      case IncomeSort.dateNewestFirst:
        return 'date DESC';
      case IncomeSort.dateOldestFirst:
        return 'date ASC';
      case IncomeSort.amountHighFirst:
        return 'amount DESC, date DESC';
      case IncomeSort.amountLowFirst:
        return 'amount ASC, date DESC';
    }
  }

  /// Incomes matching [filters] (search, dates, category label, account, sort).
  Future<List<Income>> getIncomesFiltered(IncomeFilters filters) async {
    final db = await _databaseHelper.database;

    final buffer = StringBuffer('''
      SELECT * FROM $_incomeTable
      WHERE 1 = 1
    ''');

    final args = <Object?>[];

    if (filters.startDate != null) {
      buffer.write(' AND date >= ?');
      args.add(filters.startDate!.toIso8601String());
    }
    if (filters.endDate != null) {
      buffer.write(' AND date <= ?');
      args.add(filters.endDate!.toIso8601String());
    }
    if (filters.accountId != null) {
      buffer.write(' AND accountId = ?');
      args.add(filters.accountId);
    }
    final cat = filters.categoryLabel?.trim();
    if (cat != null && cat.isNotEmpty) {
      buffer.write(' AND category = ?');
      args.add(cat);
    }

    final q = filters.searchQuery?.trim();
    if (q != null && q.isNotEmpty) {
      final pattern = '%$q%';
      buffer.write(
        ' AND (IFNULL(note, "") LIKE ? OR IFNULL(category, "") LIKE ? OR CAST(amount AS TEXT) LIKE ?)',
      );
      args.add(pattern);
      args.add(pattern);
      args.add(pattern);
    }

    buffer.write(' ORDER BY ${_orderByClause(filters.sort)}');

    final results = await db.rawQuery(buffer.toString(), args);
    return results.map((map) => Income.fromMap(map)).toList();
  }

  /// Get incomes by date range
  Future<List<Income>> getIncomesByDateRange(DateTime start, DateTime end) async {
    final result = await _databaseHelper.queryWhere(
      _incomeTable,
      'date >= ? AND date <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final incomes = result.map((map) => Income.fromMap(map)).toList();
    incomes.sort((a, b) => b.date.compareTo(a.date));
    return incomes;
  }

  /// Insert income and credit account in one transaction.
  Future<void> addIncome(Income income) async {
    await _databaseHelper.transaction((txn) async {
      await txn.insert(_incomeTable, income.toMap());
      await _accountRepository.applyBalanceDeltaTxn(txn, income.accountId, income.amount);
    });
  }

  /// Reverts ledger for [original], applies credits for [updated], persist row.
  Future<void> updateIncomeWithLedger(Income original, Income updated) async {
    await _databaseHelper.transaction((txn) async {
      await _accountRepository.applyBalanceDeltaTxn(
        txn,
        original.accountId,
        -original.amount,
      );
      await _accountRepository.applyBalanceDeltaTxn(
        txn,
        updated.accountId,
        updated.amount,
      );
      await txn.update(
        _incomeTable,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );
    });
  }

  /// Deletes income row and removes the credit from the account balance.
  Future<void> deleteIncomeWithLedger(Income income) async {
    await _databaseHelper.transaction((txn) async {
      await txn.delete(
        _incomeTable,
        where: 'id = ?',
        whereArgs: [income.id],
      );
      await _accountRepository.applyBalanceDeltaTxn(
        txn,
        income.accountId,
        -income.amount,
      );
    });
  }
}
