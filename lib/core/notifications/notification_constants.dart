/// Centralised notification IDs, channel definitions, and payload keys.
///
/// Every scheduled or instant notification in the app references constants
/// defined here so that IDs are never duplicated across features.
class NotificationConstants {
  NotificationConstants._();

  // ── Notification IDs ─────────────────────────────────────────────────

  /// Daily reminders
  static const int morningReminderId = 91010;
  static const int nightReminderId = 91011;

  /// Monthly reminders
  static const int monthlyIncomeReminderId = 91020;
  static const int monthlyReportReminderId = 91021;

  /// Weekly reminders
  static const int weeklySummaryReminderId = 91030;
  static const int recurringReminderId = 91001; // legacy — keep
  static const int backupReminderId = 91002; // legacy — keep

  /// Smart / data-driven
  static const int iouPendingReminderId = 91040;
  static const int inactivityReminderId = 91050;

  /// Budget exceeded uses a base + hash so each category gets a unique id.
  static const int budgetExceededBaseId = 92000;

  // ── Android Notification Channels ────────────────────────────────────

  static const String dailyChannelId = 'daily_reminders';
  static const String dailyChannelName = 'Daily Reminders';
  static const String dailyChannelDesc =
      'Morning & night expense logging reminders';

  static const String monthlyChannelId = 'monthly_reminders';
  static const String monthlyChannelName = 'Monthly Reminders';
  static const String monthlyChannelDesc = 'Income & report reminders';

  static const String weeklyChannelId = 'weekly_reminders';
  static const String weeklyChannelName = 'Weekly Reminders';
  static const String weeklyChannelDesc = 'Weekly summary check-in';

  static const String expenseChannelId = 'expense_reminders';
  static const String expenseChannelName = 'Expense Reminders';
  static const String expenseChannelDesc =
      'Recurring template and backup reminders';

  static const String iouChannelId = 'iou_reminders';
  static const String iouChannelName = 'IOU Reminders';
  static const String iouChannelDesc = 'Pending IOU settlement reminders';

  static const String budgetChannelId = 'budget_alerts';
  static const String budgetChannelName = 'Budget Alerts';
  static const String budgetChannelDesc = 'Over-budget warnings';

  static const String engagementChannelId = 'engagement_reminders';
  static const String engagementChannelName = 'Engagement';
  static const String engagementChannelDesc = 'Inactivity nudges';

  // ── Payload Keys ─────────────────────────────────────────────────────

  /// JSON key inside the notification payload that specifies the route to
  /// navigate to when the user taps the notification.
  static const String payloadRouteKey = 'route';
}
