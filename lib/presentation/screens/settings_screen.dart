import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ads/ads_controller.dart';
import '../../core/constants/supported_currencies.dart';
import '../../core/database/database_helper.dart';
import '../../data/export/csv_export_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../data/backup/backup_service.dart';
import '../providers/account_provider.dart';
import '../providers/backup_provider.dart';
import '../providers/category_provider.dart';
import '../../l10n/app_localizations.dart';

import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/lock_provider.dart';
import '../providers/purchase_provider.dart';

import '../providers/settings_provider.dart';
import '../providers/udhar_provider.dart';

/// Hub for app preferences and backup / restore.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _reloadAllData(BuildContext context) async {
    await Future.wait([
      context.read<AccountProvider>().loadAccounts(showLoading: false),
      context.read<ExpenseProvider>().loadAll(showLoading: false),
      context.read<CategoryProvider>().loadCategories(showLoading: false),
      context.read<UdharProvider>().loadUdhar(showLoading: false),
      context.read<IncomeProvider>().loadIncomes(showLoading: false),
    ]);
  }

  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await context.read<BackupProvider>().exportToDocumentsFile();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsBackupSaved),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.settingsBackupSavedSubtitle,
              ),
              const SizedBox(height: 12),
              SelectableText(path),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: path));
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.settingsPathCopied)),
                );
              },
              child: Text(AppLocalizations.of(context)!.settingsCopyPath),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.commonGotIt),
            ),
          ],
        ),
      );
      if (context.mounted) {
        await context.read<AdsController>().presentInterstitialIfEligible();
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsExportFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _import(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsRestoreBackupTitle),
        content: Text(
          AppLocalizations.of(context)!.settingsRestoreBackupConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.settingsReplaceData),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final backupProvider = context.read<BackupProvider>();

    FilePickerResult? result;
    try {
      // FileType.custom invokes a native path that can fail on some builds;
      // FileType.any + JSON validation is more reliable on Android.
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
    } on MissingPluginException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'File picker unavailable.\n'
              'Stop the app completely, then run: flutter clean && flutter pub get && flutter run\n'
              '$e',
            ),
          ),
        );
      }
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    String? jsonStr;
    if (file.path != null && file.path!.isNotEmpty) {
      jsonStr = await File(file.path!).readAsString();
    } else if (file.bytes != null && file.bytes!.isNotEmpty) {
      jsonStr = utf8.decode(file.bytes!);
    }

    if (jsonStr == null || jsonStr.isEmpty) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsCouldNotReadFile)),
        );
      }
      return;
    }

    try {
      await backupProvider.importFromJsonString(jsonStr);
      if (!context.mounted) return;
      await _reloadAllData(context);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsBackupRestored)),
      );
    } on BackupFormatException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsInvalidBackup(e.toString()))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settingsRestoreFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final svc = CsvExportService(DatabaseHelper.instance);
      final paths = await svc.exportToDocumentsFiles();
      if (!context.mounted) return;
      final (a, e, i) = paths;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsCsvExportSaved),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.settingsThreeFilesSaved),
                const SizedBox(height: 8),
                SelectableText('${AppLocalizations.of(context)!.settingsAccountsLabel}\n$a'),
                const SizedBox(height: 8),
                SelectableText('${AppLocalizations.of(context)!.settingsExpensesLabel}\n$e'),
                const SizedBox(height: 8),
                SelectableText('${AppLocalizations.of(context)!.settingsIncomesLabel}\n$i'),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.commonGotIt),
            ),
          ],
        ),
      );
      if (context.mounted) {
        await context.read<AdsController>().presentInterstitialIfEligible();
      }
    } catch (err) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsCsvExportFailed(err.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context)!.titleSettings),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<BackupProvider>(
        builder: (context, backup, _) {
          return Stack(
            children: [
              ListView(
                padding: DesignConstants.screenPadding,
                children: [
                  Text(AppLocalizations.of(context)!.settingsAppearance, style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(AppLocalizations.of(context)!.settingsSystem),
                            icon: const Icon(Icons.brightness_auto, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(AppLocalizations.of(context)!.settingsLight),
                            icon: const Icon(Icons.light_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(AppLocalizations.of(context)!.settingsDark),
                            icon: const Icon(Icons.dark_mode, size: 18),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) {
                          if (selection.isEmpty) return;
                          settings.setThemeMode(selection.first);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notifications_outlined,
                        color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.titleNotificationSettings),
                    subtitle: Text(
                      AppLocalizations.of(context)!.settingsNotificationSubtitle,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/notification-settings'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.translate_outlined,
                        color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.titleLanguageSettings),
                    subtitle: Text(
                      AppLocalizations.of(context)!.settingsLanguageSubtitle,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/select-language'),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text(AppLocalizations.of(context)!.settingsRegionSecurity, style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(Icons.currency_exchange,
                                color: scheme.primary),
                          ),
                          const SizedBox(width: DesignConstants.spacingSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.settingsCurrency,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButton<String>(
                                  isExpanded: true,
                                  value: kSupportedCurrencyLabels
                                          .containsKey(settings.currencyCode)
                                      ? settings.currencyCode
                                      : 'INR',
                                  items: kSupportedCurrencyLabels.entries
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(
                                            '${e.key} — ${e.value}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) settings.setCurrencyCode(v);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingMd),
                  Consumer2<LockProvider, SettingsProvider>(
                    builder: (context, lock, settings, _) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(Icons.lock_outline, color: scheme.primary),
                        title: Text(AppLocalizations.of(context)!.settingsRequirePin),
                        subtitle: Text(
                          AppLocalizations.of(context)!.settingsRequirePinSubtitle,
                        ),
                        value: settings.appLockEnabled,
                        onChanged: (v) async {
                          if (v) {
                            await context.push('/set-pin');
                            if (context.mounted) {
                              await settings.reloadFromPrefs();
                            }
                          } else {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.settingsTurnOffAppLock),
                                content: Text(
                                  AppLocalizations.of(context)!.settingsTurnOffAppLockConfirm,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(AppLocalizations.of(context)!.commonCancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(AppLocalizations.of(context)!.settingsTurnOff),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true && context.mounted) {
                              await lock.clearPinAndDisable();
                              await settings.reloadFromPrefs();
                            }
                          }
                        },
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.pin_outlined, color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.settingsChangePin),
                    subtitle: Text(AppLocalizations.of(context)!.settingsChangePinSubtitle),
                    onTap: () async {
                      await context.push('/set-pin');
                      if (context.mounted) {
                        await context.read<SettingsProvider>().reloadFromPrefs();
                      }
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text(AppLocalizations.of(context)!.settingsData, style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Text(
                    AppLocalizations.of(context)!.settingsBackupDescription,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingSm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.upload_file, color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.settingsExportBackup),
                    subtitle: Text(
                      AppLocalizations.of(context)!.settingsExportBackupSubtitle,
                    ),
                    onTap: backup.isBusy ? null : () => _export(context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.table_chart_outlined,
                        color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.settingsExportCsv),
                    subtitle: Text(
                      AppLocalizations.of(context)!.settingsExportCsvSubtitle,
                    ),
                    onTap: backup.isBusy ? null : () => _exportCsv(context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.download_for_offline_outlined,
                        color: scheme.primary),
                    title: Text(AppLocalizations.of(context)!.settingsRestoreBackup),
                    subtitle: Text(
                      AppLocalizations.of(context)!.settingsRestoreBackupSubtitle,
                    ),
                    onTap: backup.isBusy ? null : () => _import(context),
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text(AppLocalizations.of(context)!.settingsPurchases, style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Consumer<PurchaseProvider>(
                    builder: (context, purchase, _) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.restore, color: scheme.primary),
                        title: Text(AppLocalizations.of(context)!.settingsRestorePurchases),
                        subtitle: Text(
                          purchase.adsRemoved
                              ? AppLocalizations.of(context)!.settingsAdsAlreadyRemoved
                              : AppLocalizations.of(context)!.settingsRecoverAdFree,
                        ),
                        onTap: purchase.adsRemoved
                            ? null
                            : () async {
                                await purchase.restorePurchases();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        purchase.adsRemoved
                                            ? AppLocalizations.of(context)!.settingsPurchaseRestored
                                            : AppLocalizations.of(context)!.settingsNoPurchaseFound,
                                      ),
                                    ),
                                  );
                                }
                              },
                      );
                    },
                  ),
                ],
              ),
              if (backup.isBusy)
                const ModalBarrier(
                  dismissible: false,
                  color: Color(0x66000000),
                ),
              if (backup.isBusy)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.settingsWorking),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      ),
    );
  }
}
