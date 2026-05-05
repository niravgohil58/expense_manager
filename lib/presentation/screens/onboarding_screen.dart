import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context) async {
    await context.read<AppPreferences>().setOnboardingCompleted(true);
    if (!context.mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final pages = <Widget>[
      _OnboardPage(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.onboardingTitle,
        body: l10n.onboardingSubtitle,
      ),
      _OnboardPage(
        icon: Icons.dashboard_customize_rounded,
        title: l10n.onboardingSlide2Title,
        body: l10n.onboardingSlide2Body,
      ),
      _OnboardPage(
        icon: Icons.cloud_off_rounded,
        title: l10n.onboardingSlide3Title,
        body: l10n.onboardingSlide3Body,
      ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(context),
                child: Text(AppLocalizations.of(context)!.commonSkip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor:
                        i == _page ? scheme.primary : scheme.outlineVariant,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  if (_page < pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finish(context);
                  }
                },
                child: Text(
                  _page < pages.length - 1
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

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 88, color: scheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
