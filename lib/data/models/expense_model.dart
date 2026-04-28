import 'category_model.dart';



/// Expense model representing a single expense entry
class Expense {
  final String id;
  final double amount;
  final Category category;
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
      category: Category(
        id: map['categoryId'] as String? ?? 'unknown',
        name: map['categoryName'] as String? ?? 'Unknown',
        iconCode: map['categoryIconCode'] as int? ?? 0xe402, // Default to other
        colorValue: map['categoryColorValue'] as int? ?? 0xFF90A4AE, // Default to grey
        isEnabled: (map['categoryIsEnabled'] as int? ?? 1) == 1,
        isSystem: (map['categoryIsSystem'] as int? ?? 0) == 1,
        createdAt: DateTime.now(), // Placeholder as it's a join
      ),
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
      'category': category.id, // Store category ID
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
    Category? category,
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
    return 'Expense(id: $id, amount: $amount, category: ${category.name}, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
