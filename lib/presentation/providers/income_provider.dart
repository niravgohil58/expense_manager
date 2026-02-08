import 'package:flutter/material.dart';
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

  /// Load incomes (defaults to current month)
  Future<void> loadIncomes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load largely for the last year for now, or just all?
      // Let's load all for simplicity or match ExpenseProvider pattern
      // Checking implementation_plan, we didn't specify.
      // Let's load all for now.
      _incomes = await _repository.getAllIncomes();
      
      // Sort by date DESC
      _incomes.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = 'Failed to load incomes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add income
  Future<void> addIncome({
    required double amount,
    required String category,
    required String accountId,
    required DateTime date,
    String? note,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final income = Income(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID generation
        amount: amount,
        category: category,
        accountId: accountId,
        date: date,
        note: note,
        createdAt: DateTime.now(),
      );

      await _repository.addIncome(income);
      
      // Update account balance
      await _accountProvider.addToBalance(accountId, amount);
      
      await loadIncomes();
    } catch (e) {
      _error = 'Failed to add income: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
