/// Transfer model representing money movement between accounts
class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Create Transfer from database map
  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id'] as String,
      fromAccountId: map['fromAccountId'] as String,
      toAccountId: map['toAccountId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert Transfer to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Transfer copyWith({
    String? id,
    String? fromAccountId,
    String? toAccountId,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transfer(
      id: id ?? this.id,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Transfer(id: $id, from: $fromAccountId, to: $toAccountId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transfer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
