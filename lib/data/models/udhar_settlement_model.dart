/// UdharSettlement model representing a partial or full settlement
class UdharSettlement {
  final String id;
  final String udharId;
  final double amount;
  final String accountId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  const UdharSettlement({
    required this.id,
    required this.udharId,
    required this.amount,
    required this.accountId,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Create UdharSettlement from database map
  factory UdharSettlement.fromMap(Map<String, dynamic> map) {
    return UdharSettlement(
      id: map['id'] as String,
      udharId: map['udharId'] as String,
      amount: (map['amount'] as num).toDouble(),
      accountId: map['accountId'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert UdharSettlement to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'udharId': udharId,
      'amount': amount,
      'accountId': accountId,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UdharSettlement copyWith({
    String? id,
    String? udharId,
    double? amount,
    String? accountId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return UdharSettlement(
      id: id ?? this.id,
      udharId: udharId ?? this.udharId,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UdharSettlement(id: $id, udharId: $udharId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UdharSettlement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
