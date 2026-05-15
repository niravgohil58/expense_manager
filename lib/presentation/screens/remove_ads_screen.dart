import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../providers/purchase_provider.dart';

/// Screen presenting the "Remove Ads" in-app purchase offer.
class RemoveAdsScreen extends StatelessWidget {
  const RemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Remove Ads'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<PurchaseProvider>(
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
                          ? 'You\'re ad-free!'
                          : 'Enjoy an ad-free experience',
                      style: AppTextStyles.heading3.copyWith(
                        color: scheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignConstants.spacingSm),
                    Text(
                      purchase.adsRemoved
                          ? 'Thank you for your support. All ads have been permanently removed.'
                          : 'Remove all ads with a single one-time purchase.',
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
                          color: AppColors.surface,
                          borderRadius: DesignConstants.borderRadiusMd,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What you get',
                              style: AppTextStyles.heading4.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: DesignConstants.spacingMd),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'No banner ads',
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'No interstitial popups',
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'No app-open ads',
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'No native ads in lists',
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            _BenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'One-time purchase — pay once, forever',
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
                          label: const Text('Restore previous purchase'),
                          onPressed: purchase.purchaseState == PurchaseState.loading
                              ? null
                              : () async {
                                  await purchase.restorePurchases();
                                  if (context.mounted && !purchase.adsRemoved) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No previous purchase found.',
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
                              'All ads have been removed',
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DesignConstants.spacingSm),
                            Text(
                              'Your ad-free experience is active. '
                              'This applies to banners, interstitials, native ads, and app-open ads.',
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
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Processing purchase…'),
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
        ? 'Remove Ads — ${product.price}'
        : 'Remove Ads';

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
                        purchase.errorMessage ?? 'Purchase failed.',
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
