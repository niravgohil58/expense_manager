import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/income_model.dart';
import '../../data/models/recurring_template_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/repositories/recurring_repository.dart';

class RecurringProvider extends ChangeNotifier {
  RecurringProvider({
    RecurringRepository? recurringRepository,
    ExpenseRepository? expenseRepository,
    IncomeRepository? incomeRepository,
    CategoryRepository? categoryRepository,
  })  : _recurring = recurringRepository ?? RecurringRepository(),
        _expense = expenseRepository ?? ExpenseRepository(),
        _income = incomeRepository ?? IncomeRepository(),
        _category = categoryRepository ?? CategoryRepository();

  final RecurringRepository _recurring;
  final ExpenseRepository _expense;
  final IncomeRepository _income;
  final CategoryRepository _category;

  List<RecurringTemplate> _templates = [];
  bool _loading = false;
  String? _error;

  List<RecurringTemplate> get templates => List.unmodifiable(_templates);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _templates = await _recurring.getAll();
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addTemplate({
    required bool kindExpense,
    required double amount,
    required String categoryRef,
    required String accountId,
    String? note,
    String frequency = 'monthly',
  }) async {
    try {
      await _recurring.createTemplate(
        kindExpense: kindExpense,
        amount: amount,
        categoryRef: categoryRef.trim(),
        accountId: accountId,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
        frequency: frequency,
      );
      await load();
      return true;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTemplate(String id) async {
    try {
      await _recurring.delete(id);
      await load();
      return true;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return false;
    }
  }

  /// Creates today’s expense or income from the template.
  Future<bool> postNow(RecurringTemplate t) async {
    try {
      if (t.kindExpense) {
        final cat = await _category.getCategoryById(t.categoryRef);
        if (cat == null) {
          throw StateError('Category no longer exists');
        }
        await _expense.addExpense(
          amount: t.amount,
          category: cat,
          accountId: t.accountId,
          date: DateTime.now(),
          note: t.note,
          attachmentPath: null,
        );
      } else {
        final inc = Income(
          id: const Uuid().v4(),
          amount: t.amount,
          category: t.categoryRef,
          accountId: t.accountId,
          date: DateTime.now(),
          note: t.note,
          createdAt: DateTime.now(),
        );
        await _income.addIncome(inc);
      }
      return true;
    } catch (e) {
      _error = '$e';
      notifyListeners();
      return false;
    }
  }
}
