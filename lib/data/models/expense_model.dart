import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Enum for expense categories
enum ExpenseCategory {
  food,
  travel,
  rent,
  shopping,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.categoryFood;
      case ExpenseCategory.travel:
        return AppColors.categoryTravel;
      case ExpenseCategory.rent:
        return AppColors.categoryRent;
      case ExpenseCategory.shopping:
        return AppColors.categoryShopping;
      case ExpenseCategory.other:
        return AppColors.categoryOther;
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// Expense model representing a single expense entry
class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String accountId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.accountId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Create Expense from database map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(map['category'] as String),
      accountId: map['accountId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert Expense to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Expense copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    String? accountId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
