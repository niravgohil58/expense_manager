import 'package:flutter/material.dart';

/// Exposes [openDrawer] to descendants below [BottomNavShell]'s inner [Scaffold],
/// which owns the [Drawer]. Nested child [Scaffold]s must not call [Scaffold.openDrawer].
class DrawerHost extends InheritedWidget {
  const DrawerHost({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static DrawerHost? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrawerHost>();
  }

  static void open(BuildContext context) {
    maybeOf(context)?.openDrawer();
  }

  static Widget menuButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      tooltip: 'Menu',
      onPressed: () => open(context),
    );
  }

  @override
  bool updateShouldNotify(DrawerHost oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}
