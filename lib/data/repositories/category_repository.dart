import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;

  CategoryRepository({DatabaseHelper? dbHelper, Uuid? uuid})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  static const String _table = 'categories';

  Future<List<Category>> getAllCategories() async {
    final maps = await _dbHelper.queryAll(_table);
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getEnabledCategories() async {
    final maps = await _dbHelper.queryWhere(_table, 'isEnabled = ?', [1]);
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category> addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      iconCode: icon.codePoint,
      colorValue: color.toARGB32(),
      createdAt: DateTime.now(),
    );
    await _dbHelper.insert(_table, category.toMap());
    return category;
  }

  Future<void> updateCategory(Category category) async {
    await _dbHelper.update(_table, category.toMap(), category.id);
  }

  Future<Category?> getCategoryById(String id) async {
    final map = await _dbHelper.queryById(_table, id);
    return map != null ? Category.fromMap(map) : null;
  }
}
