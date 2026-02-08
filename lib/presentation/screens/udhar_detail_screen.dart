import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../data/models/udhar_model.dart';
import '../providers/account_provider.dart';
import '../providers/udhar_provider.dart';

/// Udhar detail screen with settlement history
class UdharDetailScreen extends StatefulWidget {
  final String udharId;

  const UdharDetailScreen({super.key, required this.udharId});

  @override
  State<UdharDetailScreen> createState() => _UdharDetailScreenState();
}

class _UdharDetailScreenState extends State<UdharDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UdharProvider>().loadSettlements(widget.udharId);
    });
  }

  void _showSettlementDialog() {
    final udhar = context.read<UdharProvider>().getUdharById(widget.udharId);
    if (udhar == null) return;

    final amountController = TextEditingController();
    String? selectedAccountId = context.read<AccountProvider>().accounts.first.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Settlement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(udhar.pendingAmount)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: DesignConstants.spacingMd),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${DesignConstants.currencySymbol} ',
                border: OutlineInputBorder(
                  borderRadius: DesignConstants.borderRadiusMd,
                ),
              ),
            ),
            const SizedBox(height: DesignConstants.spacingMd),
            Consumer<AccountProvider>(
              builder: (context, provider, _) {
                return DropdownButtonFormField<String>(
                  initialValue: selectedAccountId,
                  decoration: InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(
                      borderRadius: DesignConstants.borderRadiusMd,
                    ),
                  ),
                  items: provider.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                  onChanged: (value) => selectedAccountId = value,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty) return;
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) return;

              Navigator.pop(context);
              await context.read<UdharProvider>().addSettlement(
                    udharId: widget.udharId,
                    amount: amount,
                    accountId: selectedAccountId!,
                    date: DateTime.now(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Add Settlement'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: DesignConstants.currencySymbol,
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Udhar Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<UdharProvider>(
        builder: (context, provider, _) {
          final udhar = provider.getUdharById(widget.udharId);
          if (udhar == null) {
            return const Center(child: Text('Udhar not found'));
          }

          final isDena = udhar.type == UdharType.dena;
          final color = isDena ? AppColors.udharDena : AppColors.udharLena;
          final settlements = provider.getSettlements(widget.udharId);

          return SingleChildScrollView(
            padding: DesignConstants.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Udhar Card
                Container(
                  width: double.infinity,
                  padding: DesignConstants.paddingLg,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: DesignConstants.borderRadiusLg,
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: DesignConstants.borderRadiusMd,
                            ),
                            child: Center(
                              child: Text(
                                udhar.personName.substring(0, 1).toUpperCase(),
                                style: AppTextStyles.heading2.copyWith(color: color),
                              ),
                            ),
                          ),
                          const SizedBox(width: DesignConstants.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  udhar.personName,
                                  style: AppTextStyles.heading3,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignConstants.spacingXs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: DesignConstants.borderRadiusXs,
                                  ),
                                  child: Text(
                                    udhar.type.shortName,
                                    style: AppTextStyles.labelSmall.copyWith(color: color),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignConstants.spacingLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoItem(
                            label: 'Total Amount',
                            value: formatter.format(udhar.amount),
                          ),
                          _InfoItem(
                            label: 'Settled',
                            value: formatter.format(udhar.paidAmount),
                            valueColor: AppColors.success,
                          ),
                          _InfoItem(
                            label: 'Pending',
                            value: formatter.format(udhar.pendingAmount),
                            valueColor: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignConstants.spacingMd),
                      Text(
                        'Date: ${dateFormatter.format(udhar.date)}',
                        style: AppTextStyles.bodySmall,
                      ),
                      if (udhar.note != null && udhar.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: DesignConstants.spacingXs),
                          child: Text(
                            'Note: ${udhar.note}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      // Progress Bar
                      const SizedBox(height: DesignConstants.spacingMd),
                      ClipRRect(
                        borderRadius: DesignConstants.borderRadiusSm,
                        child: LinearProgressIndicator(
                          value: udhar.amount > 0 ? udhar.paidAmount / udhar.amount : 0,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingLg),

                // Settlement History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Settlement History', style: AppTextStyles.heading4),
                    if (!udhar.isSettled)
                      TextButton.icon(
                        onPressed: _showSettlementDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                  ],
                ),
                const SizedBox(height: DesignConstants.spacingSm),

                if (settlements.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: DesignConstants.paddingLg,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: DesignConstants.borderRadiusMd,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No settlements yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...settlements.map((settlement) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: DesignConstants.spacingSm),
                      padding: DesignConstants.paddingMd,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: DesignConstants.borderRadiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: DesignConstants.paddingSm,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: DesignConstants.borderRadiusSm,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: DesignConstants.iconSizeSm,
                            ),
                          ),
                          const SizedBox(width: DesignConstants.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatter.format(settlement.amount),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  dateFormatter.format(settlement.date),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<UdharProvider>(
        builder: (context, provider, _) {
          final udhar = provider.getUdharById(widget.udharId);
          if (udhar == null || udhar.isSettled) return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: _showSettlementDialog,
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textOnPrimary,
            icon: const Icon(Icons.add),
            label: const Text('Add Settlement'),
          );
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
