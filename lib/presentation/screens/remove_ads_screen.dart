import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../providers/purchase_provider.dart';
import '../../l10n/app_localizations.dart';


/// Screen presenting the "Remove Ads" in-app purchase offer.
class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleRemoveAds),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<PurchaseProvider>(
        builder: (context, purchase, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: DesignConstants.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: DesignConstants.spacingLg),

                    // Hero icon
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.block_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignConstants.spacingLg),

                    // Heading
                    Text(
                      purchase.adsRemoved
                          ? AppLocalizations.of(context)!.adsAdFree
                          : AppLocalizations.of(context)!.adsHeroTitle,
                      style: AppTextStyles.heading3.copyWith(
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignConstants.spacingSm),
                    Text(
                      purchase.adsRemoved
                          ? AppLocalizations.of(context)!.adsHeroSubtitleActive
                          : AppLocalizations.of(context)!.adsHeroSubtitleOffer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignConstants.spacingXl),

                    // Benefits card
                    if (!purchase.adsRemoved) ...[
                      Container(
                        padding: DesignConstants.paddingMd,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: DesignConstants.borderRadiusMd,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.adsWhatYouGet,
                              style: AppTextStyles.heading4.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: DesignConstants.spacingMd),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: AppLocalizations.of(context)!.adsBenefitBanners,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: AppLocalizations.of(context)!.adsBenefitInterstitials,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: AppLocalizations.of(context)!.adsBenefitAppOpen,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: AppLocalizations.of(context)!.adsBenefitNative,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: AppLocalizations.of(context)!.adsBenefitOneTime,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignConstants.spacingXl),

                      // Buy button
                      _RemoveAdsBuyButton(purchase: purchase),
                      const SizedBox(height: DesignConstants.spacingMd),

                      // Restore link
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.restore, size: 18),
                          label: Text(AppLocalizations.of(context)!.adsRestore),
                          onPressed: purchase.purchaseState == PurchaseState.loading
                              ? null
                              : () async {
                                  await purchase.restorePurchases();
                                  if (context.mounted && !purchase.adsRemoved) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)!.adsNoPurchaseFound,
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],

                    // Success state
                    if (purchase.adsRemoved) ...[
                      Container(
                        padding: DesignConstants.paddingLg,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: DesignConstants.borderRadiusMd,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 48,
                            ),
                            const SizedBox(height: DesignConstants.spacingMd),
                            Text(
                              AppLocalizations.of(context)!.adsSuccessTitle,
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            Text(
                              AppLocalizations.of(context)!.adsSuccessBody,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: DesignConstants.spacingLg),
                  ],
                ),
              ),

              // Loading overlay
              if (purchase.purchaseState == PurchaseState.loading) ...[
                const ModalBarrier(
                  dismissible: false,
                  color: Color(0x66000000),
                ),
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.adsProcessing),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      ),
    );
  }
}

class _RemoveAdsBuyButton extends StatelessWidget {
  const _RemoveAdsBuyButton({required this.purchase});

  final PurchaseProvider purchase;

  @override
  Widget build(BuildContext context) {
    final product = purchase.removeAdsProduct;
    final isLoading = purchase.purchaseState == PurchaseState.loading;

    final label = product != null
        ? AppLocalizations.of(context)!.adsRemoveWithPrice(product.price)
        : AppLocalizations.of(context)!.adsRemove;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: isLoading
            ? null
            : () async {
                await purchase.buyRemoveAds();
                if (context.mounted &&
                    purchase.purchaseState == PurchaseState.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        purchase.errorMessage ?? AppLocalizations.of(context)!.adsPurchaseFailed,
                      ),
                    ),
                  );
                  purchase.clearError();
                }
              },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: DesignConstants.borderRadiusMd,
          ),
        ),
        child: product == null
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.success, size: 22),
        const SizedBox(width: DesignConstants.spacingSm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
