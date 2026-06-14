import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

class SelectLanguageScreen extends StatefulWidget {
  final bool isFirstTime;

  const SelectLanguageScreen({super.key, this.isFirstTime = false});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String? _selectedLanguageCode;

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português', 'flag': '🇧🇷'},
    {
      'code': 'id',
      'name': 'Indonesian',
      'native': 'Bahasa Indonesia',
      'flag': '🇮🇩',
    },
    {'code': 'de', 'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _selectedLanguageCode = settings.languageCode ?? 'en';
  }

  void _handleLanguageSelect(String code) {
    setState(() {
      _selectedLanguageCode = code;
    });
    // Apply language immediately so user gets real-time preview of the UI language
    context.read<SettingsProvider>().setLanguageCode(code);
  }

  void _onContinue() async {
    if (_selectedLanguageCode != null) {
      await context.read<SettingsProvider>().setLanguageCode(
        _selectedLanguageCode,
      );
      if (mounted) {
        if (widget.isFirstTime) {
          context.go(
            '/home',
          ); // GoRouter redirect will send to onboarding or login
        } else {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          widget.isFirstTime
              ? AppLocalizations.of(context)!.titleSelectLanguage
              : AppLocalizations.of(context)!.titleLanguageSettings,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        automaticallyImplyLeading: !widget.isFirstTime,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.isFirstTime) ...[
              Padding(
                padding: const EdgeInsets.all(DesignConstants.spacingLg),
                child: Column(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 64,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: DesignConstants.spacingMd),
                    Text(
                      AppLocalizations.of(context)!.selectLanguageWelcome,
                      style: AppTextStyles.heading2.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignConstants.spacingXs),
                    Text(
                      AppLocalizations.of(context)!.selectLanguageInstruction,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignConstants.spacingMd,
                  vertical: DesignConstants.spacingSm,
                ),
                itemCount: _languages.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: DesignConstants.spacingXs),
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final code = lang['code']!;
                  final isSelected = _selectedLanguageCode == code;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: DesignConstants.borderRadiusMd,
                      side: BorderSide(
                        color: isSelected
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    color: isSelected
                        ? scheme.primary.withValues(alpha: 0.08)
                        : scheme.surfaceContainerLow,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignConstants.spacingMd,
                        vertical: DesignConstants.spacingXs,
                      ),
                      leading: Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        lang['native']!,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected ? scheme.primary : scheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        lang['name']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: scheme.primary)
                          : null,
                      onTap: () => _handleLanguageSelect(code),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignConstants.spacingMd),
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  minimumSize: const Size(
                    double.infinity,
                    DesignConstants.buttonHeightMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: DesignConstants.borderRadiusMd,
                  ),
                ),
                child: Text(
                  widget.isFirstTime
                      ? AppLocalizations.of(context)!.commonContinue
                      : AppLocalizations.of(context)!.commonSave,
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
