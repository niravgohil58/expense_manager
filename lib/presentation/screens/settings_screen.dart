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
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../providers/lock_provider.dart';

import '../providers/settings_provider.dart';
import '../providers/udhar_provider.dart';
import '../widgets/reminders_settings_section.dart';

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
          title: const Text('Backup saved'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'File is in app storage. Copy the path below to upload via '
                'Files, Google Drive, or share manually.',
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
                  const SnackBar(content: Text('Path copied to clipboard')),
                );
              },
              child: const Text('Copy path'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
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
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _import(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This will replace ALL data on this device with the backup file. '
          'Current expenses, accounts, IOUs, and incomes will be overwritten. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Replace data'),
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
          const SnackBar(content: Text('Could not read file')),
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
        const SnackBar(content: Text('Backup restored')),
      );
    } on BackupFormatException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Invalid backup: $e')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
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
          title: const Text('CSV export saved'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Three files in app documents:'),
                const SizedBox(height: 8),
                SelectableText('Accounts:\n$a'),
                const SizedBox(height: 8),
                SelectableText('Expenses:\n$e'),
                const SizedBox(height: 8),
                SelectableText('Incomes:\n$i'),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (context.mounted) {
        await context.read<AdsController>().presentInterstitialIfEligible();
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('CSV export failed: $e')));
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
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer<BackupProvider>(
        builder: (context, backup, _) {
          return Stack(
            children: [
              ListView(
                padding: DesignConstants.screenPadding,
                children: [
                  Text('Appearance', style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode, size: 18),
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
                  const RemindersSettingsSection(),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text('Region & security', style: AppTextStyles.heading4),
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
                                  'Currency',
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
                        title: const Text('Require PIN'),
                        subtitle: const Text(
                          'Locks when returning from background',
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
                                title: const Text('Turn off app lock?'),
                                content: const Text(
                                  'PIN will be removed from secure storage.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Turn off'),
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
                    title: const Text('Change PIN'),
                    subtitle: const Text('Set a new PIN (requires lock enabled)'),
                    onTap: () async {
                      await context.push('/set-pin');
                      if (context.mounted) {
                        await context.read<SettingsProvider>().reloadFromPrefs();
                      }
                    },
                  ),
                  const SizedBox(height: DesignConstants.spacingLg),
                  Text('Data', style: AppTextStyles.heading4),
                  const SizedBox(height: DesignConstants.spacingSm),
                  Text(
                    'Backup contains accounts, categories, expenses, transfers, incomes, IOUs, and settlements. Restore replaces everything locally.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DesignConstants.spacingSm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.upload_file, color: scheme.primary),
                    title: const Text('Export backup'),
                    subtitle: const Text(
                      'Saves JSON to app folder — copy path or upload via Files/Drive',
                    ),
                    onTap: backup.isBusy ? null : () => _export(context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.table_chart_outlined,
                        color: scheme.primary),
                    title: const Text('Export CSV (accounts, expenses, incomes)'),
                    subtitle: const Text(
                      'Three comma-separated files in app documents',
                    ),
                    onTap: backup.isBusy ? null : () => _exportCsv(context),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.download_for_offline_outlined,
                        color: scheme.primary),
                    title: const Text('Restore from backup'),
                    subtitle: const Text(
                      'Choose your backup file (JSON). Replaces local data',
                    ),
                    onTap: backup.isBusy ? null : () => _import(context),
                  ),
                ],
              ),
              if (backup.isBusy)
                const ModalBarrier(
                  dismissible: false,
                  color: Color(0x66000000),
                ),
              if (backup.isBusy)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Working…'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
