import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../core/ads/ads_controller.dart';

/// Anchored adaptive banner meant for [BottomNavShell] **above** the nav row.
///
/// Remote Config + [AdsController] decide visibility and unit ID.
class ShellBannerSlot extends StatelessWidget {
  const ShellBannerSlot({super.key});

  @override
  Widget build(BuildContext context) {
    final unitId = context.watch<AdsController>().bannerUnitIdOrNull;
    if (unitId == null || unitId.isEmpty) {
      return const SizedBox.shrink();
    }
    return _AdaptiveBannerBody(key: ValueKey<String>(unitId), unitId: unitId);
  }
}

class _AdaptiveBannerBody extends StatefulWidget {
  const _AdaptiveBannerBody({super.key, required this.unitId});

  final String unitId;

  @override
  State<_AdaptiveBannerBody> createState() => _AdaptiveBannerBodyState();
}

class _AdaptiveBannerBodyState extends State<_AdaptiveBannerBody> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  @override
  void didUpdateWidget(covariant _AdaptiveBannerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unitId != widget.unitId) {
      _banner?.dispose();
      _banner = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
    }
  }

  Future<void> _load() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;

    final banner = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('[ExpenseAds] Banner onAdLoaded unit=${widget.unitId}');
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            '[ExpenseAds] Banner FAILED unit=${widget.unitId} '
            'code=${error.code} domain=${error.domain} message=${error.message}',
          );
          ad.dispose();
          if (mounted) setState(() => _banner = null);
        },
      ),
    );

    await banner.load();
    if (!mounted) {
      banner.dispose();
      return;
    }
    setState(() {
      _banner?.dispose();
      _banner = banner;
    });
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) {
      return SizedBox(height: AdSize.banner.height.toDouble());
    }
    return SizedBox(
      width: double.infinity,
      height: banner.size.height.toDouble(),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(child: AdWidget(ad: banner)),
      ),
    );
  }
}
