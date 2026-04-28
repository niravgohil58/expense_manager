/// Sort options for expense list queries.
enum ExpenseSort {
  dateNewestFirst,
  dateOldestFirst,
  amountHighFirst,
  amountLowFirst,
}

/// Filters for listing/searching expenses (Phase C).
class ExpenseFilters {
  const ExpenseFilters({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.accountId,
    this.sort = ExpenseSort.dateNewestFirst,
  });

  /// Matches note, category name, or amount text (partial).
  final String? searchQuery;

  final DateTime? startDate;
  final DateTime? endDate;

  final String? categoryId;
  final String? accountId;

  final ExpenseSort sort;

  /// Any narrowing beyond default sort (used for empty-state copy / clear chips).
  bool get hasActiveFilters {
    final q = searchQuery?.trim();
    return (q != null && q.isNotEmpty) ||
        startDate != null ||
        endDate != null ||
        categoryId != null ||
        accountId != null;
  }

  ExpenseFilters copyWith({
    String? searchQuery,
    bool clearSearch = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? categoryId,
    bool clearCategory = false,
    String? accountId,
    bool clearAccount = false,
    ExpenseSort? sort,
  }) {
    return ExpenseFilters(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      sort: sort ?? this.sort,
    );
  }

  /// Default: no filters, newest date first.
  static const ExpenseFilters none = ExpenseFilters();
}
