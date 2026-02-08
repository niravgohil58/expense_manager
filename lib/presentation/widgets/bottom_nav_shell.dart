import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';

/// Bottom navigation shell for main app screens
class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.spacingMd,
              vertical: DesignConstants.spacingXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  path: '/home',
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Expenses',
                  path: '/expenses',
                ),
                _NavItem(
                  icon: Icons.people_rounded,
                  label: 'Udhar',
                  path: '/udhar',
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  path: '/reports',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isSelected = currentPath == path;

    return InkWell(
      onTap: () => context.go(path),
      borderRadius: DesignConstants.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.spacingSm,
          vertical: DesignConstants.spacingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: DesignConstants.iconSizeMd,
            ),
            const SizedBox(height: DesignConstants.spacingXxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
