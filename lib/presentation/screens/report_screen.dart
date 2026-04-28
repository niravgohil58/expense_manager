import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/expense_provider.dart';
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
  List<double> _monthlyData = List.filled(12, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final provider = context.read<ExpenseProvider>();
    final start = DateTime(_selectedYear, 1, 1);
    final end = DateTime(_selectedYear, 12, 31, 23, 59, 59);

    // Load category data
    _categoryData = await provider.getExpensesByCategories(start, end);

    // Load monthly data
    _monthlyData = List.filled(12, 0);
    for (int month = 1; month <= 12; month++) {
      final expenses = await provider.getExpensesForMonth(_selectedYear, month);
      double total = 0;
      for (final expense in expenses) {
        total += expense.amount;
      }
      _monthlyData[month - 1] = total;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: DesignConstants.currencySymbol,
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

                  // Yearly Total
                  Container(
                    width: double.infinity,
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: DesignConstants.borderRadiusMd,
                    ),
                    child: Column(
                      children: [
                        Text('Total Expenses in $_selectedYear',
                            style: AppTextStyles.labelMedium),
                        Text(
                          formatter.format(_monthlyData.fold(0.0, (a, b) => a + b)),
                          style: AppTextStyles.amountLarge.copyWith(
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Monthly Bar Chart
                  Text('Monthly Expenses', style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Container(
                    height: 200,
                    padding: DesignConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _buildBarChart(),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),

                  // Category Pie Chart
                  Text('By Category', style: AppTextStyles.heading4),
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
    );
  }

  Widget _buildBarChart() {
    final maxValue = _monthlyData.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue == 0 ? 1000 : maxValue * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                if (value.toInt() >= 0 && value.toInt() < 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(12, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _monthlyData[index],
                color: AppColors.primary,
                width: 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
