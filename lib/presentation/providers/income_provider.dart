import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';
import 'account_provider.dart';

/// Provider for managing income state
class IncomeProvider extends ChangeNotifier {
  final IncomeRepository _repository;
  final AccountProvider _accountProvider;

  IncomeProvider({
    IncomeRepository? repository,
    required AccountProvider accountProvider,
  })  : _repository = repository ?? IncomeRepository(),
        _accountProvider = accountProvider;

  List<Income> _incomes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Calculate total income for current month
  double get currentMonthTotal {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double total = 0;
    for (final income in _incomes) {
      if (income.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          income.date.isBefore(end.add(const Duration(seconds: 1)))) {
        total += income.amount;
      }
    }
    return total;
  }

  Future<void> loadIncomes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incomes = await _repository.getAllIncomes();
      _incomes.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = 'Failed to load incomes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add income; returns false on failure ([error] is set).
  Future<bool> addIncome({
    required double amount,
    required String category,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final income = Income(
        id: const Uuid().v4(),
        amount: amount,
        category: category,
        accountId: accountId,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      await _repository.addIncome(income);

      await loadIncomes();
      await _accountProvider.loadAccounts();
      return true;
    } catch (e) {
      _error = 'Failed to add income: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
