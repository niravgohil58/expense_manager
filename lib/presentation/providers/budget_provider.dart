import 'package:flutter/material.dart';

import '../../data/repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository();

  final BudgetRepository _repository;

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  Map<String, double> _limits = {};
  bool _loading = false;
  String? _error;

  int get year => _year;
  int get month => _month;
  Map<String, double> get limits => Map.unmodifiable(_limits);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadMonth(int year, int month) async {
    _year = year;
    _month = month;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _limits = await _repository.limitsForMonth(year, month);
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveLimit(String categoryId, double limit) async {
    try {
      await _repository.upsertLimit(
        categoryId: categoryId,
        year: _year,
        month: _month,
        limitAmount: limit,
      );
      _limits = await _repository.limitsForMonth(_year, _month);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return false;
    }
  }
}
