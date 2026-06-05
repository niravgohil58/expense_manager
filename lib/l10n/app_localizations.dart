import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('id'),
    Locale('mr'),
    Locale('pt'),
    Locale('ta'),
    Locale('te'),
  ];

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

  /// No description provided for @drawerTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get drawerTermsConditions;

  /// No description provided for @drawerPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get drawerPrivacyPolicy;

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
  /// **'Everything runs on your phone — no account or sign-in. Stay on top of money without handing data to a server.'**
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

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSlide1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Log expenses and income across multiple accounts.'**
  String get onboardingSlide1Bullet1;

  /// No description provided for @onboardingSlide1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Use categories and charts to see where money goes.'**
  String get onboardingSlide1Bullet2;

  /// No description provided for @onboardingSlide1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Track informal IOUs — who lent whom and what\'s still pending.'**
  String get onboardingSlide1Bullet3;

  /// No description provided for @onboardingSlide1Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Works fully offline after install.'**
  String get onboardingSlide1Bullet4;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Everything in one place'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Shape the app around how you actually manage cash, cards, and informal debts.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide2Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Move balances between accounts with transfers.'**
  String get onboardingSlide2Bullet1;

  /// No description provided for @onboardingSlide2Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Optional budgets per category and recurring templates for repeats.'**
  String get onboardingSlide2Bullet2;

  /// No description provided for @onboardingSlide2Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt photos to expenses when you need proof.'**
  String get onboardingSlide2Bullet3;

  /// No description provided for @onboardingSlide2Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Record IOUs and settlements tied to an account.'**
  String get onboardingSlide2Bullet4;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Your data stays yours'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Privacy-first by design — export when you want a backup or spreadsheet.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSlide3Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Records stay on this device unless you export.'**
  String get onboardingSlide3Bullet1;

  /// No description provided for @onboardingSlide3Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup from Settings when you\'re ready.'**
  String get onboardingSlide3Bullet2;

  /// No description provided for @onboardingSlide3Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Optional app PIN so only you open the app.'**
  String get onboardingSlide3Bullet3;

  /// No description provided for @onboardingSlide3Bullet4.
  ///
  /// In en, this message translates to:
  /// **'CSV export when you want to analyse elsewhere.'**
  String get onboardingSlide3Bullet4;

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
  /// **'No IOUs yet'**
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

  /// No description provided for @iouTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'About IOUs'**
  String get iouTipsTitle;

  /// No description provided for @iouTipsBody.
  ///
  /// In en, this message translates to:
  /// **'• Track lends (they owe you) and borrows (you owe).\n• Totals above show pending amounts from open IOUs.\n• Tap a row for history and settlements.\n• Adding or settling updates the linked account balance.'**
  String get iouTipsBody;

  /// No description provided for @iouTipsHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get iouTipsHide;

  /// No description provided for @iouTipsShowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show tips'**
  String get iouTipsShowTooltip;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginRegisterTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your profile securely with Firebase.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get loginPasswordTooShort;

  /// No description provided for @loginPrimarySignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginPrimarySignIn;

  /// No description provided for @loginPrimaryRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginPrimaryRegister;

  /// No description provided for @loginToggleToRegister.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Register'**
  String get loginToggleToRegister;

  /// No description provided for @loginToggleToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get loginToggleToSignIn;

  /// No description provided for @loginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginGoogle;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get loginErrorGeneric;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get profileNotSignedIn;

  /// No description provided for @profileNoDisplayName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileNoDisplayName;

  /// No description provided for @profileUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get profileUserIdLabel;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @titleAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get titleAddAccount;

  /// No description provided for @titleAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get titleAddCategory;

  /// No description provided for @titleEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get titleEditCategory;

  /// No description provided for @titleAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get titleAddExpense;

  /// No description provided for @titleEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get titleEditExpense;

  /// No description provided for @titleAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get titleAddIncome;

  /// No description provided for @titleEditIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get titleEditIncome;

  /// No description provided for @titleAddIou.
  ///
  /// In en, this message translates to:
  /// **'Add IOU'**
  String get titleAddIou;

  /// No description provided for @titleExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get titleExpenses;

  /// No description provided for @titleIncomes.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get titleIncomes;

  /// No description provided for @titleManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get titleManageCategories;

  /// No description provided for @titleNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get titleNotificationSettings;

  /// No description provided for @titleAddTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add Template'**
  String get titleAddTemplate;

  /// No description provided for @titleRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get titleRemoveAds;

  /// No description provided for @titleMonthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get titleMonthlyReport;

  /// No description provided for @titleSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get titleSelectLanguage;

  /// No description provided for @titleLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get titleLanguageSettings;

  /// No description provided for @titleAppSecurityPin.
  ///
  /// In en, this message translates to:
  /// **'App Security PIN'**
  String get titleAppSecurityPin;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @titleTransferHistory.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get titleTransferHistory;

  /// No description provided for @titleTransferBalance.
  ///
  /// In en, this message translates to:
  /// **'Transfer Balance'**
  String get titleTransferBalance;

  /// No description provided for @titleIouDetails.
  ///
  /// In en, this message translates to:
  /// **'IOU Details'**
  String get titleIouDetails;

  /// No description provided for @titleIouDebtTracker.
  ///
  /// In en, this message translates to:
  /// **'IOU Debt Tracker'**
  String get titleIouDebtTracker;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get commonAllow;

  /// No description provided for @notifDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notifDialogTitle;

  /// No description provided for @notifDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Expense Manager requires notification permission to send you daily expense reminders, budget warnings, and pending IOU alerts. This helps you stay on top of your finances.'**
  String get notifDialogBody;

  /// No description provided for @drawerRemoveAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase'**
  String get drawerRemoveAdsSubtitle;

  /// No description provided for @drawerCheckUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for update'**
  String get drawerCheckUpdate;

  /// No description provided for @drawerRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate this app'**
  String get drawerRateApp;

  /// No description provided for @selectLanguageWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Expense Manager'**
  String get selectLanguageWelcome;

  /// No description provided for @selectLanguageInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language to continue.'**
  String get selectLanguageInstruction;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get navIncome;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navIous.
  ///
  /// In en, this message translates to:
  /// **'IOUs'**
  String get navIous;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @udharTypeLent.
  ///
  /// In en, this message translates to:
  /// **'Lent (they owe you)'**
  String get udharTypeLent;

  /// No description provided for @udharTypeBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed (you owe)'**
  String get udharTypeBorrowed;

  /// No description provided for @udharTypeReceivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get udharTypeReceivable;

  /// No description provided for @udharTypePayable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get udharTypePayable;

  /// No description provided for @udharStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get udharStatusPending;

  /// No description provided for @udharStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get udharStatusPartial;

  /// No description provided for @udharStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get udharStatusCompleted;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Budget Tracker'**
  String get homeTitle;

  /// No description provided for @homeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeAccounts;

  /// No description provided for @homeAddAccount.
  ///
  /// In en, this message translates to:
  /// **'ADD ACCOUNT'**
  String get homeAddAccount;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get homeThisMonth;

  /// No description provided for @homeSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get homeSpent;

  /// No description provided for @homeEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get homeEarned;

  /// No description provided for @homeNetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Net this month'**
  String get homeNetThisMonth;

  /// No description provided for @homeRenameAccount.
  ///
  /// In en, this message translates to:
  /// **'Rename Account'**
  String get homeRenameAccount;

  /// No description provided for @homeAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get homeAddMoney;

  /// No description provided for @homeAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get homeAccountName;

  /// No description provided for @homeAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC Bank'**
  String get homeAccountNameHint;

  /// No description provided for @homeAddBalanceTo.
  ///
  /// In en, this message translates to:
  /// **'Add balance to {accountName}'**
  String homeAddBalanceTo(String accountName);

  /// No description provided for @homeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get homeAmount;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage all reminders and alerts'**
  String get settingsNotificationSubtitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app display language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsRegionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Region & security'**
  String get settingsRegionSecurity;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsRequirePin.
  ///
  /// In en, this message translates to:
  /// **'Require PIN'**
  String get settingsRequirePin;

  /// No description provided for @settingsRequirePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Locks when returning from background'**
  String get settingsRequirePinSubtitle;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new PIN (requires lock enabled)'**
  String get settingsChangePinSubtitle;

  /// No description provided for @settingsTurnOffAppLock.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock?'**
  String get settingsTurnOffAppLock;

  /// No description provided for @settingsTurnOffAppLockConfirm.
  ///
  /// In en, this message translates to:
  /// **'PIN will be removed from secure storage.'**
  String get settingsTurnOffAppLockConfirm;

  /// No description provided for @settingsTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get settingsTurnOff;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup contains accounts, categories, expenses, transfers, incomes, IOUs, and settlements. Restore replaces everything locally.'**
  String get settingsBackupDescription;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saves JSON to app folder — copy path or upload via Files/Drive'**
  String get settingsExportBackupSubtitle;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV (accounts, expenses, incomes)'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three comma-separated files in app documents'**
  String get settingsExportCsvSubtitle;

  /// No description provided for @settingsRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsRestoreBackup;

  /// No description provided for @settingsRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your backup file (JSON). Replaces local data'**
  String get settingsRestoreBackupSubtitle;

  /// No description provided for @settingsBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get settingsBackupSaved;

  /// No description provided for @settingsBackupSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'File is in app storage. Copy the path below to upload via Files, Google Drive, or share manually.'**
  String get settingsBackupSavedSubtitle;

  /// No description provided for @settingsCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get settingsCopyPath;

  /// No description provided for @settingsPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Path copied to clipboard'**
  String get settingsPathCopied;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @settingsRestoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get settingsRestoreBackupTitle;

  /// No description provided for @settingsRestoreBackupConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will replace ALL data on this device with the backup file. Current expenses, accounts, IOUs, and incomes will be overwritten. This cannot be undone.'**
  String get settingsRestoreBackupConfirm;

  /// No description provided for @settingsReplaceData.
  ///
  /// In en, this message translates to:
  /// **'Replace data'**
  String get settingsReplaceData;

  /// No description provided for @settingsFilePickerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'File picker unavailable.'**
  String get settingsFilePickerUnavailable;

  /// No description provided for @settingsCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read file'**
  String get settingsCouldNotReadFile;

  /// No description provided for @settingsBackupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get settingsBackupRestored;

  /// No description provided for @settingsInvalidBackup.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup: {error}'**
  String settingsInvalidBackup(String error);

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String settingsRestoreFailed(String error);

  /// No description provided for @settingsCsvExportSaved.
  ///
  /// In en, this message translates to:
  /// **'CSV export saved'**
  String get settingsCsvExportSaved;

  /// No description provided for @settingsThreeFilesSaved.
  ///
  /// In en, this message translates to:
  /// **'Three files in app documents:'**
  String get settingsThreeFilesSaved;

  /// No description provided for @settingsAccountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Accounts:'**
  String get settingsAccountsLabel;

  /// No description provided for @settingsExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses:'**
  String get settingsExpensesLabel;

  /// No description provided for @settingsIncomesLabel.
  ///
  /// In en, this message translates to:
  /// **'Incomes:'**
  String get settingsIncomesLabel;

  /// No description provided for @settingsCsvExportFailed.
  ///
  /// In en, this message translates to:
  /// **'CSV export failed: {error}'**
  String settingsCsvExportFailed(String error);

  /// No description provided for @settingsPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get settingsPurchases;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsAdsAlreadyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Ads already removed'**
  String get settingsAdsAlreadyRemoved;

  /// No description provided for @settingsRecoverAdFree.
  ///
  /// In en, this message translates to:
  /// **'Recover your ad-free purchase'**
  String get settingsRecoverAdFree;

  /// No description provided for @settingsPurchaseRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored!'**
  String get settingsPurchaseRestored;

  /// No description provided for @settingsNoPurchaseFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get settingsNoPurchaseFound;

  /// No description provided for @settingsWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get settingsWorking;

  /// No description provided for @listFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get listFilters;

  /// No description provided for @listDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get listDateRange;

  /// No description provided for @listAllDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get listAllDates;

  /// No description provided for @listThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get listThisMonth;

  /// No description provided for @listLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get listLast30Days;

  /// No description provided for @listAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get listAllCategories;

  /// No description provided for @listAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get listAllAccounts;

  /// No description provided for @listSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Date · newest'**
  String get listSortNewest;

  /// No description provided for @listSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Date · oldest'**
  String get listSortOldest;

  /// No description provided for @listSortHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount · high'**
  String get listSortHigh;

  /// No description provided for @listSortLow.
  ///
  /// In en, this message translates to:
  /// **'Amount · low'**
  String get listSortLow;

  /// No description provided for @listClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get listClearAll;

  /// No description provided for @listApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get listApply;

  /// No description provided for @listClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get listClearFilters;

  /// No description provided for @listDeleteIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete income'**
  String get listDeleteIncomeTitle;

  /// No description provided for @listDeleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get listDeleteExpenseTitle;

  /// No description provided for @listDeleteIncomeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this income?'**
  String get listDeleteIncomeConfirm;

  /// No description provided for @listDeleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get listDeleteExpenseConfirm;

  /// No description provided for @listNoIncomesYet.
  ///
  /// In en, this message translates to:
  /// **'No incomes yet'**
  String get listNoIncomesYet;

  /// No description provided for @listNoExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get listNoExpensesYet;

  /// No description provided for @listTapToRecordIncome.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record income'**
  String get listTapToRecordIncome;

  /// No description provided for @listTapToRecordExpense.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record expense'**
  String get listTapToRecordExpense;

  /// No description provided for @listIncomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Income deleted successfully'**
  String get listIncomeDeleted;

  /// No description provided for @listExpenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get listExpenseDeleted;

  /// No description provided for @listIncomeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete income'**
  String get listIncomeDeleteFailed;

  /// No description provided for @listExpenseDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense'**
  String get listExpenseDeleteFailed;

  /// No description provided for @formAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get formAmount;

  /// No description provided for @formEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get formEnterAmount;

  /// No description provided for @formEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get formEnterValidAmount;

  /// No description provided for @formAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt'**
  String get formAttachReceipt;

  /// No description provided for @formRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get formRemove;

  /// No description provided for @formAttachImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not attach image: {error}'**
  String formAttachImageError(String error);

  /// No description provided for @formSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get formSelectAccount;

  /// No description provided for @formSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get formSelectCategory;

  /// No description provided for @formExpenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get formExpenseUpdated;

  /// No description provided for @formExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get formExpenseAdded;

  /// No description provided for @formExpenseUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense'**
  String get formExpenseUpdateFailed;

  /// No description provided for @formExpenseAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add expense'**
  String get formExpenseAddFailed;

  /// No description provided for @formIncomeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Income updated successfully'**
  String get formIncomeUpdated;

  /// No description provided for @formIncomeAdded.
  ///
  /// In en, this message translates to:
  /// **'Income added successfully'**
  String get formIncomeAdded;

  /// No description provided for @formIncomeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update income'**
  String get formIncomeUpdateFailed;

  /// No description provided for @formIncomeAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add income'**
  String get formIncomeAddFailed;

  /// No description provided for @formCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get formCategory;

  /// No description provided for @formPaymentFrom.
  ///
  /// In en, this message translates to:
  /// **'Payment From'**
  String get formPaymentFrom;

  /// No description provided for @formDepositTo.
  ///
  /// In en, this message translates to:
  /// **'Deposit To'**
  String get formDepositTo;

  /// No description provided for @formDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get formDate;

  /// No description provided for @formNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get formNoteOptional;

  /// No description provided for @formAddNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get formAddNoteHint;

  /// No description provided for @formUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get formUpdateExpense;

  /// No description provided for @formSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get formSaveExpense;

  /// No description provided for @formUpdateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get formUpdateIncome;

  /// No description provided for @formSaveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get formSaveIncome;

  /// No description provided for @formDeleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get formDeleteExpenseTitle;

  /// No description provided for @formDeleteIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Income'**
  String get formDeleteIncomeTitle;

  /// No description provided for @formDeleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get formDeleteExpenseConfirm;

  /// No description provided for @formDeleteIncomeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this income?'**
  String get formDeleteIncomeConfirm;

  /// No description provided for @formManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get formManage;

  /// No description provided for @transferSelectBoth.
  ///
  /// In en, this message translates to:
  /// **'Please select both accounts'**
  String get transferSelectBoth;

  /// No description provided for @transferSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to the same account'**
  String get transferSameAccount;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get transferSuccess;

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get transferFailed;

  /// No description provided for @transferFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get transferFromAccount;

  /// No description provided for @transferToAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get transferToAccount;

  /// No description provided for @transferButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferButton;

  /// No description provided for @transferNoTransfersYet.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet'**
  String get transferNoTransfersYet;

  /// No description provided for @udharLentOn.
  ///
  /// In en, this message translates to:
  /// **'Lent on {date}'**
  String udharLentOn(String date);

  /// No description provided for @udharBorrowedOn.
  ///
  /// In en, this message translates to:
  /// **'Borrowed on {date}'**
  String udharBorrowedOn(String date);

  /// No description provided for @udharSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled: {amount}'**
  String udharSettled(String amount);

  /// No description provided for @udharPersonNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter person name'**
  String get udharPersonNameRequired;

  /// No description provided for @udharPersonNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get udharPersonNameLabel;

  /// No description provided for @udharEnterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get udharEnterNameHint;

  /// No description provided for @udharMoneyGave.
  ///
  /// In en, this message translates to:
  /// **'Money you gave'**
  String get udharMoneyGave;

  /// No description provided for @udharMoneyTook.
  ///
  /// In en, this message translates to:
  /// **'Money you took'**
  String get udharMoneyTook;

  /// No description provided for @udharSaveIou.
  ///
  /// In en, this message translates to:
  /// **'Save IOU'**
  String get udharSaveIou;

  /// No description provided for @udharSaved.
  ///
  /// In en, this message translates to:
  /// **'IOU saved'**
  String get udharSaved;

  /// No description provided for @udharAddSettlement.
  ///
  /// In en, this message translates to:
  /// **'Add Settlement'**
  String get udharAddSettlement;

  /// No description provided for @udharIouNotFound.
  ///
  /// In en, this message translates to:
  /// **'IOU not found'**
  String get udharIouNotFound;

  /// No description provided for @udharTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get udharTotalAmount;

  /// No description provided for @udharSettledLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get udharSettledLabel;

  /// No description provided for @udharPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get udharPendingLabel;

  /// No description provided for @udharDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String udharDetailDate(String date);

  /// No description provided for @udharDetailNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String udharDetailNote(String note);

  /// No description provided for @udharSettlementHistory.
  ///
  /// In en, this message translates to:
  /// **'Settlement History'**
  String get udharSettlementHistory;

  /// No description provided for @udharNoSettlementsYet.
  ///
  /// In en, this message translates to:
  /// **'No settlements yet'**
  String get udharNoSettlementsYet;

  /// No description provided for @reportTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get reportTotalSpent;

  /// No description provided for @reportTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get reportTotalEarned;

  /// No description provided for @reportNetForYear.
  ///
  /// In en, this message translates to:
  /// **'Net for {year}'**
  String reportNetForYear(String year);

  /// No description provided for @reportIncomeVsExpensesByMonth.
  ///
  /// In en, this message translates to:
  /// **'Income vs expenses by month'**
  String get reportIncomeVsExpensesByMonth;

  /// No description provided for @reportNoExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No expense data'**
  String get reportNoExpenseData;

  /// No description provided for @reportExpensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by category'**
  String get reportExpensesByCategory;

  /// No description provided for @reportIouSummary.
  ///
  /// In en, this message translates to:
  /// **'IOU summary'**
  String get reportIouSummary;

  /// No description provided for @budgetsLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit ({prefix})'**
  String budgetsLimitLabel(String prefix);

  /// No description provided for @budgetsSpentProgress.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} / {limit}'**
  String budgetsSpentProgress(String spent, String limit);

  /// No description provided for @recurringPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get recurringPosted;

  /// No description provided for @recurringRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get recurringRemoved;

  /// No description provided for @recurringEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get recurringEnterValidAmount;

  /// No description provided for @recurringSelectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get recurringSelectAccount;

  /// No description provided for @recurringSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get recurringSelectCategory;

  /// No description provided for @recurringEnterIncomeCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter income category label'**
  String get recurringEnterIncomeCategoryLabel;

  /// No description provided for @recurringCategoryLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Category label (e.g. Salary)'**
  String get recurringCategoryLabelHint;

  /// No description provided for @recurringFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringFrequency;

  /// No description provided for @recurringSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get recurringSaving;

  /// No description provided for @recurringSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save template'**
  String get recurringSaveTemplate;

  /// No description provided for @lockEnterDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 4 digits'**
  String get lockEnterDigits;

  /// No description provided for @lockIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get lockIncorrectPin;

  /// No description provided for @lockAppLocked.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get lockAppLocked;

  /// No description provided for @lockEnterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue'**
  String get lockEnterPinToContinue;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @pinAtLeast4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinAtLeast4Digits;

  /// No description provided for @pinDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinDoNotMatch;

  /// No description provided for @pinDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a numeric PIN (stored securely on device). Used when app lock is enabled.'**
  String get pinDescription;

  /// No description provided for @pinConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirmLabel;

  /// No description provided for @pinSave.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get pinSave;

  /// No description provided for @pinSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get pinSaving;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @adsAdFree.
  ///
  /// In en, this message translates to:
  /// **'You\'re ad-free!'**
  String get adsAdFree;

  /// No description provided for @adsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy an ad-free experience'**
  String get adsHeroTitle;

  /// No description provided for @adsHeroSubtitleActive.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support. All ads have been permanently removed.'**
  String get adsHeroSubtitleActive;

  /// No description provided for @adsHeroSubtitleOffer.
  ///
  /// In en, this message translates to:
  /// **'Remove all ads with a single one-time purchase.'**
  String get adsHeroSubtitleOffer;

  /// No description provided for @adsWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get adsWhatYouGet;

  /// No description provided for @adsBenefitBanners.
  ///
  /// In en, this message translates to:
  /// **'No banner ads'**
  String get adsBenefitBanners;

  /// No description provided for @adsBenefitInterstitials.
  ///
  /// In en, this message translates to:
  /// **'No interstitial popups'**
  String get adsBenefitInterstitials;

  /// No description provided for @adsBenefitAppOpen.
  ///
  /// In en, this message translates to:
  /// **'No app-open ads'**
  String get adsBenefitAppOpen;

  /// No description provided for @adsBenefitNative.
  ///
  /// In en, this message translates to:
  /// **'No native ads in lists'**
  String get adsBenefitNative;

  /// No description provided for @adsBenefitOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase — pay once, forever'**
  String get adsBenefitOneTime;

  /// No description provided for @adsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore previous purchase'**
  String get adsRestore;

  /// No description provided for @adsNoPurchaseFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found.'**
  String get adsNoPurchaseFound;

  /// No description provided for @adsSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'All ads have been removed'**
  String get adsSuccessTitle;

  /// No description provided for @adsSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your ad-free experience is active. This applies to banners, interstitials, native ads, and app-open ads.'**
  String get adsSuccessBody;

  /// No description provided for @adsProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing purchase…'**
  String get adsProcessing;

  /// No description provided for @adsRemoveWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads — {price}'**
  String adsRemoveWithPrice(String price);

  /// No description provided for @adsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get adsRemove;

  /// No description provided for @adsPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed.'**
  String get adsPurchaseFailed;

  /// No description provided for @listFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get listFrom;

  /// No description provided for @listTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get listTo;

  /// No description provided for @listAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get listAccountLabel;

  /// No description provided for @listSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get listSortLabel;

  /// No description provided for @listSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes, category, amount…'**
  String get listSearchHint;

  /// No description provided for @listNoIncomeMatches.
  ///
  /// In en, this message translates to:
  /// **'No income matches your filters'**
  String get listNoIncomeMatches;

  /// No description provided for @listNoIncomeToShow.
  ///
  /// In en, this message translates to:
  /// **'No income to show'**
  String get listNoIncomeToShow;

  /// No description provided for @listNoExpenseMatches.
  ///
  /// In en, this message translates to:
  /// **'No expenses match your filters'**
  String get listNoExpenseMatches;

  /// No description provided for @listNoExpenseToShow.
  ///
  /// In en, this message translates to:
  /// **'No expenses to show'**
  String get listNoExpenseToShow;

  /// No description provided for @listDeleteIncomeConfirmDetail.
  ///
  /// In en, this message translates to:
  /// **'Remove this \"{category}\" income entry? If deleting would leave an account balance negative, the delete will be blocked.'**
  String listDeleteIncomeConfirmDetail(String category);

  /// No description provided for @listDeleteExpenseConfirmDetail.
  ///
  /// In en, this message translates to:
  /// **'Remove this expense from {category}? The amount will be added back to the account.'**
  String listDeleteExpenseConfirmDetail(String category);

  /// No description provided for @listDatesRangeSummary.
  ///
  /// In en, this message translates to:
  /// **'Dates {a}–{b}'**
  String listDatesRangeSummary(String a, String b);

  /// No description provided for @udharToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get udharToReceive;

  /// No description provided for @udharToReceiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money owed to you'**
  String get udharToReceiveSubtitle;

  /// No description provided for @udharToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get udharToPay;

  /// No description provided for @udharToPaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Money you owe'**
  String get udharToPaySubtitle;

  /// No description provided for @udharOpenIous.
  ///
  /// In en, this message translates to:
  /// **'Open IOUs'**
  String get udharOpenIous;

  /// No description provided for @formCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Salary, Freelance, Gift'**
  String get formCategoryHint;

  /// No description provided for @formEnterCategory.
  ///
  /// In en, this message translates to:
  /// **'Please enter category'**
  String get formEnterCategory;

  /// No description provided for @formTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get formTypeLabel;

  /// No description provided for @udharLentLabel.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get udharLentLabel;

  /// No description provided for @udharBorrowedLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get udharBorrowedLabel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @accAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account added successfully'**
  String get accAddedSuccess;

  /// No description provided for @accNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accNameLabel;

  /// No description provided for @accNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC Bank, SBI Savings'**
  String get accNameHint;

  /// No description provided for @accEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get accEnterName;

  /// No description provided for @accTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accTypeLabel;

  /// No description provided for @accInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get accInitialBalance;

  /// No description provided for @accEnterInitialBalance.
  ///
  /// In en, this message translates to:
  /// **'Please enter initial balance'**
  String get accEnterInitialBalance;

  /// No description provided for @accEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get accEnterValidAmount;

  /// No description provided for @accCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get accCreateButton;

  /// No description provided for @catUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get catUpdatedSuccess;

  /// No description provided for @catAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get catAddedSuccess;

  /// No description provided for @catUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update category'**
  String get catUpdateFailed;

  /// No description provided for @catAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category'**
  String get catAddFailed;

  /// No description provided for @catNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get catNameLabel;

  /// No description provided for @catNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get catNameHint;

  /// No description provided for @catEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get catEnterName;

  /// No description provided for @catIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get catIconLabel;

  /// No description provided for @catColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get catColorLabel;

  /// No description provided for @catSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Category'**
  String get catSaveButton;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @catNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get catNoCategories;

  /// No description provided for @catDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get catDeleteConfirmTitle;

  /// No description provided for @catDeleteBuiltInError.
  ///
  /// In en, this message translates to:
  /// **'Built-in categories cannot be deleted.'**
  String get catDeleteBuiltInError;

  /// No description provided for @catDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone if no expenses use it.'**
  String get catDeleteConfirmBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'gu',
    'hi',
    'id',
    'mr',
    'pt',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'mr':
      return AppLocalizationsMr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
