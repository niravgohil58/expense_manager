/// Sort options for income list queries.
enum IncomeSort {
  dateNewestFirst,
  dateOldestFirst,
  amountHighFirst,
  amountLowFirst,
}

/// Filters for listing/searching incomes (Phase D).
class IncomeFilters {
  const IncomeFilters({
    this.searchQuery,
    this.startDate,
    this.endDate,
    /// Exact match on [Income.category] (free-text label).
    this.categoryLabel,
    this.accountId,
    this.sort = IncomeSort.dateNewestFirst,
  });

  /// Matches note, category label, or amount text (partial).
  final String? searchQuery;

  final DateTime? startDate;
  final DateTime? endDate;

  final String? categoryLabel;
  final String? accountId;

  final IncomeSort sort;

  bool get hasActiveFilters {
    final q = searchQuery?.trim();
    return (q != null && q.isNotEmpty) ||
        startDate != null ||
        endDate != null ||
        (categoryLabel != null && categoryLabel!.trim().isNotEmpty) ||
        accountId != null;
  }

  IncomeFilters copyWith({
    String? searchQuery,
    bool clearSearch = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? categoryLabel,
    bool clearCategoryLabel = false,
    String? accountId,
    bool clearAccount = false,
    IncomeSort? sort,
  }) {
    return IncomeFilters(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      categoryLabel: clearCategoryLabel
          ? null
          : (categoryLabel ?? this.categoryLabel),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      sort: sort ?? this.sort,
    );
  }

  static const IncomeFilters none = IncomeFilters();
}
