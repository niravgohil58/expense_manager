import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import 'app_drawer.dart';
import 'drawer_host.dart';

/// Bottom navigation shell for main app screens (owns [Drawer]).
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key, required this.child});

  final Widget child;

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DrawerHost(
      openDrawer: _openDrawer,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
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
                    icon: Icons.trending_up_rounded,
                    label: 'Income',
                    path: '/income',
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Expenses',
                    path: '/expenses',
                  ),
                  _NavItem(
                    icon: Icons.people_rounded,
                    label: 'IOUs',
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({required this.icon, required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == path;
    final scheme = Theme.of(context).colorScheme;
    final active = scheme.primary;
    final inactive = scheme.onSurfaceVariant;

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
              color: isSelected ? active : inactive,
              size: DesignConstants.iconSizeMd,
            ),
            const SizedBox(height: DesignConstants.spacingXxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? active : inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
