import '../models/income_model.dart';
import '../../core/database/database_helper.dart';
import 'account_repository.dart';

/// Repository for Income operations
class IncomeRepository {
  final DatabaseHelper _databaseHelper;
  final AccountRepository _accountRepository;

  IncomeRepository({
    DatabaseHelper? databaseHelper,
    AccountRepository? accountRepository,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _accountRepository = accountRepository ??
            AccountRepository(dbHelper: databaseHelper ?? DatabaseHelper.instance);

  /// Get all incomes
  Future<List<Income>> getAllIncomes() async {
    final result = await _databaseHelper.queryAll('incomes');
    return result.map((map) => Income.fromMap(map)).toList();
  }

  /// Get incomes by date range
  Future<List<Income>> getIncomesByDateRange(DateTime start, DateTime end) async {
    final result = await _databaseHelper.queryWhere(
      'incomes',
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
      await txn.insert('incomes', income.toMap());
      await _accountRepository.applyBalanceDeltaTxn(txn, income.accountId, income.amount);
    });
  }

  /// Update income
  Future<void> updateIncome(Income income) async {
    await _databaseHelper.update('incomes', income.toMap(), income.id);
  }

  /// Delete income
  Future<void> deleteIncome(String id) async {
    await _databaseHelper.delete('incomes', id);
  }
}
