import '../models/income_model.dart';
import '../../core/database/database_helper.dart';

/// Repository for Income operations
class IncomeRepository {
  final DatabaseHelper _databaseHelper;

  IncomeRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

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
    // Sort by date DESC
    final incomes = result.map((map) => Income.fromMap(map)).toList();
    incomes.sort((a, b) => b.date.compareTo(a.date));
    return incomes;
  }

  /// Add income
  Future<void> addIncome(Income income) async {
    await _databaseHelper.insert('incomes', income.toMap());
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
