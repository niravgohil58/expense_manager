import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/category_model.dart';
import '../../l10n/app_localizations.dart';
import '../providers/account_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/drawer_host.dart';
import '../providers/udhar_provider.dart';

/// Report screen with charts
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedYear = DateTime.now().year;
  Map<Category, double> _categoryData = {};
  List<double> _monthlyExpenseData = List.filled(12, 0);
  List<double> _monthlyIncomeData = List.filled(12, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    final expenseProvider = context.read<ExpenseProvider>();
    final incomeProvider = context.read<IncomeProvider>();
    final udharProvider = context.read<UdharProvider>();
    final accountProvider = context.read<AccountProvider>();

    await expenseProvider.loadExpenses(showLoading: !silent);
    if (!mounted) return;
    await incomeProvider.loadIncomes(showLoading: !silent);
    if (!mounted) return;
    await udharProvider.loadUdhar(showLoading: false);
    if (!mounted) return;
    await accountProvider.loadAccounts(showLoading: false);
    if (!mounted) return;

    final start = DateTime(_selectedYear, 1, 1);
    final end = DateTime(_selectedYear, 12, 31, 23, 59, 59);

    _categoryData =
        await expenseProvider.getExpensesByCategories(start, end);

    _monthlyExpenseData = List.filled(12, 0);
    _monthlyIncomeData = List.filled(12, 0);
    for (int month = 1; month <= 12; month++) {
      final expenses =
          await expenseProvider.getExpensesForMonth(_selectedYear, month);
      double expenseTotal = 0;
      for (final expense in expenses) {
        expenseTotal += expense.amount;
      }
      _monthlyExpenseData[month - 1] = expenseTotal;

      final incomes =
          await incomeProvider.getIncomesForMonth(_selectedYear, month);
      double incomeTotal = 0;
      for (final income in incomes) {
        incomeTotal += income.amount;
      }
      _monthlyIncomeData[month - 1] = incomeTotal;
    }

    if (!mounted) return;
    setState(() {
      if (!silent) {
        _isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final formatter =
        AppCurrencyFormat(currencyCode).formatter(decimalDigits: 0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadData(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: DesignConstants.screenPadding,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() => _selectedYear--);
                          _loadData();
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignConstants.spacingMd,
                          vertical: DesignConstants.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: DesignConstants.borderRadiusMd,
                        ),
                        child: Text(
                          '$_selectedYear',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedYear < DateTime.now().year
                            ? () {
                                setState(() => _selectedYear++);
                                _loadData();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Year totals (income vs expense)
                  Builder(
                    builder: (context) {
                      final yearExpense = _monthlyExpenseData.fold<double>(
                        0,
                        (a, b) => a + b,
                      );
                      final yearIncome = _monthlyIncomeData.fold<double>(
                        0,
                        (a, b) => a + b,
                      );
                      final yearNet = yearIncome - yearExpense;
                      return Container(
                        width: double.infinity,
                        padding: DesignConstants.paddingMd,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: DesignConstants.borderRadiusMd,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: DesignConstants.paddingMd,
                                    decoration: BoxDecoration(
                                      color: AppColors.expense.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius:
                                          DesignConstants.borderRadiusMd,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total spent',
                                          style: AppTextStyles.labelSmall,
                                        ),
                                        Text(
                                          formatter.format(yearExpense),
                                          style: AppTextStyles.amountLarge
                                              .copyWith(
                                            color: AppColors.expense,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: DesignConstants.spacingMd),
                                Expanded(
                                  child: Container(
                                    padding: DesignConstants.paddingMd,
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius:
                                          DesignConstants.borderRadiusMd,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total earned',
                                          style: AppTextStyles.labelSmall,
                                        ),
                                        Text(
                                          formatter.format(yearIncome),
                                          style: AppTextStyles.amountLarge
                                              .copyWith(
                                            color: AppColors.income,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignConstants.spacingMd),
                            Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: DesignConstants.spacingSm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Net for $_selectedYear',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${yearNet >= 0 ? '+' : ''}${formatter.format(yearNet)}',
                                  style: AppTextStyles.amountMedium.copyWith(
                                    color: yearNet >= 0
                                        ? AppColors.income
                                        : AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Monthly comparison chart
                  Text(
                    'Income vs expenses by month',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Container(
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 220,
                          child: _buildMonthlyComparisonChart(),
                        ),
                        const SizedBox(height: DesignConstants.spacingSm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _reportLegendChip(
                              color: AppColors.expense,
                              label: 'Spent',
                            ),
                            const SizedBox(width: DesignConstants.spacingMd),
                            _reportLegendChip(
                              color: AppColors.success,
                              label: 'Earned',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  Text(
                    AppLocalizations.of(context)!.reportNetMonthlyTitle,
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Container(
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: List.generate(12, (i) {
                        final net =
                            _monthlyIncomeData[i] - _monthlyExpenseData[i];
                        final mo = DateFormat.MMM()
                            .format(DateTime(_selectedYear, i + 1));
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(mo),
                          trailing: Text(
                            '${net >= 0 ? '+' : ''}${formatter.format(net)}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: net >= 0
                                  ? AppColors.income
                                  : AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Category Pie Chart (expenses only)
                  Text('Expenses by category', style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Container(
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _categoryData.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No expense data'),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: _buildPieChart(),
                              ),
                              const SizedBox(height: DesignConstants.spacingMd),
                              _buildCategoryLegend(formatter),
                            ],
                          ),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Udhar Summary
                  Text('Udhar Summary', style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Consumer<UdharProvider>(
                    builder: (context, provider, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: DesignConstants.paddingMd,
                              decoration: BoxDecoration(
                                color: AppColors.udharDena.withValues(alpha: 0.1),
                                borderRadius: DesignConstants.borderRadiusMd,
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.arrow_downward,
                                      color: AppColors.udharDena),
                                  Text('Milna Hai', style: AppTextStyles.labelSmall),
                                  Text(
                                    formatter.format(provider.totalPendingDena),
                                    style: AppTextStyles.amountSmall.copyWith(
                                      color: AppColors.udharDena,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignConstants.spacingMd),
                          Expanded(
                            child: Container(
                              padding: DesignConstants.paddingMd,
                              decoration: BoxDecoration(
                                color: AppColors.udharLena.withValues(alpha: 0.1),
                                borderRadius: DesignConstants.borderRadiusMd,
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.arrow_upward,
                                      color: AppColors.udharLena),
                                  Text('Dena Hai', style: AppTextStyles.labelSmall),
                                  Text(
                                    formatter.format(provider.totalPendingLena),
                                    style: AppTextStyles.amountSmall.copyWith(
                                      color: AppColors.udharLena,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                ],
              ),
            ),
            ),
    );
  }

  Widget _reportLegendChip({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMonthlyComparisonChart() {
    double maxVal = 0;
    for (int i = 0; i < 12; i++) {
      final e = _monthlyExpenseData[i];
      final inc = _monthlyIncomeData[i];
      if (e > maxVal) maxVal = e;
      if (inc > maxVal) maxVal = inc;
    }
    final maxY = maxVal == 0 ? 1000.0 : maxVal * 1.15;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'J',
                  'F',
                  'M',
                  'A',
                  'M',
                  'J',
                  'J',
                  'A',
                  'S',
                  'O',
                  'N',
                  'D',
                ];
                final i = value.toInt();
                if (i >= 0 && i < 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[i],
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(12, (index) {
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: _monthlyExpenseData[index],
                color: AppColors.expense,
                width: 10,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: _monthlyIncomeData[index],
                color: AppColors.success,
                width: 10,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _categoryData.values.fold(0.0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _categoryData.entries.map((entry) {
          final percentage = total > 0 ? (entry.value / total * 100) : 0;
          return PieChartSectionData(
            color: entry.key.color,
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryLegend(NumberFormat formatter) {
    return Wrap(
      spacing: DesignConstants.spacingMd,
      runSpacing: DesignConstants.spacingSm,
      children: _categoryData.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.key.color,
                borderRadius: DesignConstants.borderRadiusXs,
              ),
            ),
            const SizedBox(width: DesignConstants.spacingXs),
            Text(
              '${entry.key.name}: ${formatter.format(entry.value)}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
