/// Template for posting recurring expense/income manually ("Post now").
class RecurringTemplate {
  const RecurringTemplate({
    required this.id,
    required this.kindExpense,
    required this.amount,
    required this.categoryRef,
    required this.accountId,
    this.note,
    required this.frequency,
    required this.createdAt,
  });

  /// `true` = expense (categoryRef is category id); `false` = income (categoryRef is label).
  final bool kindExpense;
  final String id;
  final double amount;
  final String categoryRef;
  final String accountId;
  final String? note;
  /// `monthly` or `weekly` (for display / future automation).
  final String frequency;
  final DateTime createdAt;

  factory RecurringTemplate.fromMap(Map<String, dynamic> map) {
    return RecurringTemplate(
      id: map['id'] as String,
      kindExpense: (map['kind'] as String) == 'expense',
      amount: (map['amount'] as num).toDouble(),
      categoryRef: map['categoryRef'] as String,
      accountId: map['accountId'] as String,
      note: map['note'] as String?,
      frequency: map['frequency'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kindExpense ? 'expense' : 'income',
      'amount': amount,
      'categoryRef': categoryRef,
      'accountId': accountId,
      'note': note,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
