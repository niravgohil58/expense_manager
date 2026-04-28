import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  final CategoryRepository _repository;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Category> get enabledCategories =>
      _categories.where((c) => c.isEnabled).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads categories from the database.
  ///
  /// When [showLoading] is false, [isLoading] is not toggled (background refresh).
  Future<void> loadCategories({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    try {
      await _repository.addCategory(name: name, icon: icon, color: color);
      await loadCategories(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategoryFull({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    try {
      final existing = await _repository.getCategoryById(id);
      if (existing == null) return false;
      final updated = existing.copyWith(
        name: name.trim(),
        iconCode: icon.codePoint,
        colorValue: color.toARGB32(),
      );
      await _repository.updateCategory(updated);
      await loadCategories(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCategoryStatus(Category category) async {
    try {
      final updatedCategory = category.copyWith(isEnabled: !category.isEnabled);
      await _repository.updateCategory(updatedCategory);
      await loadCategories(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes category only when no expense references it and [Category.isSystem] is false.
  Future<bool> deleteCategory(String id) async {
    try {
      final cat = await _repository.getCategoryById(id);
      if (cat == null) return false;
      if (cat.isSystem) {
        _error = 'Built-in categories cannot be deleted.';
        notifyListeners();
        return false;
      }
      final n = await _repository.countExpenseReferences(id);
      if (n > 0) {
        _error =
            'Cannot delete: $n expense(s) use this category. Change those expenses first.';
        notifyListeners();
        return false;
      }
      await _repository.deleteCategory(id);
      await loadCategories(showLoading: false);
      return true;
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
