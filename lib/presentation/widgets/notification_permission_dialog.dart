import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';


class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: DesignConstants.borderRadiusLg,
      ),
      backgroundColor: scheme.surface,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignConstants.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DesignConstants.spacingXs),
                Text(
                  AppLocalizations.of(context)!.notifDialogTitle,
                  style: AppTextStyles.heading3.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingMd),
                Text(
                  AppLocalizations.of(context)!.notifDialogBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingLg),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          AppLocalizations.of(context)!.commonCancel,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: DesignConstants.spacingSm),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: DesignConstants.borderRadiusSm,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignConstants.spacingLg,
                            vertical: DesignConstants.spacingSm,
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.commonAllow),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
        ],
      ),
    );
  }
}
