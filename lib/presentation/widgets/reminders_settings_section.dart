import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

const List<(int weekday, String label)> _kWeekdayChoices = [
  (DateTime.monday, 'Monday'),
  (DateTime.tuesday, 'Tuesday'),
  (DateTime.wednesday, 'Wednesday'),
  (DateTime.thursday, 'Thursday'),
  (DateTime.friday, 'Friday'),
  (DateTime.saturday, 'Saturday'),
  (DateTime.sunday, 'Sunday'),
];

/// Local weekly reminders (Android / iOS). Settings-backed.
class RemindersSettingsSection extends StatelessWidget {
  const RemindersSettingsSection({super.key});

  static String _timeLabel(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(
    BuildContext context,
    SettingsProvider settings, {
    required bool recurring,
  }) async {
    final initial = TimeOfDay(
      hour: recurring ? settings.recurringReminderHour : settings.backupReminderHour,
      minute: recurring ? settings.recurringReminderMinute : settings.backupReminderMinute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !context.mounted) return;
    if (recurring) {
      await settings.setRecurringReminderTime(picked.hour, picked.minute);
    } else {
      await settings.setBackupReminderTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final notifications = LocalNotificationService.instance;

    if (!notifications.isSupportedMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsRemindersTitle, style: AppTextStyles.heading4),
          const SizedBox(height: DesignConstants.spacingSm),
          Text(
            l10n.settingsRemindersUnavailable,
            style: AppTextStyles.bodySmall.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: DesignConstants.spacingLg),
        ],
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsRemindersTitle, style: AppTextStyles.heading4),
            const SizedBox(height: DesignConstants.spacingSm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.repeat_rounded, color: scheme.primary),
              title: Text(l10n.settingsRecurringReminderTitle),
              subtitle: Text(l10n.settingsRecurringReminderSubtitle),
              value: settings.recurringReminderEnabled,
              onChanged: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                if (v) {
                  final ok =
                      await LocalNotificationService.instance.requestPermissionsIfNeeded();
                  if (!context.mounted) return;
                  if (!ok) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.settingsReminderPermissionDenied)),
                    );
                    return;
                  }
                }
                await settings.setRecurringReminderEnabled(v);
              },
            ),
            if (settings.recurringReminderEnabled) ...[
              Padding(
                padding: const EdgeInsets.only(left: 48, right: 0, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsReminderPickWeekday,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: settings.recurringReminderWeekday,
                              items: _kWeekdayChoices
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.$1,
                                      child: Text(e.$2),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (wd) {
                                if (wd != null) {
                                  settings.setRecurringReminderWeekday(wd);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => _pickTime(context, settings, recurring: true),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _timeLabel(
                          settings.recurringReminderHour,
                          settings.recurringReminderMinute,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.backup_rounded, color: scheme.primary),
              title: Text(l10n.settingsBackupReminderTitle),
              subtitle: Text(l10n.settingsBackupReminderSubtitle),
              value: settings.backupReminderEnabled,
              onChanged: (v) async {
                final messenger = ScaffoldMessenger.of(context);
                if (v) {
                  final ok =
                      await LocalNotificationService.instance.requestPermissionsIfNeeded();
                  if (!context.mounted) return;
                  if (!ok) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.settingsReminderPermissionDenied)),
                    );
                    return;
                  }
                }
                await settings.setBackupReminderEnabled(v);
              },
            ),
            if (settings.backupReminderEnabled) ...[
              Padding(
                padding: const EdgeInsets.only(left: 48, right: 0, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsReminderPickWeekday,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: settings.backupReminderWeekday,
                              items: _kWeekdayChoices
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.$1,
                                      child: Text(e.$2),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (wd) {
                                if (wd != null) {
                                  settings.setBackupReminderWeekday(wd);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () => _pickTime(context, settings, recurring: false),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _timeLabel(
                          settings.backupReminderHour,
                          settings.backupReminderMinute,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
