import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/database_helper.dart';

/// Escapes CSV cells with commas or quotes.
String csvEscape(String value) {
  final s = value.replaceAll('\r\n', ' ').replaceAll('\n', ' ');
  if (s.contains(',') || s.contains('"')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

/// Writes readable CSV files next to JSON backups (documents dir).
class CsvExportService {
  CsvExportService(this._db);

  final DatabaseHelper _db;

  Future<String> _writeCsv({
    required String filePrefix,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final stamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final path = p.join(docs.path, '${filePrefix}_$stamp.csv');
    final sb = StringBuffer();
    sb.writeln(headers.map(csvEscape).join(','));
    for (final row in rows) {
      sb.writeln(headers.map((h) => csvEscape('${row[h] ?? ''}')).join(','));
    }
    await File(path).writeAsString(sb.toString());
    return path;
  }

  /// Returns paths for accounts, expenses, incomes CSV files.
  Future<(String, String, String)> exportToDocumentsFiles() async {
    final db = await _db.database;
    final accounts = await db.query('accounts');
    final expenses = await db.query('expenses');
    final incomes = await db.query('incomes');

    final accountsPath = await _writeCsv(
      filePrefix: 'expense_manager_accounts',
      headers: ['id', 'name', 'type', 'balance', 'createdAt', 'updatedAt'],
      rows: accounts,
    );

    final expensesPath = await _writeCsv(
      filePrefix: 'expense_manager_expenses',
      headers: [
        'id',
        'amount',
        'category',
        'accountId',
        'date',
        'note',
        'createdAt',
      ],
      rows: expenses,
    );

    final incomesPath = await _writeCsv(
      filePrefix: 'expense_manager_incomes',
      headers: [
        'id',
        'amount',
        'category',
        'accountId',
        'date',
        'note',
        'createdAt',
      ],
      rows: incomes,
    );

    return (accountsPath, expensesPath, incomesPath);
  }
}
