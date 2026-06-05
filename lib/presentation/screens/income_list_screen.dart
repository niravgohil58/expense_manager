import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/ads/ads_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../widgets/ads/native_ad_list_tile.dart';
import '../widgets/drawer_host.dart';
import '../../core/constants/text_styles.dart';
import '../../data/models/income_model.dart';
import '../../data/query/income_filters.dart';
import '../providers/account_provider.dart';
import '../providers/income_provider.dart';
import '../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization/l10n_helpers.dart';


/// Income list with search, filters, and sort (Phase D).
class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({super.key});

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

List<String> _distinctIncomeCategoryLabels(List<Income> incomes) {
  final labels = incomes.map((e) => e.category).toSet().toList();
  labels.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return labels;
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final income = context.read<IncomeProvider>();
      await Future.wait([
        income.loadIncomes(),
        context.read<AccountProvider>().loadAccounts(showLoading: false),
      ]);
      if (!mounted) return;
      final q = income.incomeFilters.searchQuery;
      if (q != null && q.isNotEmpty) {
        _searchController.text = q;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  static String? _dropdownCategoryLabel(String? label, List<String> distinct) {
    if (label == null || label.isEmpty) return null;
    return distinct.contains(label) ? label : null;
  }

  static String? _dropdownAccountValue(
    String? id,
    AccountProvider accountProvider,
  ) {
    if (id == null) return null;
    final ok = accountProvider.accounts.any((a) => a.id == id);
    return ok ? id : null;
  }

  void _onSearchChanged(String value, IncomeProvider incomeProvider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final t = value.trim();
      if (t.isEmpty) {
        incomeProvider.setIncomeFilters(
          incomeProvider.incomeFilters.copyWith(clearSearch: true),
        );
      } else {
        incomeProvider.setIncomeFilters(
          incomeProvider.incomeFilters.copyWith(searchQuery: t),
        );
      }
    });
  }

  Future<void> _showFiltersSheet(BuildContext context) async {
    final incomeProvider = context.read<IncomeProvider>();
    final accountProvider = context.read<AccountProvider>();

    IncomeFilters draft = incomeProvider.incomeFilters;
    final distinctCategories = _distinctIncomeCategoryLabels(
      incomeProvider.incomes,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.listFilters, style: AppTextStyles.heading4),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context)!.listDateRange, style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.listAllDates),
                          selected:
                              draft.startDate == null && draft.endDate == null,
                          onSelected: (_) {
                            setModalState(() {
                              draft = draft.copyWith(
                                clearStartDate: true,
                                clearEndDate: true,
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.listThisMonth),
                          selected: _isThisMonth(
                            draft.startDate,
                            draft.endDate,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              final now = DateTime.now();
                              draft = draft.copyWith(
                                startDate: DateTime(now.year, now.month, 1),
                                endDate: DateTime(
                                  now.year,
                                  now.month + 1,
                                  0,
                                  23,
                                  59,
                                  59,
                                ),
                              );
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.listLast30Days),
                          selected: _isLast30Days(
                            draft.startDate,
                            draft.endDate,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              final end = DateTime.now();
                              final start = end.subtract(
                                const Duration(days: 30),
                              );
                              draft = draft.copyWith(
                                startDate: DateTime(
                                  start.year,
                                  start.month,
                                  start.day,
                                ),
                                endDate: DateTime(
                                  end.year,
                                  end.month,
                                  end.day,
                                  23,
                                  59,
                                  59,
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              draft.startDate == null
                                  ? AppLocalizations.of(context)!.listFrom
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(draft.startDate!),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: draft.startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  draft = draft.copyWith(startDate: picked);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event, size: 18),
                            label: Text(
                              draft.endDate == null
                                  ? AppLocalizations.of(context)!.listTo
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(draft.endDate!),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: draft.endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  draft = draft.copyWith(
                                    endDate: DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      23,
                                      59,
                                      59,
                                    ),
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.formCategory),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _dropdownCategoryLabel(
                            draft.categoryLabel,
                            distinctCategories,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(AppLocalizations.of(context)!.listAllCategories),
                            ),
                            ...distinctCategories.map(
                              (name) => DropdownMenuItem<String?>(
                                value: name,
                                child: Text(getCategoryNameFromString(context, name)),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setModalState(() {
                              draft = draft.copyWith(
                                categoryLabel: v,
                                clearCategoryLabel: v == null,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.listAccountLabel),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _dropdownAccountValue(
                            draft.accountId,
                            accountProvider,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(AppLocalizations.of(context)!.listAllAccounts),
                            ),
                            ...accountProvider.accounts.map(
                              (a) => DropdownMenuItem<String?>(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setModalState(() {
                              draft = draft.copyWith(
                                accountId: v,
                                clearAccount: v == null,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.listSortLabel),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<IncomeSort>(
                          isExpanded: true,
                          value: draft.sort,
                          items: [
                            DropdownMenuItem(
                              value: IncomeSort.dateNewestFirst,
                              child: Text(AppLocalizations.of(context)!.listSortNewest),
                            ),
                            DropdownMenuItem(
                              value: IncomeSort.dateOldestFirst,
                              child: Text(AppLocalizations.of(context)!.listSortOldest),
                            ),
                            DropdownMenuItem(
                              value: IncomeSort.amountHighFirst,
                              child: Text(AppLocalizations.of(context)!.listSortHigh),
                            ),
                            DropdownMenuItem(
                              value: IncomeSort.amountLowFirst,
                              child: Text(AppLocalizations.of(context)!.listSortLow),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(
                              () => draft = draft.copyWith(sort: v),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              _searchController.clear();
                              await incomeProvider.clearIncomeFilters();
                            },
                            child: Text(AppLocalizations.of(context)!.listClearAll),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await incomeProvider.setIncomeFilters(draft);
                            },
                            child: Text(AppLocalizations.of(context)!.listApply),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final s = DateTime(now.year, now.month, 1);
    final e = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return start.year == s.year &&
        start.month == s.month &&
        start.day == s.day &&
        end.year == e.year &&
        end.month == e.month &&
        end.day == e.day;
  }

  bool _isLast30Days(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final diff = end.difference(start).inDays;
    return diff >= 28 && diff <= 32;
  }

  Future<bool?> _confirmDeleteIncome(
    BuildContext context,
    Income income,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.listDeleteIncomeTitle),
        content: Text(
          AppLocalizations.of(context)!.listDeleteIncomeConfirmDetail(getCategoryNameFromString(context, income.category)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context)!.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    final provider = context.read<IncomeProvider>();
    final ok = await provider.deleteIncome(income.id);
    if (!context.mounted) return false;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? AppLocalizations.of(context)!.listIncomeDeleteFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return ok;
  }

  Future<void> _refreshIncomeList(BuildContext context) async {
    final accounts = context.read<AccountProvider>();
    final incomes = context.read<IncomeProvider>();
    await accounts.loadAccounts(showLoading: false);
    await incomes.loadIncomes(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: Text(AppLocalizations.of(context)!.titleIncomes),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Consumer2<IncomeProvider, AdsController>(
        builder: (context, provider, ads, _) {
          if (provider.isLoading && provider.incomes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.incomesForList;
          final hasFilters = provider.incomeFilters.hasActiveFilters;

          final insertAfter = ads.nativeInsertAfterItems;
          final insertNative =
              ads.snapshot.showNative && list.length > insertAfter;
          final nativeSlotIndex = insertNative ? insertAfter : -1;
          final extraItems = insertNative ? 1 : 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.listSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setIncomeFilters(
                                provider.incomeFilters.copyWith(
                                  clearSearch: true,
                                ),
                              );
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (v) {
                    setState(() {});
                    _onSearchChanged(v, provider);
                  },
                  onSubmitted: (v) => _onSearchChanged(v, provider),
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (hasFilters || _searchController.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        _searchController.clear();
                        await provider.clearIncomeFilters();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(AppLocalizations.of(context)!.listClearFilters),
                    ),
                  ),
                ),
              if (hasFilters)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            _filterSummary(context, provider.incomeFilters),
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshIncomeList(context),
                  child: list.isEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: _buildEmptyState(
                                  context,
                                  provider,
                                  hasFilters,
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: DesignConstants.screenPadding.copyWith(
                            top: 0,
                          ),
                          itemCount: list.length + extraItems,
                          itemBuilder: (context, index) {
                            if (insertNative && index == nativeSlotIndex) {
                              return const NativeAdListTile();
                            }
                            final dataIndex =
                                insertNative && index > nativeSlotIndex
                                    ? index - 1
                                    : index;
                            final income = list[dataIndex];
                            return Dismissible(
                              key: ValueKey<String>('inc_${income.id}'),
                              direction: DismissDirection.endToStart,
                              background: _IncomeSwipeDeleteBackground(
                                alignment: Alignment.centerRight,
                              ),
                              confirmDismiss: (_) =>
                                  _confirmDeleteIncome(context, income),
                              child: _IncomeCard(income: income),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-income'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _filterSummary(BuildContext context, IncomeFilters f) {
    final parts = <String>[];
    final q = f.searchQuery?.trim();
    if (q != null && q.isNotEmpty) {
      final short = q.length > 28 ? '${q.substring(0, 25)}…' : q;
      parts.add('“$short”');
    }
    if (f.startDate != null || f.endDate != null) {
      final a = f.startDate != null
          ? DateFormat('dd/MM').format(f.startDate!)
          : '…';
      final b = f.endDate != null
          ? DateFormat('dd/MM').format(f.endDate!)
          : '…';
      parts.add(AppLocalizations.of(context)!.listDatesRangeSummary(a, b));
    }
    if (f.categoryLabel != null && f.categoryLabel!.trim().isNotEmpty) {
      parts.add(getCategoryNameFromString(context, f.categoryLabel!.trim()));
    }
    if (f.accountId != null) parts.add(AppLocalizations.of(context)!.listAccountLabel);
    parts.add(_sortLabel(context, f.sort));
    return parts.join(' · ');
  }

  String _sortLabel(BuildContext context, IncomeSort s) {
    final l10n = AppLocalizations.of(context)!;
    switch (s) {
      case IncomeSort.dateNewestFirst:
        return l10n.listSortNewest;
      case IncomeSort.dateOldestFirst:
        return l10n.listSortOldest;
      case IncomeSort.amountHighFirst:
        return l10n.listSortHigh;
      case IncomeSort.amountLowFirst:
        return l10n.listSortLow;
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    IncomeProvider provider,
    bool hasFilters,
  ) {
    if (provider.incomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: DesignConstants.spacingMd),
            Text(
              AppLocalizations.of(context)!.listNoIncomesYet,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignConstants.spacingXs),
            Text(AppLocalizations.of(context)!.listTapToRecordIncome, style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: DesignConstants.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: AppColors.textHint),
            const SizedBox(height: DesignConstants.spacingMd),
            Text(
              hasFilters
                  ? AppLocalizations.of(context)!.listNoIncomeMatches
                  : AppLocalizations.of(context)!.listNoIncomeToShow,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignConstants.spacingMd),
            FilledButton(
              onPressed: () async {
                _searchController.clear();
                await provider.clearIncomeFilters();
                setState(() {});
              },
              child: Text(AppLocalizations.of(context)!.listClearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeSwipeDeleteBackground extends StatelessWidget {
  const _IncomeSwipeDeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: DesignConstants.borderRadiusMd,
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  final Income income;

  const _IncomeCard({required this.income});

  String? _accountName(AccountProvider accounts) {
    for (final a in accounts.accounts) {
      if (a.id == income.accountId) return a.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final formatter =
        AppCurrencyFormat(currencyCode).formatter();
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Consumer<AccountProvider>(
      builder: (context, accounts, _) {
        final accountLabel = _accountName(accounts) ?? income.accountId;

        return InkWell(
          onTap: () => context.push('/add-income', extra: income),
          borderRadius: DesignConstants.borderRadiusMd,
          child: Container(
            margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
            padding: DesignConstants.paddingMd,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: DesignConstants.borderRadiusMd,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: DesignConstants.paddingSm,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: DesignConstants.borderRadiusSm,
                  ),
                  child: Icon(Icons.trending_up, color: AppColors.success),
                ),
                const SizedBox(width: DesignConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getCategoryNameFromString(context, income.category), style: AppTextStyles.labelMedium),
                      Text(
                        dateFormatter.format(income.date),
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        accountLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (income.note != null && income.note!.isNotEmpty)
                        Text(
                          income.note!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  '+ ${formatter.format(income.amount)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
