import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../data/models/udhar_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/udhar_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/drawer_host.dart';

/// Udhar home screen with summary and list
class UdharHomeScreen extends StatefulWidget {
  const UdharHomeScreen({super.key});

  @override
  State<UdharHomeScreen> createState() => _UdharHomeScreenState();
}

class _UdharHomeScreenState extends State<UdharHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UdharProvider>().loadUdhar();
    });
  }

  Future<void> _refreshUdhar(BuildContext context) async {
    final udhar = context.read<UdharProvider>();
    final accounts = context.read<AccountProvider>();
    await udhar.loadUdhar(showLoading: false);
    await accounts.loadAccounts(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: DrawerHost.menuButton(context),
        title: const Text('Udhar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<UdharProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.udharList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => _refreshUdhar(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: DesignConstants.screenPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Aapko Milna Hai',
                                subtitle: 'Money to receive',
                                amount: provider.totalPendingDena,
                                color: AppColors.udharDena,
                                icon: Icons.arrow_downward,
                              ),
                            ),
                            const SizedBox(width: DesignConstants.spacingMd),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Aapko Dena Hai',
                                subtitle: 'Money to pay',
                                amount: provider.totalPendingLena,
                                color: AppColors.udharLena,
                                icon: Icons.arrow_upward,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignConstants.spacingLg),
                        if (provider.pendingUdhar.isEmpty)
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Center(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: DesignConstants.spacingXl,
                                    ),
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(
                                      height: DesignConstants.spacingMd,
                                    ),
                                    Text(
                                      l10n.emptyUdharTitle,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: DesignConstants.spacingXs),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      child: Text(
                                        l10n.emptyUdharSubtitle,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending Udhar',
                                style: AppTextStyles.heading4,
                              ),
                              const SizedBox(height: DesignConstants.spacingSm),
                              ...provider.pendingUdhar.map((udhar) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: DesignConstants.spacingSm,
                                  ),
                                  child: _UdharCard(udhar: udhar),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-udhar'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final formatter =
        AppCurrencyFormat(currencyCode).formatter(decimalDigits: 0);

    return Container(
      padding: DesignConstants.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: DesignConstants.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: DesignConstants.iconSizeSm),
              const SizedBox(width: DesignConstants.spacingXs),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignConstants.spacingXs),
          Text(
            formatter.format(amount),
            style: AppTextStyles.amountMedium.copyWith(color: color),
          ),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _UdharCard extends StatelessWidget {
  final Udhar udhar;

  const _UdharCard({required this.udhar});

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsProvider>().currencyCode;
    final formatter =
        AppCurrencyFormat(currencyCode).formatter(decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy');
    final isDena = udhar.type == UdharType.dena;
    final color = isDena ? AppColors.udharDena : AppColors.udharLena;

    return InkWell(
      onTap: () => context.push('/udhar/${udhar.id}'),
      borderRadius: DesignConstants.borderRadiusMd,
      child: Container(
        padding: DesignConstants.paddingMd,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: DesignConstants.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: DesignConstants.borderRadiusSm,
              ),
              child: Center(
                child: Text(
                  udhar.personName.isEmpty
                      ? '?'
                      : udhar.personName.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ),
            ),
            const SizedBox(width: DesignConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(udhar.personName, style: AppTextStyles.labelMedium),
                  Text(
                    '${isDena ? 'Gave' : 'Took'} on ${dateFormatter.format(udhar.date)}',
                    style: AppTextStyles.caption,
                  ),
                  if (udhar.paidAmount > 0)
                    Text(
                      'Settled: ${formatter.format(udhar.paidAmount)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(udhar.pendingAmount),
                  style: AppTextStyles.amountSmall.copyWith(color: color),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignConstants.spacingXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: DesignConstants.borderRadiusXs,
                  ),
                  child: Text(
                    udhar.type.shortName,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
