// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get drawerMoneyTitle => 'Money';

  @override
  String get drawerTransfer => 'Transfer';

  @override
  String get drawerTransferHistory => 'Transfer history';

  @override
  String get drawerManageCategories => 'Manage categories';

  @override
  String get drawerAddAccount => 'Add account';

  @override
  String get drawerBudgets => 'Budgets';

  @override
  String get drawerDataTitle => 'Data & tools';

  @override
  String get drawerRecurring => 'Recurring templates';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerSecurityTitle => 'Security';

  @override
  String get drawerSetPin => 'App PIN';

  @override
  String get drawerFooterTitle => 'Help';

  @override
  String get drawerOnboarding => 'Introduction';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerHeaderTitle => 'Expense Manager';

  @override
  String get drawerTotalBalanceLabel => 'Total balance';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutBody =>
      'Expense Manager keeps your spending offline on this device. Backup regularly from Settings.';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingSubtitle =>
      'Track expenses, income, accounts, and udhar — all offline.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingSlide2Title => 'Stay organized';

  @override
  String get onboardingSlide2Body =>
      'Accounts, transfers, udhar, and categories stay in one place.';

  @override
  String get onboardingSlide3Title => 'Own your data';

  @override
  String get onboardingSlide3Body =>
      'Records stay on this device unless you backup or export.';

  @override
  String get commonSkip => 'Skip';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsMonthHint => 'Set optional monthly limits per category.';

  @override
  String get budgetsSave => 'Save budgets';

  @override
  String get recurringTitle => 'Recurring templates';

  @override
  String get recurringSubtitle =>
      'Save common entries and post them when due. Enable weekly reminders in Settings.';

  @override
  String get settingsRemindersTitle => 'Reminders';

  @override
  String get settingsRemindersUnavailable =>
      'Local reminders are available on Android and iOS devices.';

  @override
  String get settingsRecurringReminderTitle => 'Weekly recurring reminder';

  @override
  String get settingsRecurringReminderSubtitle =>
      'Nudge to review recurring templates and post when due.';

  @override
  String get settingsBackupReminderTitle => 'Weekly backup reminder';

  @override
  String get settingsBackupReminderSubtitle =>
      'Reminder to export a backup from Settings.';

  @override
  String get settingsReminderPickWeekday => 'Day';

  @override
  String get settingsReminderPermissionDenied =>
      'Notification permission is required for reminders.';

  @override
  String get recurringPostNow => 'Post now';

  @override
  String get recurringAdd => 'Add template';

  @override
  String get recurringKindExpense => 'Expense';

  @override
  String get recurringKindIncome => 'Income';

  @override
  String get errorGoHome => 'Go home';

  @override
  String get reportNetMonthlyTitle => 'Net cash flow (income − expense)';

  @override
  String get emptyUdharTitle => 'No udhar yet';

  @override
  String get emptyUdharSubtitle =>
      'Tap + to record money you lent or borrowed.';

  @override
  String get commonGotIt => 'Got it';
}
