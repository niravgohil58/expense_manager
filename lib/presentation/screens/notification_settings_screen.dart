import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/design_constants.dart';
import '../../core/constants/text_styles.dart';
import '../../core/notifications/local_notification_service.dart';
import '../../core/preferences/app_preferences.dart';

import '../widgets/notification_permission_dialog.dart';

/// Dedicated screen for managing all notification preferences.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late AppPreferences _prefs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefs = context.read<AppPreferences>();
  }

  Future<void> _reschedule() async {
    await LocalNotificationService.instance.rescheduleAllFromPrefs(_prefs);
  }

  Future<bool> _ensurePermission() async {
    final isGranted = await Permission.notification.isGranted;
    if (isGranted) return true;

    if (!mounted) return false;

    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NotificationPermissionDialog(),
    );

    if (allowed == true) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        return true;
      } else {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Please give the permission from settings for notifications to enable this reminder.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
    }
    
    return false;
  }

  Future<void> _pickTime({
    required int currentHour,
    required int currentMinute,
    required Future<void> Function(int hour, int minute) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );
    if (picked == null || !mounted) return;
    await onPicked(picked.hour, picked.minute);
    await _reschedule();
    setState(() {});
  }

  static String _timeLabel(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notifications = LocalNotificationService.instance;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: !notifications.isSupportedMobile
          ? Center(
              child: Padding(
                padding: DesignConstants.screenPadding,
                child: Text(
                  'Notifications are not available on this platform.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: DesignConstants.screenPadding,
              children: [
                // ── Daily Reminders ──────────────────────────────
                _SectionHeader(
                  icon: Icons.wb_sunny_rounded,
                  title: 'Daily Reminders',
                  color: AppColors.accent,
                ),
                const SizedBox(height: DesignConstants.spacingSm),
                _buildDailySection(scheme),
                const SizedBox(height: DesignConstants.spacingLg),

                // ── Monthly ─────────────────────────────────────
                _SectionHeader(
                  icon: Icons.calendar_month_rounded,
                  title: 'Monthly',
                  color: AppColors.primary,
                ),
                const SizedBox(height: DesignConstants.spacingSm),
                _buildMonthlySection(scheme),
                const SizedBox(height: DesignConstants.spacingLg),

                // ── Weekly ──────────────────────────────────────
                _SectionHeader(
                  icon: Icons.view_week_rounded,
                  title: 'Weekly',
                  color: AppColors.success,
                ),
                const SizedBox(height: DesignConstants.spacingSm),
                _buildWeeklySection(scheme),
                const SizedBox(height: DesignConstants.spacingLg),

                // ── Smart Alerts ────────────────────────────────
                _SectionHeader(
                  icon: Icons.psychology_rounded,
                  title: 'Smart Alerts',
                  color: AppColors.expense,
                ),
                const SizedBox(height: DesignConstants.spacingSm),
                _buildSmartSection(scheme),
                const SizedBox(height: DesignConstants.spacingXl),
              ],
            ),
      ),
    );
  }

  // ── Daily Section ────────────────────────────────────────────────────

  Widget _buildDailySection(ColorScheme scheme) {
    return _NotificationCard(
      children: [
        _NotificationToggle(
          icon: Icons.wb_sunny_outlined,
          title: 'Morning reminder',
          subtitle: 'Log your expenses every morning',
          value: _prefs.morningReminderEnabled,
          timeLabel: _timeLabel(
              _prefs.morningReminderHour, _prefs.morningReminderMinute),
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setMorningReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.morningReminderHour,
            currentMinute: _prefs.morningReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setMorningReminderHour(h);
              await _prefs.setMorningReminderMinute(m);
            },
          ),
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.nightlight_round,
          title: 'Night reminder',
          subtitle: 'Review your daily spending',
          value: _prefs.nightReminderEnabled,
          timeLabel: _timeLabel(
              _prefs.nightReminderHour, _prefs.nightReminderMinute),
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setNightReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.nightReminderHour,
            currentMinute: _prefs.nightReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setNightReminderHour(h);
              await _prefs.setNightReminderMinute(m);
            },
          ),
        ),
      ],
    );
  }

  // ── Monthly Section ──────────────────────────────────────────────────

  Widget _buildMonthlySection(ColorScheme scheme) {
    return _NotificationCard(
      children: [
        _NotificationToggle(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Income reminder',
          subtitle: 'Add salary on the 1st of every month',
          value: _prefs.monthlyIncomeReminderEnabled,
          timeLabel: _timeLabel(_prefs.monthlyIncomeReminderHour,
              _prefs.monthlyIncomeReminderMinute),
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setMonthlyIncomeReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.monthlyIncomeReminderHour,
            currentMinute: _prefs.monthlyIncomeReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setMonthlyIncomeReminderHour(h);
              await _prefs.setMonthlyIncomeReminderMinute(m);
            },
          ),
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.pie_chart_outline_rounded,
          title: 'Report reminder',
          subtitle:
              'Review your monthly report on the ${_ordinal(_prefs.monthlyReportReminderDay)}',
          value: _prefs.monthlyReportReminderEnabled,
          timeLabel: _timeLabel(_prefs.monthlyReportReminderHour,
              _prefs.monthlyReportReminderMinute),
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setMonthlyReportReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.monthlyReportReminderHour,
            currentMinute: _prefs.monthlyReportReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setMonthlyReportReminderHour(h);
              await _prefs.setMonthlyReportReminderMinute(m);
            },
          ),
        ),
      ],
    );
  }

  // ── Weekly Section ───────────────────────────────────────────────────

  Widget _buildWeeklySection(ColorScheme scheme) {
    return _NotificationCard(
      children: [
        _NotificationToggle(
          icon: Icons.summarize_outlined,
          title: 'Weekly summary',
          subtitle: 'Check your weekly spending',
          value: _prefs.weeklySummaryReminderEnabled,
          timeLabel: _timeLabel(_prefs.weeklySummaryReminderHour,
              _prefs.weeklySummaryReminderMinute),
          weekday: _prefs.weeklySummaryReminderWeekday,
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setWeeklySummaryReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.weeklySummaryReminderHour,
            currentMinute: _prefs.weeklySummaryReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setWeeklySummaryReminderHour(h);
              await _prefs.setWeeklySummaryReminderMinute(m);
            },
          ),
          onWeekdayChanged: (wd) async {
            await _prefs.setWeeklySummaryReminderWeekday(wd);
            await _reschedule();
            setState(() {});
          },
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.repeat_rounded,
          title: 'Recurring templates',
          subtitle: 'Post recurring expenses or income',
          value: _prefs.recurringReminderEnabled,
          timeLabel: _timeLabel(_prefs.recurringReminderHour,
              _prefs.recurringReminderMinute),
          weekday: _prefs.recurringReminderWeekday,
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setRecurringReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.recurringReminderHour,
            currentMinute: _prefs.recurringReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setRecurringReminderHour(h);
              await _prefs.setRecurringReminderMinute(m);
            },
          ),
          onWeekdayChanged: (wd) async {
            await _prefs.setRecurringReminderWeekday(wd);
            await _reschedule();
            setState(() {});
          },
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.backup_outlined,
          title: 'Backup reminder',
          subtitle: 'Export a backup to keep data safe',
          value: _prefs.backupReminderEnabled,
          timeLabel: _timeLabel(
              _prefs.backupReminderHour, _prefs.backupReminderMinute),
          weekday: _prefs.backupReminderWeekday,
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setBackupReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.backupReminderHour,
            currentMinute: _prefs.backupReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setBackupReminderHour(h);
              await _prefs.setBackupReminderMinute(m);
            },
          ),
          onWeekdayChanged: (wd) async {
            await _prefs.setBackupReminderWeekday(wd);
            await _reschedule();
            setState(() {});
          },
        ),
      ],
    );
  }

  // ── Smart Alerts Section ─────────────────────────────────────────────

  Widget _buildSmartSection(ColorScheme scheme) {
    return _NotificationCard(
      children: [
        _NotificationToggle(
          icon: Icons.handshake_outlined,
          title: 'IOU pending reminder',
          subtitle: 'Settle what you owe and collect dues',
          value: _prefs.iouReminderEnabled,
          timeLabel: _timeLabel(
              _prefs.iouReminderHour, _prefs.iouReminderMinute),
          weekday: _prefs.iouReminderWeekday,
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setIouReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
          onTimeTap: () => _pickTime(
            currentHour: _prefs.iouReminderHour,
            currentMinute: _prefs.iouReminderMinute,
            onPicked: (h, m) async {
              await _prefs.setIouReminderHour(h);
              await _prefs.setIouReminderMinute(m);
            },
          ),
          onWeekdayChanged: (wd) async {
            await _prefs.setIouReminderWeekday(wd);
            await _reschedule();
            setState(() {});
          },
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.warning_amber_rounded,
          title: 'Budget exceeded',
          subtitle: 'Alert when spending exceeds budget',
          value: _prefs.budgetAlertEnabled,
          onChanged: (v) async {
            await _prefs.setBudgetAlertEnabled(v);
            setState(() {});
          },
        ),
        const Divider(height: 1),
        _NotificationToggle(
          icon: Icons.edit_notifications_outlined,
          title: 'Inactivity nudge',
          subtitle: 'Remind if no entries for 2 days',
          value: _prefs.inactivityReminderEnabled,
          onChanged: (v) async {
            if (v && !await _ensurePermission()) return;
            await _prefs.setInactivityReminderEnabled(v);
            await _reschedule();
            setState(() {});
          },
        ),
      ],
    );
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }
}

