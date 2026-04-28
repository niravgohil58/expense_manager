import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expense_app/core/database/database_helper.dart';
import 'package:expense_app/core/errors/app_exceptions.dart';
import 'package:expense_app/data/models/account_model.dart';
import 'package:expense_app/data/repositories/account_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.resetForTesting(deleteFile: true);
  });

  group('AccountRepository ledger', () {
    test('transfer rolls back when source has insufficient balance', () async {
      final repo = AccountRepository();
      await repo.updateBalance('cash', 100);

      await repo.addAccount(
        name: 'Bank X',
        type: AccountType.bank,
        balance: 0,
      );
      final accounts = await repo.getAllAccounts();
      final bankId =
          accounts.firstWhere((a) => a.name == 'Bank X').id;

      await expectLater(
        repo.transferBetweenAccountsAtomic('cash', bankId, 150),
        throwsA(isA<InsufficientBalanceException>()),
      );

      expect((await repo.getAccountById('cash'))!.balance, 100);
      expect((await repo.getAccountById(bankId))!.balance, 0);
    });

    test('subtractFromBalance rejects below epsilon', () async {
      final repo = AccountRepository();
      await repo.updateBalance('cash', 0.005);

      await expectLater(
        repo.subtractFromBalance('cash', 0.01),
        throwsA(isA<InsufficientBalanceException>()),
      );

      expect((await repo.getAccountById('cash'))!.balance, closeTo(0.005, 1e-12));
    });
  });
}
