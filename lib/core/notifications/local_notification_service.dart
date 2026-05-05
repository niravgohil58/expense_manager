import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../preferences/app_preferences.dart';

/// Weekly local reminders (no Firebase). Android & iOS only.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const int recurringReminderNotificationId = 91001;
  static const int backupReminderNotificationId = 91002;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'expense_reminders',
    'Reminders',
    description: 'Weekly recurring-template and backup reminders',
    importance: Importance.defaultImportance,
  );

  bool get isSupportedMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (!isSupportedMobile || _initialized) return;

    tzdata.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    );

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {
        // tz.database always includes UTC
      }
    }
  }

  /// Returns whether notifications are allowed (best-effort on older Android).
  Future<bool> requestPermissionsIfNeeded() async {
    if (!isSupportedMobile) return false;
    await initialize();

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final result = await android?.requestNotificationsPermission();
      return result ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final result = await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  Future<void> rescheduleFromPrefs(AppPreferences prefs) async {
    if (!isSupportedMobile) return;
    await initialize();

    await _plugin.cancel(id: recurringReminderNotificationId);
    await _plugin.cancel(id: backupReminderNotificationId);

    final location = tz.local;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    if (prefs.recurringReminderEnabled) {
      final next = _nextWeeklyOccurrence(
        location,
        prefs.recurringReminderWeekday,
        prefs.recurringReminderHour,
        prefs.recurringReminderMinute,
      );
      await _plugin.zonedSchedule(
        id: recurringReminderNotificationId,
        title: 'Recurring templates',
        body: 'Review templates and post expenses or income when due.',
        scheduledDate: next,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    if (prefs.backupReminderEnabled) {
      final next = _nextWeeklyOccurrence(
        location,
        prefs.backupReminderWeekday,
        prefs.backupReminderHour,
        prefs.backupReminderMinute,
      );
      await _plugin.zonedSchedule(
        id: backupReminderNotificationId,
        title: 'Backup reminder',
        body: 'Export a backup from Settings to keep your data safe.',
        scheduledDate: next,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime _nextWeeklyOccurrence(
    tz.Location location,
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    for (var i = 0; i < 14; i++) {
      if (scheduled.weekday == weekday && scheduled.isAfter(now)) {
        return scheduled;
      }
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled.add(const Duration(days: 7));
  }
}
