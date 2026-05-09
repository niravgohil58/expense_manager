import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_constants.dart';
import '../../core/preferences/app_preferences.dart';
import '../../l10n/app_localizations.dart';

/// First-run / replay introduction (marks onboarding completed when finished).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = context.read<AppPreferences>();
      if (prefs.legalTermsAccepted && mounted) {
        setState(() => _termsAccepted = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context, int lastIndex) async {
    final prefs = context.read<AppPreferences>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (!prefs.legalTermsAccepted && !_termsAccepted) {
      await _controller.animateToPage(
        lastIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.legalAcceptSnackbar)));
      return;
    }

    if (_termsAccepted && !prefs.legalTermsAccepted) {
      await prefs.setLegalTermsAccepted(true);
    }

    await prefs.setOnboardingCompleted(true);
    if (!context.mounted) return;
    context.go('/home');
  }

  Future<void> _advance(BuildContext context, int lastIndex) async {
    if (_page < lastIndex) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final prefs = context.read<AppPreferences>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (!prefs.legalTermsAccepted && !_termsAccepted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.legalAcceptSnackbar)));
      return;
    }

    if (!prefs.legalTermsAccepted) {
      await prefs.setLegalTermsAccepted(true);
    }
    await prefs.setOnboardingCompleted(true);
    if (!context.mounted) return;
    context.go('/home');
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final slides = <_OnboardSlideData>[
      _OnboardSlideData(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.onboardingTitle,
        lead: l10n.onboardingSubtitle,
        bullets: [
          l10n.onboardingSlide1Bullet1,
          l10n.onboardingSlide1Bullet2,
          l10n.onboardingSlide1Bullet3,
          l10n.onboardingSlide1Bullet4,
        ],
      ),
      _OnboardSlideData(
        icon: Icons.dashboard_customize_rounded,
        title: l10n.onboardingSlide2Title,
        lead: l10n.onboardingSlide2Body,
        bullets: [
          l10n.onboardingSlide2Bullet1,
          l10n.onboardingSlide2Bullet2,
          l10n.onboardingSlide2Bullet3,
          l10n.onboardingSlide2Bullet4,
        ],
      ),
      _OnboardSlideData(
        icon: Icons.verified_user_rounded,
        title: l10n.onboardingSlide3Title,
        lead: l10n.onboardingSlide3Body,
        bullets: [
          l10n.onboardingSlide3Bullet1,
          l10n.onboardingSlide3Bullet2,
          l10n.onboardingSlide3Bullet3,
          l10n.onboardingSlide3Bullet4,
        ],
      ),
    ];

    final lastIndex = slides.length - 1;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: DesignConstants.screenPaddingHorizontal,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _finish(context, lastIndex),
                  child: Text(l10n.commonSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _OnboardSlidePage(data: slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignConstants.spacingMd,
                DesignConstants.spacingSm,
                DesignConstants.spacingMd,
                DesignConstants.spacingXs,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _page > 0
                        ? IconButton(
                            onPressed: _previousPage,
                            tooltip: l10n.onboardingBack,
                            icon:
                                const Icon(Icons.arrow_back_ios_new_rounded),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: i == _page ? 28 : 8,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(DesignConstants.radiusFull),
                            color: i == _page
                                ? scheme.primary
                                : scheme.outlineVariant
                                    .withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (_page == lastIndex)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignConstants.spacingLg,
                  0,
                  DesignConstants.spacingLg,
                  DesignConstants.spacingSm,
                ),
                child: CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 2,
                    runSpacing: 4,
                    children: [
                      Text(
                        l10n.onboardingLegalPrefix,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              color: scheme.onSurface,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: scheme.primary,
                        ),
                        onPressed: () => context.push('/terms'),
                        child: Text(l10n.drawerTermsConditions),
                      ),
                      Text(
                        l10n.onboardingLegalMiddle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              color: scheme.onSurface,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: scheme.primary,
                        ),
                        onPressed: () => context.push('/privacy'),
                        child: Text(l10n.drawerPrivacyPolicy),
                      ),
                      Text(
                        l10n.onboardingLegalSuffix,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              color: scheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignConstants.spacingLg,
                DesignConstants.spacingSm,
                DesignConstants.spacingLg,
                DesignConstants.spacingLg,
              ),
              child: FilledButton(
                onPressed: () => _advance(context, lastIndex),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                  ),
                ),
                child: Text(
                  _page < lastIndex
                      ? l10n.onboardingNext
                      : l10n.onboardingStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardSlideData {
  const _OnboardSlideData({
    required this.icon,
    required this.title,
    required this.lead,
    required this.bullets,
  });

  final IconData icon;
  final String title;
  final String lead;
  final List<String> bullets;
}

class _OnboardSlidePage extends StatelessWidget {
  const _OnboardSlidePage({required this.data});

  final _OnboardSlideData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConstants.spacingLg,
            vertical: DesignConstants.spacingMd,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DesignConstants.spacingSm),
                Center(child: _OnboardHeroIcon(icon: data.icon)),
                const SizedBox(height: DesignConstants.spacingXl),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingMd),
                Text(
                  data.lead,
                  textAlign: TextAlign.center,
                  style: theme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingLg),
                ...data.bullets.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: DesignConstants.spacingMd,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: DesignConstants.spacingMd),
                        Expanded(
                          child: Text(
                            line,
                            style: theme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              height: 1.42,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignConstants.spacingSm),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardHeroIcon extends StatelessWidget {
  const _OnboardHeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Icon(
      icon,
      size: 84,
      color: scheme.primary,
    );
  }
}
