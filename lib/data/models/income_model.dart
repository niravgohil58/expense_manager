/// Income model representing a source of income
class Income {
  final String id;
  final double amount;
  final String category; // e.g. Salary, Freelance
  final String accountId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Income({
    required this.id,
    required this.amount,
    required this.category,
    required this.accountId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Create Income from database map
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      accountId: map['accountId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert Income to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Income copyWith({
    String? id,
    double? amount,
    String? category,
    String? accountId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
