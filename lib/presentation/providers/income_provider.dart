import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/errors/app_exceptions.dart';
import '../../data/models/income_model.dart';
import '../../data/query/income_filters.dart';
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
  /// Rows matching [IncomeFilters] for the Income tab list only.
  List<Income> _incomesForList = [];
  bool _isLoading = false;
  String? _error;
  IncomeFilters _incomeListFilters = IncomeFilters.none;

  /// Full snapshot (month totals, distinct categories for filters).
  List<Income> get incomes => _incomes;

  /// Filtered view for [IncomeListScreen].
  List<Income> get incomesForList => _incomesForList;

  bool get isLoading => _isLoading;
  String? get error => _error;
  IncomeFilters get incomeFilters => _incomeListFilters;

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

  /// Incomes in [month] of [year] (reports / analytics).
  Future<List<Income>> getIncomesForMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return _repository.getIncomesByDateRange(start, end);
  }

  Future<void> setIncomeFilters(IncomeFilters filters) async {
    _incomeListFilters = filters;
    try {
      _incomesForList =
          await _repository.getIncomesFiltered(_incomeListFilters);
    } catch (e) {
      _error = 'Failed to filter incomes: $e';
    }
    notifyListeners();
  }

  Future<void> clearIncomeFilters() async {
    await setIncomeFilters(IncomeFilters.none);
  }

  Future<void> _reloadIncomeListQuery() async {
    _incomesForList =
        await _repository.getIncomesFiltered(_incomeListFilters);
  }

  Future<void> loadIncomes({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _error = null;
    }

    try {
      _incomes = await _repository.getAllIncomes();
      _incomes.sort((a, b) => b.date.compareTo(a.date));
      await _reloadIncomeListQuery();
    } catch (e) {
      _error = 'Failed to load incomes: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
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

      await loadIncomes(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to add income: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update existing income (account balances adjusted).
  Future<bool> updateIncome(Income updated) async {
    _error = null;
    notifyListeners();
    try {
      final original =
          _incomes.firstWhere((e) => e.id == updated.id);
      await _repository.updateIncomeWithLedger(original, updated);
      await loadIncomes(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update income: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete income and reverse its credit on the account.
  Future<bool> deleteIncome(String id) async {
    _error = null;
    notifyListeners();
    try {
      final income = _incomes.firstWhere((e) => e.id == id);
      await _repository.deleteIncomeWithLedger(income);
      await loadIncomes(showLoading: false);
      await _accountProvider.loadAccounts(showLoading: false);
      return true;
    } on InsufficientBalanceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to delete income: $e';
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
