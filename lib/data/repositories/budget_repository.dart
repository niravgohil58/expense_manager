import '../../core/database/database_helper.dart';

class BudgetRepository {
  BudgetRepository({DatabaseHelper? dbHelper})
      : _db = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _db;
  static const String _table = 'category_budgets';

  /// categoryId -> limit (> 0 only stored).
  Future<Map<String, double>> limitsForMonth(int year, int month) async {
    final maps = await _db.queryWhere(
      _table,
      'year = ? AND month = ?',
      [year, month],
    );
    final out = <String, double>{};
    for (final m in maps) {
      final id = m['categoryId'] as String;
      final lim = (m['limitAmount'] as num).toDouble();
      if (lim > 0) out[id] = lim;
    }
    return out;
  }

  /// Saves limit; removes row when [limitAmount] <= 0.
  Future<void> upsertLimit({
    required String categoryId,
    required int year,
    required int month,
    required double limitAmount,
  }) async {
    final db = await _db.database;
    if (limitAmount <= 0) {
      await db.delete(
        _table,
        where: 'categoryId = ? AND year = ? AND month = ?',
        whereArgs: [categoryId, year, month],
      );
      return;
    }
    await db.execute(
      '''
      INSERT INTO $_table (categoryId, year, month, limitAmount)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(categoryId, year, month) DO UPDATE SET limitAmount = excluded.limitAmount
      ''',
      [categoryId, year, month, limitAmount],
    );
  }
}
