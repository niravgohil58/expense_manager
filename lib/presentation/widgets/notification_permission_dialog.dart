import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';

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
                  'Enable Notifications',
                  style: AppTextStyles.heading3.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingMd),
                Text(
                  'Expense Manager requires notification permission to send you daily expense reminders, budget warnings, and pending IOU alerts. This helps you stay on top of your finances.',
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
                          'Cancel',
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
                        child: const Text('Allow'),
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
