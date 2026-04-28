import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expense_app/core/database/database_helper.dart';
import 'package:expense_app/data/backup/backup_service.dart';
import 'package:expense_app/data/models/category_model.dart';
import 'package:expense_app/data/repositories/account_repository.dart';
import 'package:expense_app/data/repositories/expense_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.resetForTesting(deleteFile: true);
  });

  test('backup JSON survives export → wipe expenses → import', () async {
    final helper = DatabaseHelper.instance;
    final backup = BackupService(helper);
    final expenseRepo = ExpenseRepository();

    final db = await helper.database;
    final catRows = await db.query('categories', where: 'id = ?', whereArgs: ['food']);
    expect(catRows, isNotEmpty);
    final food = Category.fromMap(catRows.first);

    await AccountRepository().updateBalance('cash', 100);

    await expenseRepo.addExpense(
      amount: 42.5,
      category: food,
      accountId: 'cash',
      date: DateTime.utc(2025, 6, 1),
      note: 'test meal',
    );

    final payload = await backup.buildBackupPayload();
    final json = backup.encodePrettyJson(payload);

    await db.delete('expenses');

    expect(await expenseRepo.getAllExpenses(), isEmpty);

    await backup.importFromJsonString(json);

    final restored = await expenseRepo.getAllExpenses();
    expect(restored, hasLength(1));
    expect(restored.single.amount, 42.5);
    expect(restored.single.note, 'test meal');
  });
}
