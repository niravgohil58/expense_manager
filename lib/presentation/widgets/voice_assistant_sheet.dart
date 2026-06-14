import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/voice_command_service.dart';
import '../providers/category_provider.dart';
import '../providers/account_provider.dart';
import '../../core/localization/l10n_helpers.dart';
import '../../data/models/category_model.dart';
import '../../data/models/account_model.dart';

class VoiceAssistantSheet extends StatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  State<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();

  /// Static helper to display the sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantSheet(),
    );
  }
}

class _VoiceAssistantSheetState extends State<VoiceAssistantSheet>
    with SingleTickerProviderStateMixin {
  final VoiceCommandService _voiceService = VoiceCommandService.instance;

  late AnimationController _pulseController;
  String _words = '';
  double _soundLevel = 0.0;
  bool _isListening = false;
  bool _hasError = false;
  String _statusMessage = 'Initializing...';
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Load categories and accounts so we can match them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories(showLoading: false);
      context.read<AccountProvider>().loadAccounts(showLoading: false);
      _startVoiceCapture();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _navigationTimer?.cancel();
    _voiceService.stopListening();
    super.dispose();
  }

  Future<void> _startVoiceCapture() async {
    setState(() {
      _hasError = false;
      _statusMessage = 'Listening... Speak now';
      _isListening = true;
    });

    try {
      await _voiceService.startListening(
        localeId: 'en_US',
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() {
              _isListening = false;
              _statusMessage = 'Listening stopped';
            });
            if (_words.isNotEmpty) {
              _processAndNavigate();
            }
          } else if (status == 'listening') {
            setState(() {
              _isListening = true;
              _statusMessage = 'Listening... Speak now';
            });
          }
        },
        onResult: (text) {
          setState(() {
            _words = text;
          });
          // Debounce navigation so it waits for the user to finish speaking
          _navigationTimer?.cancel();
          _navigationTimer = Timer(const Duration(milliseconds: 1500), () {
            _processAndNavigate();
          });
        },
        onSoundLevelChange: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _isListening = false;
        _statusMessage = 'Voice recognition unavailable. Please try again.';
      });
    }
  }

  Future<void> _stopVoiceCapture() async {
    _navigationTimer?.cancel();
    await _voiceService.stopListening();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
    if (_words.isNotEmpty) {
      _processAndNavigate();
    } else {
      context.pop();
    }
  }

  void _processAndNavigate() {
    if (!mounted) return;
    if (_words.isEmpty) return;

    final categoryList = context.read<CategoryProvider>().categories;
    final Map<String, Category> searchMap = {};

    for (final cat in categoryList) {
      searchMap[cat.name.toLowerCase()] = cat;
      searchMap[getCategoryName(context, cat).toLowerCase()] = cat;
    }

    final accountList = context.read<AccountProvider>().accounts;
    final Map<String, Account> accountSearchMap = {};
    for (final acc in accountList) {
      accountSearchMap[acc.name.toLowerCase()] = acc;
      if (acc.type == AccountType.cash) {
        accountSearchMap['cash'] = acc;
      } else if (acc.type == AccountType.bank) {
        accountSearchMap['bank'] = acc;
      }
    }

    final parsed = _voiceService.parseCommand(
      _words,
      searchMap.keys.toList(),
      accounts: accountSearchMap.keys.toList(),
    );

    // Close bottom sheet
    context.pop();

    // Find matched account ID if parsed
    String? matchedAccountId;
    if (parsed.accountName != null) {
      final matchedAcc = accountSearchMap[parsed.accountName!.toLowerCase()];
      if (matchedAcc != null) {
        matchedAccountId = matchedAcc.id;
      }
    }

    // Route to add-expense or add-income with the parsed parameters
    if (parsed.type == VoiceTransactionType.expense) {
      // Find matching Category object if we have one
      Category? matchedCategory;
      if (parsed.categoryName != null) {
        matchedCategory = searchMap[parsed.categoryName!.toLowerCase()];
      }
      matchedCategory ??= categoryList.firstWhere(
        (c) => c.name.toLowerCase() == 'other',
        orElse: () =>
            categoryList.isNotEmpty ? categoryList.first : categoryList.first,
      );

      context.push(
        '/add-expense',
        extra: {
          'amount': parsed.amount,
          'category': matchedCategory,
          'accountId': matchedAccountId,
          'note': parsed.note,
        },
      );
    } else {
      String categoryName = 'Other';
      if (parsed.categoryName != null) {
        final catObj = searchMap[parsed.categoryName!.toLowerCase()];
        categoryName = catObj != null
            ? getCategoryName(context, catObj)
            : parsed.categoryName!;
      }
      context.push(
        '/add-income',
        extra: {
          'amount': parsed.amount,
          'category': categoryName,
          'accountId': matchedAccountId,
          'note': parsed.note,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(DesignConstants.spacingLg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignConstants.spacingLg),
            Text(
              'Voice Assistant',
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignConstants.spacingXs),
            Text(
              _statusMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _hasError ? AppColors.error : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignConstants.spacingXl),

            // Pulsating mic button
            Center(
              child: GestureDetector(
                onTap: _isListening ? _stopVoiceCapture : _startVoiceCapture,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer soundwave ring
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 100 + (_soundLevel * 4),
                      height: 100 + (_soundLevel * 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (_isListening
                                    ? AppColors.primary
                                    : scheme.outlineVariant)
                                .withValues(alpha: 0.15),
                      ),
                    ),
                    // Inner pulse ring
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.15).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (_isListening
                                      ? AppColors.primary
                                      : scheme.outlineVariant)
                                  .withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    // Core Button
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? AppColors.primary
                            : scheme.surfaceContainerHigh,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening
                            ? AppColors.textOnPrimary
                            : scheme.primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignConstants.spacingXl),

            // Speech text display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignConstants.spacingMd),
              constraints: const BoxConstraints(minHeight: 80),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: DesignConstants.borderRadiusMd,
                border: Border.all(color: scheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                _words.isNotEmpty
                    ? _words
                    : 'Say something like: "Spent 500 on Food for lunch"',
                style: _words.isNotEmpty
                    ? AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      )
                    : AppTextStyles.bodyLarge.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DesignConstants.spacingLg),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                if (_words.isNotEmpty)
                  ElevatedButton(
                    onPressed: _processAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: DesignConstants.borderRadiusMd,
                      ),
                    ),
                    child: const Text('Parse & Go'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
