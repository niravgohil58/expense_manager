/// Enum for udhar types
enum UdharType {
  dena, // Money you gave (receivable)
  lena; // Money you took (payable)

  String get displayName {
    switch (this) {
      case UdharType.dena:
        return 'Lent (they owe you)';
      case UdharType.lena:
        return 'Borrowed (you owe)';
    }
  }

  String get shortName {
    switch (this) {
      case UdharType.dena:
        return 'Receivable';
      case UdharType.lena:
        return 'Payable';
    }
  }

  static UdharType fromString(String value) {
    return UdharType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UdharType.dena,
    );
  }
}

/// Enum for udhar status
enum UdharStatus {
  pending,
  partial,
  completed;

  String get displayName {
    switch (this) {
      case UdharStatus.pending:
        return 'Pending';
      case UdharStatus.partial:
        return 'Partial';
      case UdharStatus.completed:
        return 'Completed';
    }
  }

  static UdharStatus fromString(String value) {
    return UdharStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UdharStatus.pending,
    );
  }
}

/// Informal IOU (money lent or borrowed with someone).
class Udhar {
  final String id;
  final String personName;
  final UdharType type;
  final double amount;
  final double paidAmount;
  final String accountId;
  final UdharStatus status;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Udhar({
    required this.id,
    required this.personName,
    required this.type,
    required this.amount,
    required this.paidAmount,
    required this.accountId,
    required this.status,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get pending amount (amount - paidAmount)
  double get pendingAmount => amount - paidAmount;

  /// Check if udhar is fully settled
  bool get isSettled => pendingAmount <= 0;

  /// Create Udhar from database map
  factory Udhar.fromMap(Map<String, dynamic> map) {
    return Udhar(
      id: map['id'] as String,
      personName: map['personName'] as String,
      type: UdharType.fromString(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      accountId: map['accountId'] as String,
      status: UdharStatus.fromString(map['status'] as String),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Convert Udhar to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'type': type.name,
      'amount': amount,
      'paidAmount': paidAmount,
      'accountId': accountId,
      'status': status.name,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Udhar copyWith({
    String? id,
    String? personName,
    UdharType? type,
    double? amount,
    double? paidAmount,
    String? accountId,
    UdharStatus? status,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Udhar(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      accountId: accountId ?? this.accountId,
      status: status ?? this.status,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Udhar(id: $id, person: $personName, type: $type, amount: $amount, pending: $pendingAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Udhar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
