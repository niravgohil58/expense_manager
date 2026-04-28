import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/account_model.dart';

/// Repository for Account database operations
class AccountRepository {
  final DatabaseHelper _dbHelper;

  AccountRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  static const String _tableName = 'accounts';
  static const double _epsilon = 1e-9;

  /// Applies [delta] to [accountId] balance inside an open [transaction].
  /// Negative balances are rejected unless [allowNegative] is true.
  Future<void> applyBalanceDeltaTxn(
    Transaction txn,
    String accountId,
    double delta, {
    bool allowNegative = false,
  }) async {
    final rows = await txn.query(
      _tableName,
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Account not found: $accountId');
    }
    final balance = (rows.first['balance'] as num).toDouble();
    final newBalance = balance + delta;
    if (!allowNegative && newBalance < -_epsilon) {
      throw InsufficientBalanceException(
        'Insufficient balance (have ${balance.toStringAsFixed(2)}, need ${(-delta).toStringAsFixed(2)})',
      );
    }
    await txn.update(
      _tableName,
      {
        'balance': newBalance,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  /// Atomically moves [amount] from [fromAccountId] to [toAccountId].
  Future<void> transferBetweenAccountsAtomic(
    String fromAccountId,
    String toAccountId,
    double amount,
  ) async {
    await _dbHelper.transaction((txn) async {
      await applyBalanceDeltaTxn(txn, fromAccountId, -amount);
      await applyBalanceDeltaTxn(txn, toAccountId, amount);
    });
  }

  /// Get all accounts
  Future<List<Account>> getAllAccounts() async {
    final maps = await _dbHelper.queryAll(_tableName);
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  /// Get account by id
  Future<Account?> getAccountById(String id) async {
    final map = await _dbHelper.queryById(_tableName, id);
    return map != null ? Account.fromMap(map) : null;
  }

  /// Update account balance
  Future<void> updateBalance(String accountId, double newBalance) async {
    await _dbHelper.updateAccountBalance(accountId, newBalance);
  }

  /// Add amount to account balance
  Future<void> addToBalance(String accountId, double amount) async {
    final account = await getAccountById(accountId);
    if (account != null) {
      await updateBalance(accountId, account.balance + amount);
    }
  }

  /// Subtract amount from account balance
  Future<void> subtractFromBalance(String accountId, double amount) async {
    final account = await getAccountById(accountId);
    if (account != null) {
      final newBalance = account.balance - amount;
      if (newBalance < -_epsilon) {
        throw InsufficientBalanceException(
          'Insufficient balance (have ${account.balance.toStringAsFixed(2)}, need ${amount.toStringAsFixed(2)})',
        );
      }
      await updateBalance(accountId, newBalance);
    }
  }

  /// Update account details
  Future<void> updateAccount(Account account) async {
    await _dbHelper.update(_tableName, account.toMap(), account.id);
  }

  /// Get total balance across all accounts
  Future<double> getTotalBalance() async {
    final accounts = await getAllAccounts();
    double total = 0.0;
    for (final account in accounts) {
      total += account.balance;
    }
    return total;
  }

  /// Add new account
  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double balance,
  }) async {
    final now = DateTime.now();
    final account = Account(
      id: const Uuid().v4(),
      name: name,
      type: type,
      balance: balance,
      createdAt: now,
      updatedAt: now,
    );

    await _dbHelper.insert(_tableName, account.toMap());
  }

  /// Delete account
  Future<void> deleteAccount(String id) async {
    await _dbHelper.delete(_tableName, id);
  }
}