// ── Reusable Widgets ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: DesignConstants.spacingSm),
        Text(title, style: AppTextStyles.heading4),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: DesignConstants.borderRadiusMd,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.timeLabel,
    this.onTimeTap,
    this.weekday,
    this.onWeekdayChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? timeLabel;
  final VoidCallback? onTimeTap;
  final int? weekday;
  final ValueChanged<int>? onWeekdayChanged;

  static const List<(int weekday, String label)> _weekdays = [
    (DateTime.monday, 'Mon'),
    (DateTime.tuesday, 'Tue'),
    (DateTime.wednesday, 'Wed'),
    (DateTime.thursday, 'Thu'),
    (DateTime.friday, 'Fri'),
    (DateTime.saturday, 'Sat'),
    (DateTime.sunday, 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignConstants.spacingMd,
        vertical: DesignConstants.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: scheme.onSurfaceVariant),
              const SizedBox(width: DesignConstants.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          if (value && (timeLabel != null || weekday != null))
            Padding(
              padding: const EdgeInsets.only(
                  left: 34, top: DesignConstants.spacingXs),
              child: Row(
                children: [
                  if (weekday != null && onWeekdayChanged != null) ...[
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isDense: true,
                        value: weekday,
                        items: _weekdays
                            .map((e) => DropdownMenuItem(
                                  value: e.$1,
                                  child: Text(e.$2,
                                      style: AppTextStyles.bodySmall),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) onWeekdayChanged!(v);
                        },
                      ),
                    ),
                    const SizedBox(width: DesignConstants.spacingSm),
                  ],
                  if (timeLabel != null && onTimeTap != null)
                    TextButton.icon(
                      onPressed: onTimeTap,
                      icon: const Icon(Icons.schedule, size: 16),
                      label: Text(timeLabel!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
