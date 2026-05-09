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
  String get drawerTermsConditions => 'Terms & Conditions';

  @override
  String get drawerPrivacyPolicy => 'Privacy Policy';

  @override
  String get legalAcceptSnackbar =>
      'Please accept the Terms & Conditions and Privacy Policy to continue.';

  @override
  String get onboardingLegalPrefix => 'I have read and agree to the ';

  @override
  String get onboardingLegalMiddle => ' and ';

  @override
  String get onboardingLegalSuffix => '.';

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
      'Everything runs on your phone — no account or sign-in. Stay on top of money without handing data to a server.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingSlide1Bullet1 =>
      'Log expenses and income across multiple accounts.';

  @override
  String get onboardingSlide1Bullet2 =>
      'Use categories and charts to see where money goes.';

  @override
  String get onboardingSlide1Bullet3 =>
      'Track informal IOUs — who lent whom and what\'s still pending.';

  @override
  String get onboardingSlide1Bullet4 => 'Works fully offline after install.';

  @override
  String get onboardingSlide2Title => 'Everything in one place';

  @override
  String get onboardingSlide2Body =>
      'Shape the app around how you actually manage cash, cards, and informal debts.';

  @override
  String get onboardingSlide2Bullet1 =>
      'Move balances between accounts with transfers.';

  @override
  String get onboardingSlide2Bullet2 =>
      'Optional budgets per category and recurring templates for repeats.';

  @override
  String get onboardingSlide2Bullet3 =>
      'Attach receipt photos to expenses when you need proof.';

  @override
  String get onboardingSlide2Bullet4 =>
      'Record IOUs and settlements tied to an account.';

  @override
  String get onboardingSlide3Title => 'Your data stays yours';

  @override
  String get onboardingSlide3Body =>
      'Privacy-first by design — export when you want a backup or spreadsheet.';

  @override
  String get onboardingSlide3Bullet1 =>
      'Records stay on this device unless you export.';

  @override
  String get onboardingSlide3Bullet2 =>
      'Encrypted backup from Settings when you\'re ready.';

  @override
  String get onboardingSlide3Bullet3 =>
      'Optional app PIN so only you open the app.';

  @override
  String get onboardingSlide3Bullet4 =>
      'CSV export when you want to analyse elsewhere.';

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
  String get emptyUdharTitle => 'No IOUs yet';

  @override
  String get emptyUdharSubtitle =>
      'Tap + to record money you lent or borrowed.';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get iouTipsTitle => 'About IOUs';

  @override
  String get iouTipsBody =>
      '• Track lends (they owe you) and borrows (you owe).\n• Totals above show pending amounts from open IOUs.\n• Tap a row for history and settlements.\n• Adding or settling updates the linked account balance.';

  @override
  String get iouTipsHide => 'Hide';

  @override
  String get iouTipsShowTooltip => 'Show tips';
}
