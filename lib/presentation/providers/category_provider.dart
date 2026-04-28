import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Category> get enabledCategories => _categories.where((c) => c.isEnabled).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _isLoading = false;
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
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCategoryStatus(Category category) async {
    try {
      final updatedCategory = category.copyWith(isEnabled: !category.isEnabled);
      await _repository.updateCategory(updatedCategory);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }
}
