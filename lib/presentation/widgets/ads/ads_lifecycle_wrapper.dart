import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/ads/ads_controller.dart';
import '../../providers/lock_provider.dart';

/// App lifecycle bridge for app-open ads (foreground resumes).
class AdsLifecycleWrapper extends StatefulWidget {
  const AdsLifecycleWrapper({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<AdsLifecycleWrapper> createState() => _AdsLifecycleWrapperState();
}

class _AdsLifecycleWrapperState extends State<AdsLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_onForeground()));
    }
  }

  Future<void> _onForeground() async {
    if (!mounted) return;
    final ads = context.read<AdsController>();
    if (!ads.isSupported) return;

    final lock = context.read<LockProvider>();
    final path = widget.router.routeInformationProvider.value.uri.path;

    await ads.maybeShowAppOpen(
      routePath: path,
      lockBlocking: lock.needsLockOverlay,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
