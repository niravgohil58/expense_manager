import 'package:flutter/material.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

/// Provider for managing account state
class AccountProvider extends ChangeNotifier {
  final AccountRepository _repository;

  AccountProvider({AccountRepository? repository})
      : _repository = repository ?? AccountRepository();

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get account by id
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get cash account
  Account? get cashAccount => getAccountById('cash');

  /// Get bank account 1
  Account? get bank1Account => getAccountById('bank1');

  /// Get bank account 2
  Account? get bank2Account => getAccountById('bank2');

  /// Get total balance across all accounts
  double get totalBalance {
    double total = 0.0;
    for (final account in _accounts) {
      total += account.balance;
    }
    return total;
  }

  /// Load all accounts from database
  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _repository.getAllAccounts();
    } catch (e) {
      _error = 'Failed to load accounts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update account balance
  Future<void> updateBalance(String accountId, double newBalance) async {
    try {
      await _repository.updateBalance(accountId, newBalance);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to update balance: $e';
      notifyListeners();
    }
  }

  /// Add amount to account balance
  Future<void> addToBalance(String accountId, double amount) async {
    try {
      await _repository.addToBalance(accountId, amount);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to add to balance: $e';
      notifyListeners();
    }
  }

  /// Subtract amount from account balance
  Future<void> subtractFromBalance(String accountId, double amount) async {
    try {
      await _repository.subtractFromBalance(accountId, amount);
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to subtract from balance: $e';
      notifyListeners();
    }
  }

  /// Transfer between accounts (single DB transaction)
  Future<void> transferBetweenAccounts(
    String fromAccountId,
    String toAccountId,
    double amount,
  ) async {
    try {
      await _repository.transferBetweenAccountsAtomic(
        fromAccountId,
        toAccountId,
        amount,
      );
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to transfer: $e';
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Rename account
  Future<void> renameAccount(String id, String newName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final account = getAccountById(id);
      if (account != null) {
        final updatedAccount = account.copyWith(name: newName);
        await _repository.updateAccount(updatedAccount);
        await loadAccounts();
      }
    } catch (e) {
      _error = 'Failed to rename account: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new account
  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double balance,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.addAccount(
        name: name,
        type: type,
        balance: balance,
      );
      
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to add account: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete account
  Future<void> deleteAccount(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteAccount(id);
      
      await loadAccounts();
    } catch (e) {
      _error = 'Failed to delete account: $e';
      _isLoading = false;
      notifyListeners();
    }
}
}
