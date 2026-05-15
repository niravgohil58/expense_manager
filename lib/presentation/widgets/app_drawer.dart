import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/formatting/app_currency.dart';
import '../../l10n/app_localizations.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import '../providers/settings_provider.dart';

/// Navigation drawer for shell routes (opened via [DrawerHost]).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final balanceFormat = AppCurrencyFormat(
      settings.currencyCode,
    ).formatter(decimalDigits: 0);
    final accounts = context.watch<AccountProvider>();

    void push(String path) {
      Navigator.pop(context);
      context.push(path);
    }

    final headerBg = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.08),
      scheme.surface,
    );
    final topInset = MediaQuery.paddingOf(context).top;

    return Drawer(
      backgroundColor: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: headerBg,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primary.withValues(
                          alpha: 0.18,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: scheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.drawerHeaderTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: scheme.onSurface,
                                height: 1.2,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.drawerTotalBalanceLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    balanceFormat.format(accounts.totalBalance),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                          height: 1.15,
                        ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (!auth.firebaseAuthEnabled) {
                        return const SizedBox.shrink();
                      }
                      final email = auth.firebaseUser?.email;
                      if (email == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          email,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: DesignConstants.spacingSm,
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(l10n.drawerProfile),
                  onTap: () => push('/profile'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.drawerMoneyTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded),
                  title: Text(l10n.drawerTransfer),
                  onTap: () => push('/transfer'),
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(l10n.drawerTransferHistory),
                  onTap: () => push('/transfer-history'),
                ),
                ListTile(
                  leading: const Icon(Icons.category_rounded),
                  title: Text(l10n.drawerManageCategories),
                  onTap: () => push('/manage-categories'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(l10n.drawerAddAccount),
                  onTap: () => push('/add-account'),
                ),
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline_rounded),
                  title: Text(l10n.drawerBudgets),
                  onTap: () => push('/budgets'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.drawerDataTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.repeat_rounded),
                  title: Text(l10n.drawerRecurring),
                  onTap: () => push('/recurring-templates'),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.drawerSettings),
                  onTap: () => push('/settings'),
                ),
                Consumer<PurchaseProvider>(
                  builder: (context, purchase, _) {
                    if (purchase.adsRemoved) return const SizedBox.shrink();
                    return ListTile(
                      leading: Icon(Icons.block_rounded, color: AppColors.accent),
                      title: const Text('Remove Ads'),
                      subtitle: const Text('One-time purchase'),
                      onTap: () => push('/remove-ads'),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.drawerSecurityTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(l10n.drawerSetPin),
                  onTap: () => push('/set-pin'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.drawerFooterTitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.waving_hand_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.drawerOnboarding),
                  onTap: () => push('/onboarding'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.drawerTermsConditions),
                  onTap: () => push('/terms'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.drawerPrivacyPolicy),
                  onTap: () => push('/privacy'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(l10n.drawerAbout),
                  onTap: () => push('/about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
