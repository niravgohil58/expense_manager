import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../../core/ads/ads_controller.dart';

/// Single native template row for expense/income lists.
class NativeAdListTile extends StatefulWidget {
  const NativeAdListTile({super.key});

  @override
  State<NativeAdListTile> createState() => _NativeAdListTileState();
}

class _NativeAdListTileState extends State<NativeAdListTile> {
  NativeAd? _nativeAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load() async {
    if (!mounted) return;
    final ads = context.read<AdsController>();
    final id = ads.nativeUnitIdOrNull;
    if (id == null || id.isEmpty) return;

    final ad = NativeAd(
      adUnitId: id,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failed, error) {
          debugPrint('Native ad failed: $error');
          failed.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        cornerRadius: 10,
      ),
    );

    setState(() {
      _nativeAd?.dispose();
      _nativeAd = ad;
      _loaded = false;
    });

    await ad.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = context.watch<AdsController>();
    if (!ads.snapshot.showNative) return const SizedBox.shrink();

    final ad = _nativeAd;
    if (ad == null || !_loaded) {
      return const SizedBox(height: 120);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 320,
        width: double.infinity,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
