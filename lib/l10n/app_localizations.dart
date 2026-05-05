import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @drawerMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get drawerMoneyTitle;

  /// No description provided for @drawerTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get drawerTransfer;

  /// No description provided for @drawerTransferHistory.
  ///
  /// In en, this message translates to:
  /// **'Transfer history'**
  String get drawerTransferHistory;

  /// No description provided for @drawerManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get drawerManageCategories;

  /// No description provided for @drawerAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get drawerAddAccount;

  /// No description provided for @drawerBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get drawerBudgets;

  /// No description provided for @drawerDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & tools'**
  String get drawerDataTitle;

  /// No description provided for @drawerRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring templates'**
  String get drawerRecurring;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get drawerSecurityTitle;

  /// No description provided for @drawerSetPin.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get drawerSetPin;

  /// No description provided for @drawerFooterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get drawerFooterTitle;

  /// No description provided for @drawerOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get drawerOnboarding;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// No description provided for @drawerHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Manager'**
  String get drawerHeaderTitle;

  /// No description provided for @drawerTotalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get drawerTotalBalanceLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Expense Manager keeps your spending offline on this device. Backup regularly from Settings.'**
  String get aboutBody;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track expenses, income, accounts, and udhar — all offline.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Stay organized'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Accounts, transfers, udhar, and categories stay in one place.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Own your data'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Records stay on this device unless you backup or export.'**
  String get onboardingSlide3Body;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Set optional monthly limits per category.'**
  String get budgetsMonthHint;

  /// No description provided for @budgetsSave.
  ///
  /// In en, this message translates to:
  /// **'Save budgets'**
  String get budgetsSave;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring templates'**
  String get recurringTitle;

  /// No description provided for @recurringSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save common entries and post them when due. Enable weekly reminders in Settings.'**
  String get recurringSubtitle;

  /// No description provided for @settingsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsRemindersTitle;

  /// No description provided for @settingsRemindersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Local reminders are available on Android and iOS devices.'**
  String get settingsRemindersUnavailable;

  /// No description provided for @settingsRecurringReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly recurring reminder'**
  String get settingsRecurringReminderTitle;

  /// No description provided for @settingsRecurringReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nudge to review recurring templates and post when due.'**
  String get settingsRecurringReminderSubtitle;

  /// No description provided for @settingsBackupReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly backup reminder'**
  String get settingsBackupReminderTitle;

  /// No description provided for @settingsBackupReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder to export a backup from Settings.'**
  String get settingsBackupReminderSubtitle;

  /// No description provided for @settingsReminderPickWeekday.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get settingsReminderPickWeekday;

  /// No description provided for @settingsReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for reminders.'**
  String get settingsReminderPermissionDenied;

  /// No description provided for @recurringPostNow.
  ///
  /// In en, this message translates to:
  /// **'Post now'**
  String get recurringPostNow;

  /// No description provided for @recurringAdd.
  ///
  /// In en, this message translates to:
  /// **'Add template'**
  String get recurringAdd;

  /// No description provided for @recurringKindExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get recurringKindExpense;

  /// No description provided for @recurringKindIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get recurringKindIncome;

  /// No description provided for @errorGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get errorGoHome;

  /// No description provided for @reportNetMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Net cash flow (income − expense)'**
  String get reportNetMonthlyTitle;

  /// No description provided for @emptyUdharTitle.
  ///
  /// In en, this message translates to:
  /// **'No udhar yet'**
  String get emptyUdharTitle;

  /// No description provided for @emptyUdharSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record money you lent or borrowed.'**
  String get emptyUdharSubtitle;

  /// No description provided for @commonGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
