import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../preferences/app_preferences.dart';
import 'notification_constants.dart';
import 'notification_router.dart';

/// Local notification service for all scheduled and instant notifications.
///
/// Manages channels, scheduling, cancellation, and permission requests.
/// Android & iOS only — silently no-ops on desktop.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance =
      LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isSupportedMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ── Initialisation ───────────────────────────────────────────────────

  Future<void> initialize() async {
    if (!isSupportedMobile || _initialized) return;

    tzdata.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create all Android notification channels.
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.dailyChannelId,
          NotificationConstants.dailyChannelName,
          description: NotificationConstants.dailyChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.monthlyChannelId,
          NotificationConstants.monthlyChannelName,
          description: NotificationConstants.monthlyChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.weeklyChannelId,
          NotificationConstants.weeklyChannelName,
          description: NotificationConstants.weeklyChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.expenseChannelId,
          NotificationConstants.expenseChannelName,
          description: NotificationConstants.expenseChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.iouChannelId,
          NotificationConstants.iouChannelName,
          description: NotificationConstants.iouChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.budgetChannelId,
          NotificationConstants.budgetChannelName,
          description: NotificationConstants.budgetChannelDesc,
          importance: Importance.high,
        ),
      );
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.engagementChannelId,
          NotificationConstants.engagementChannelName,
          description: NotificationConstants.engagementChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    NotificationRouter.handlePayload(response.payload);
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  // ── Permissions ──────────────────────────────────────────────────────

  /// Returns whether notifications are allowed (best-effort on older Android).
  Future<bool> requestPermissionsIfNeeded() async {
    if (!isSupportedMobile) return false;
    await initialize();

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await android?.requestNotificationsPermission();
      return result ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final result = await ios?.requestPermissions(
          alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  // ── Master reschedule ────────────────────────────────────────────────

  /// Cancel all and reschedule every enabled notification from preferences.
  Future<void> rescheduleAllFromPrefs(AppPreferences prefs) async {
    if (!isSupportedMobile) return;
    await initialize();

    // Cancel everything first.
    await _cancelAllScheduled();

    final location = tz.local;

    // 1. Morning reminder
    if (prefs.morningReminderEnabled) {
      await _scheduleDailyReminder(
        id: NotificationConstants.morningReminderId,
        hour: prefs.morningReminderHour,
        minute: prefs.morningReminderMinute,
        title: 'Good morning! 🌅',
        body: "Don't forget to log your expenses today. Keep your finances on track!",
        channelId: NotificationConstants.dailyChannelId,
        channelName: NotificationConstants.dailyChannelName,
        payload: NotificationRouter.buildPayload('/add-expense'),
        location: location,
      );
    }

    // 2. Night reminder
    if (prefs.nightReminderEnabled) {
      await _scheduleDailyReminder(
        id: NotificationConstants.nightReminderId,
        hour: prefs.nightReminderHour,
        minute: prefs.nightReminderMinute,
        title: 'Daily wrap-up 🌙',
        body: 'Did you log all your expenses today? Take a minute to review.',
        channelId: NotificationConstants.dailyChannelId,
        channelName: NotificationConstants.dailyChannelName,
        payload: NotificationRouter.buildPayload('/expenses'),
        location: location,
      );
    }

    // 3. Monthly income reminder (1st of month)
    if (prefs.monthlyIncomeReminderEnabled) {
      await _scheduleMonthlyReminder(
        id: NotificationConstants.monthlyIncomeReminderId,
        day: 1,
        hour: prefs.monthlyIncomeReminderHour,
        minute: prefs.monthlyIncomeReminderMinute,
        title: 'New month, new income! 💰',
        body: "It's the 1st — time to add your salary or income for this month.",
        channelId: NotificationConstants.monthlyChannelId,
        channelName: NotificationConstants.monthlyChannelName,
        payload: NotificationRouter.buildPayload('/add-income'),
        location: location,
      );
    }

    // 4. Monthly report reminder (28th of month)
    if (prefs.monthlyReportReminderEnabled) {
      await _scheduleMonthlyReminder(
        id: NotificationConstants.monthlyReportReminderId,
        day: prefs.monthlyReportReminderDay,
        hour: prefs.monthlyReportReminderHour,
        minute: prefs.monthlyReportReminderMinute,
        title: 'Your monthly report is ready 📊',
        body: 'Review your spending patterns and see where your money went this month.',
        channelId: NotificationConstants.monthlyChannelId,
        channelName: NotificationConstants.monthlyChannelName,
        payload: NotificationRouter.buildPayload('/reports'),
        location: location,
      );
    }

    // 5. Weekly summary reminder
    if (prefs.weeklySummaryReminderEnabled) {
      await _scheduleWeeklyReminder(
        id: NotificationConstants.weeklySummaryReminderId,
        weekday: prefs.weeklySummaryReminderWeekday,
        hour: prefs.weeklySummaryReminderHour,
        minute: prefs.weeklySummaryReminderMinute,
        title: 'Weekly spending check-in 📋',
        body: 'See how much you spent this week and stay on top of your budget.',
        channelId: NotificationConstants.weeklyChannelId,
        channelName: NotificationConstants.weeklyChannelName,
        payload: NotificationRouter.buildPayload('/reports'),
        location: location,
      );
    }

    // 6. Recurring template reminder (existing)
    if (prefs.recurringReminderEnabled) {
      await _scheduleWeeklyReminder(
        id: NotificationConstants.recurringReminderId,
        weekday: prefs.recurringReminderWeekday,
        hour: prefs.recurringReminderHour,
        minute: prefs.recurringReminderMinute,
        title: 'Recurring templates',
        body: 'Review templates and post expenses or income when due.',
        channelId: NotificationConstants.expenseChannelId,
        channelName: NotificationConstants.expenseChannelName,
        payload: NotificationRouter.buildPayload('/recurring-templates'),
        location: location,
      );
    }

    // 7. Backup reminder (existing)
    if (prefs.backupReminderEnabled) {
      await _scheduleWeeklyReminder(
        id: NotificationConstants.backupReminderId,
        weekday: prefs.backupReminderWeekday,
        hour: prefs.backupReminderHour,
        minute: prefs.backupReminderMinute,
        title: 'Backup reminder',
        body: 'Export a backup from Settings to keep your data safe.',
        channelId: NotificationConstants.expenseChannelId,
        channelName: NotificationConstants.expenseChannelName,
        payload: NotificationRouter.buildPayload('/settings'),
        location: location,
      );
    }

    // 8. IOU pending reminder
    if (prefs.iouReminderEnabled) {
      await _scheduleWeeklyReminder(
        id: NotificationConstants.iouPendingReminderId,
        weekday: prefs.iouReminderWeekday,
        hour: prefs.iouReminderHour,
        minute: prefs.iouReminderMinute,
        title: 'Pending IOUs reminder 🤝',
        body: 'Check your pending IOUs — settle what you owe and collect what others owe you!',
        channelId: NotificationConstants.iouChannelId,
        channelName: NotificationConstants.iouChannelName,
        payload: NotificationRouter.buildPayload('/udhar'),
        location: location,
      );
    }

    // 9. Inactivity reminder (daily at 8 PM, actual firing depends on logic)
    if (prefs.inactivityReminderEnabled) {
      await _scheduleDailyReminder(
        id: NotificationConstants.inactivityReminderId,
        hour: 20,
        minute: 0,
        title: 'We miss you! 📝',
        body: "You haven't logged any expenses recently. Stay on track with your finances!",
        channelId: NotificationConstants.engagementChannelId,
        channelName: NotificationConstants.engagementChannelName,
        payload: NotificationRouter.buildPayload('/add-expense'),
        location: location,
      );
    }

    debugPrint('[LocalNotifications] rescheduleAllFromPrefs complete');
  }

  /// Legacy method — redirects to [rescheduleAllFromPrefs].
  Future<void> rescheduleFromPrefs(AppPreferences prefs) =>
      rescheduleAllFromPrefs(prefs);

  // ── Instant notifications (budget exceeded) ──────────────────────────

  /// Show an immediate notification when a budget category is exceeded.
  ///
  /// Uses [categoryName] hash to generate a unique notification ID per category
  /// so that each category only shows one alert.
  Future<void> showBudgetExceededAlert({
    required String categoryName,
    required double spent,
    required double limit,
    required String currencyPrefix,
  }) async {
    if (!isSupportedMobile) return;
    await initialize();

    final id = NotificationConstants.budgetExceededBaseId +
        (categoryName.hashCode.abs() % 999);
    final over = spent - limit;

    await _plugin.show(
      id: id,
      title: 'Budget exceeded! ⚠️',
      body:
          "You've spent $currencyPrefix${spent.toStringAsFixed(0)} on $categoryName "
          '— $currencyPrefix${over.toStringAsFixed(0)} over your '
          '$currencyPrefix${limit.toStringAsFixed(0)} budget.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationConstants.budgetChannelId,
          NotificationConstants.budgetChannelName,
          channelDescription: NotificationConstants.budgetChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: NotificationRouter.buildPayload('/budgets'),
    );
  }

  // ── Cancel helpers ───────────────────────────────────────────────────

  Future<void> _cancelAllScheduled() async {
    await _plugin.cancelAll();
  }

  /// Cancel a single notification by ID.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  // ── Scheduling helpers ───────────────────────────────────────────────

  Future<void> _scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
    required tz.Location location,
  }) async {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
        location, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _scheduleWeeklyReminder({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
    required tz.Location location,
  }) async {
    final next = _nextWeeklyOccurrence(location, weekday, hour, minute);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  Future<void> _scheduleMonthlyReminder({
    required int id,
    required int day,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
    required tz.Location location,
  }) async {
    final next = _nextMonthlyOccurrence(location, day, hour, minute);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: payload,
    );
  }

  // ── Date helpers ─────────────────────────────────────────────────────

  static tz.TZDateTime _nextWeeklyOccurrence(
    tz.Location location,
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
        location, now.year, now.month, now.day, hour, minute);
    for (var i = 0; i < 14; i++) {
      if (scheduled.weekday == weekday && scheduled.isAfter(now)) {
        return scheduled;
      }
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.add(const Duration(days: 7));
  }

  static tz.TZDateTime _nextMonthlyOccurrence(
    tz.Location location,
    int day,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(location);
    // Clamp day to valid range for the month.
    int clampedDay(int year, int month) {
      final lastDay = DateTime(year, month + 1, 0).day;
      return day > lastDay ? lastDay : day;
    }

    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      clampedDay(now.year, now.month),
      hour,
      minute,
    );
    if (scheduled.isAfter(now)) return scheduled;

    // Move to next month.
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    return tz.TZDateTime(
      location,
      nextYear,
      nextMonth,
      clampedDay(nextYear, nextMonth),
      hour,
      minute,
    );
  }
}
