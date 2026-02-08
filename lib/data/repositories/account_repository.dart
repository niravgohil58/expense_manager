import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/account_model.dart';

/// Repository for Account database operations
class AccountRepository {
  final DatabaseHelper _dbHelper;

  AccountRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  static const String _tableName = 'accounts';

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
      await updateBalance(accountId, account.balance - amount);
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
