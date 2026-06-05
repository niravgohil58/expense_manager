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

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginRegisterTitle => 'Create account';

  @override
  String get loginSubtitle =>
      'Sign in to sync your profile securely with Firebase.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginEmailInvalid => 'Enter a valid email.';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters.';

  @override
  String get loginPrimarySignIn => 'Sign in';

  @override
  String get loginPrimaryRegister => 'Create account';

  @override
  String get loginToggleToRegister => 'Need an account? Register';

  @override
  String get loginToggleToSignIn => 'Already have an account? Sign in';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNotSignedIn => 'Not signed in.';

  @override
  String get profileNoDisplayName => 'User';

  @override
  String get profileUserIdLabel => 'User ID';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get titleAddAccount => 'Add Account';

  @override
  String get titleAddCategory => 'Add Category';

  @override
  String get titleEditCategory => 'Edit Category';

  @override
  String get titleAddExpense => 'Add Expense';

  @override
  String get titleEditExpense => 'Edit Expense';

  @override
  String get titleAddIncome => 'Add Income';

  @override
  String get titleEditIncome => 'Edit Income';

  @override
  String get titleAddIou => 'Add IOU';

  @override
  String get titleExpenses => 'Expenses';

  @override
  String get titleIncomes => 'Incomes';

  @override
  String get titleManageCategories => 'Manage Categories';

  @override
  String get titleNotificationSettings => 'Notification Settings';

  @override
  String get titleAddTemplate => 'Add Template';

  @override
  String get titleRemoveAds => 'Remove Ads';

  @override
  String get titleMonthlyReport => 'Monthly Report';

  @override
  String get titleSelectLanguage => 'Select Language';

  @override
  String get titleLanguageSettings => 'Language Settings';

  @override
  String get titleAppSecurityPin => 'App Security PIN';

  @override
  String get titleSettings => 'Settings';

  @override
  String get titleTransferHistory => 'Transfer History';

  @override
  String get titleTransferBalance => 'Transfer Balance';

  @override
  String get titleIouDetails => 'IOU Details';

  @override
  String get titleIouDebtTracker => 'IOU Debt Tracker';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonAllow => 'Allow';

  @override
  String get notifDialogTitle => 'Enable Notifications';

  @override
  String get notifDialogBody =>
      'Expense Manager requires notification permission to send you daily expense reminders, budget warnings, and pending IOU alerts. This helps you stay on top of your finances.';

  @override
  String get drawerRemoveAdsSubtitle => 'One-time purchase';

  @override
  String get drawerCheckUpdate => 'Check for update';

  @override
  String get drawerRateApp => 'Rate this app';

  @override
  String get selectLanguageWelcome => 'Welcome to Expense Manager';

  @override
  String get selectLanguageInstruction =>
      'Please select your preferred language to continue.';

  @override
  String get navHome => 'Home';

  @override
  String get navIncome => 'Income';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navIous => 'IOUs';

  @override
  String get navReports => 'Reports';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Other';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get udharTypeLent => 'Lent (they owe you)';

  @override
  String get udharTypeBorrowed => 'Borrowed (you owe)';

  @override
  String get udharTypeReceivable => 'Receivable';

  @override
  String get udharTypePayable => 'Payable';

  @override
  String get udharStatusPending => 'Pending';

  @override
  String get udharStatusPartial => 'Partial';

  @override
  String get udharStatusCompleted => 'Completed';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get homeTitle => 'Expense Budget Tracker';

  @override
  String get homeAccounts => 'Accounts';

  @override
  String get homeAddAccount => 'ADD ACCOUNT';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeThisMonth => 'This Month';

  @override
  String get homeSpent => 'Spent';

  @override
  String get homeEarned => 'Earned';

  @override
  String get homeNetThisMonth => 'Net this month';

  @override
  String get homeRenameAccount => 'Rename Account';

  @override
  String get homeAddMoney => 'Add Money';

  @override
  String get homeAccountName => 'Account Name';

  @override
  String get homeAccountNameHint => 'e.g. HDFC Bank';

  @override
  String homeAddBalanceTo(String accountName) {
    return 'Add balance to $accountName';
  }

  @override
  String get homeAmount => 'Amount';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsNotificationSubtitle => 'Manage all reminders and alerts';

  @override
  String get settingsLanguageSubtitle => 'Change app display language';

  @override
  String get settingsRegionSecurity => 'Region & security';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsRequirePin => 'Require PIN';

  @override
  String get settingsRequirePinSubtitle =>
      'Locks when returning from background';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsChangePinSubtitle =>
      'Set a new PIN (requires lock enabled)';

  @override
  String get settingsTurnOffAppLock => 'Turn off app lock?';

  @override
  String get settingsTurnOffAppLockConfirm =>
      'PIN will be removed from secure storage.';

  @override
  String get settingsTurnOff => 'Turn off';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsBackupDescription =>
      'Backup contains accounts, categories, expenses, transfers, incomes, IOUs, and settlements. Restore replaces everything locally.';

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Saves JSON to app folder — copy path or upload via Files/Drive';

  @override
  String get settingsExportCsv => 'Export CSV (accounts, expenses, incomes)';

  @override
  String get settingsExportCsvSubtitle =>
      'Three comma-separated files in app documents';

  @override
  String get settingsRestoreBackup => 'Restore from backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Choose your backup file (JSON). Replaces local data';

  @override
  String get settingsBackupSaved => 'Backup saved';

  @override
  String get settingsBackupSavedSubtitle =>
      'File is in app storage. Copy the path below to upload via Files, Google Drive, or share manually.';

  @override
  String get settingsCopyPath => 'Copy path';

  @override
  String get settingsPathCopied => 'Path copied to clipboard';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsRestoreBackupTitle => 'Restore backup?';

  @override
  String get settingsRestoreBackupConfirm =>
      'This will replace ALL data on this device with the backup file. Current expenses, accounts, IOUs, and incomes will be overwritten. This cannot be undone.';

  @override
  String get settingsReplaceData => 'Replace data';

  @override
  String get settingsFilePickerUnavailable => 'File picker unavailable.';

  @override
  String get settingsCouldNotReadFile => 'Could not read file';

  @override
  String get settingsBackupRestored => 'Backup restored';

  @override
  String settingsInvalidBackup(String error) {
    return 'Invalid backup: $error';
  }

  @override
  String settingsRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get settingsCsvExportSaved => 'CSV export saved';

  @override
  String get settingsThreeFilesSaved => 'Three files in app documents:';

  @override
  String get settingsAccountsLabel => 'Accounts:';

  @override
  String get settingsExpensesLabel => 'Expenses:';

  @override
  String get settingsIncomesLabel => 'Incomes:';

  @override
  String settingsCsvExportFailed(String error) {
    return 'CSV export failed: $error';
  }

  @override
  String get settingsPurchases => 'Purchases';

  @override
  String get settingsRestorePurchases => 'Restore purchases';

  @override
  String get settingsAdsAlreadyRemoved => 'Ads already removed';

  @override
  String get settingsRecoverAdFree => 'Recover your ad-free purchase';

  @override
  String get settingsPurchaseRestored => 'Purchase restored!';

  @override
  String get settingsNoPurchaseFound => 'No previous purchase found.';

  @override
  String get settingsWorking => 'Working…';

  @override
  String get listFilters => 'Filters';

  @override
  String get listDateRange => 'Date range';

  @override
  String get listAllDates => 'All dates';

  @override
  String get listThisMonth => 'This month';

  @override
  String get listLast30Days => 'Last 30 days';

  @override
  String get listAllCategories => 'All categories';

  @override
  String get listAllAccounts => 'All accounts';

  @override
  String get listSortNewest => 'Date · newest';

  @override
  String get listSortOldest => 'Date · oldest';

  @override
  String get listSortHigh => 'Amount · high';

  @override
  String get listSortLow => 'Amount · low';

  @override
  String get listClearAll => 'Clear all';

  @override
  String get listApply => 'Apply';

  @override
  String get listClearFilters => 'Clear filters';

  @override
  String get listDeleteIncomeTitle => 'Delete income';

  @override
  String get listDeleteExpenseTitle => 'Delete expense';

  @override
  String get listDeleteIncomeConfirm =>
      'Are you sure you want to delete this income?';

  @override
  String get listDeleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get listNoIncomesYet => 'No incomes yet';

  @override
  String get listNoExpensesYet => 'No expenses yet';

  @override
  String get listTapToRecordIncome => 'Tap + to record income';

  @override
  String get listTapToRecordExpense => 'Tap + to record expense';

  @override
  String get listIncomeDeleted => 'Income deleted successfully';

  @override
  String get listExpenseDeleted => 'Expense deleted successfully';

  @override
  String get listIncomeDeleteFailed => 'Failed to delete income';

  @override
  String get listExpenseDeleteFailed => 'Failed to delete expense';

  @override
  String get formAmount => 'Amount';

  @override
  String get formEnterAmount => 'Please enter amount';

  @override
  String get formEnterValidAmount => 'Please enter a valid amount';

  @override
  String get formAttachReceipt => 'Attach receipt';

  @override
  String get formRemove => 'Remove';

  @override
  String formAttachImageError(String error) {
    return 'Could not attach image: $error';
  }

  @override
  String get formSelectAccount => 'Please select an account';

  @override
  String get formSelectCategory => 'Please select a category';

  @override
  String get formExpenseUpdated => 'Expense updated successfully';

  @override
  String get formExpenseAdded => 'Expense added successfully';

  @override
  String get formExpenseUpdateFailed => 'Failed to update expense';

  @override
  String get formExpenseAddFailed => 'Failed to add expense';

  @override
  String get formIncomeUpdated => 'Income updated successfully';

  @override
  String get formIncomeAdded => 'Income added successfully';

  @override
  String get formIncomeUpdateFailed => 'Failed to update income';

  @override
  String get formIncomeAddFailed => 'Failed to add income';

  @override
  String get formCategory => 'Category';

  @override
  String get formPaymentFrom => 'Payment From';

  @override
  String get formDepositTo => 'Deposit To';

  @override
  String get formDate => 'Date';

  @override
  String get formNoteOptional => 'Note (Optional)';

  @override
  String get formAddNoteHint => 'Add a note...';

  @override
  String get formUpdateExpense => 'Update Expense';

  @override
  String get formSaveExpense => 'Save Expense';

  @override
  String get formUpdateIncome => 'Update Income';

  @override
  String get formSaveIncome => 'Save Income';

  @override
  String get formDeleteExpenseTitle => 'Delete Expense';

  @override
  String get formDeleteIncomeTitle => 'Delete Income';

  @override
  String get formDeleteExpenseConfirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get formDeleteIncomeConfirm =>
      'Are you sure you want to delete this income?';

  @override
  String get formManage => 'Manage';

  @override
  String get transferSelectBoth => 'Please select both accounts';

  @override
  String get transferSameAccount => 'Cannot transfer to the same account';

  @override
  String get transferSuccess => 'Transfer completed successfully';

  @override
  String get transferFailed => 'Transfer failed';

  @override
  String get transferFromAccount => 'From Account';

  @override
  String get transferToAccount => 'To Account';

  @override
  String get transferButton => 'Transfer';

  @override
  String get transferNoTransfersYet => 'No transfers yet';

  @override
  String udharLentOn(String date) {
    return 'Lent on $date';
  }

  @override
  String udharBorrowedOn(String date) {
    return 'Borrowed on $date';
  }

  @override
  String udharSettled(String amount) {
    return 'Settled: $amount';
  }

  @override
  String get udharPersonNameRequired => 'Please enter person name';

  @override
  String get udharPersonNameLabel => 'Person Name';

  @override
  String get udharEnterNameHint => 'Enter name';

  @override
  String get udharMoneyGave => 'Money you gave';

  @override
  String get udharMoneyTook => 'Money you took';

  @override
  String get udharSaveIou => 'Save IOU';

  @override
  String get udharSaved => 'IOU saved';

  @override
  String get udharAddSettlement => 'Add Settlement';

  @override
  String get udharIouNotFound => 'IOU not found';

  @override
  String get udharTotalAmount => 'Total Amount';

  @override
  String get udharSettledLabel => 'Settled';

  @override
  String get udharPendingLabel => 'Pending';

  @override
  String udharDetailDate(String date) {
    return 'Date: $date';
  }

  @override
  String udharDetailNote(String note) {
    return 'Note: $note';
  }

  @override
  String get udharSettlementHistory => 'Settlement History';

  @override
  String get udharNoSettlementsYet => 'No settlements yet';

  @override
  String get reportTotalSpent => 'Total spent';

  @override
  String get reportTotalEarned => 'Total earned';

  @override
  String reportNetForYear(String year) {
    return 'Net for $year';
  }

  @override
  String get reportIncomeVsExpensesByMonth => 'Income vs expenses by month';

  @override
  String get reportNoExpenseData => 'No expense data';

  @override
  String get reportExpensesByCategory => 'Expenses by category';

  @override
  String get reportIouSummary => 'IOU summary';

  @override
  String budgetsLimitLabel(String prefix) {
    return 'Limit ($prefix)';
  }

  @override
  String budgetsSpentProgress(String spent, String limit) {
    return 'Spent $spent / $limit';
  }

  @override
  String get recurringPosted => 'Posted';

  @override
  String get recurringRemoved => 'Removed';

  @override
  String get recurringEnterValidAmount => 'Enter a valid amount';

  @override
  String get recurringSelectAccount => 'Select an account';

  @override
  String get recurringSelectCategory => 'Select a category';

  @override
  String get recurringEnterIncomeCategoryLabel => 'Enter income category label';

  @override
  String get recurringCategoryLabelHint => 'Category label (e.g. Salary)';

  @override
  String get recurringFrequency => 'Frequency';

  @override
  String get recurringSaving => 'Saving…';

  @override
  String get recurringSaveTemplate => 'Save template';

  @override
  String get lockEnterDigits => 'Enter at least 4 digits';

  @override
  String get lockIncorrectPin => 'Incorrect PIN';

  @override
  String get lockAppLocked => 'App locked';

  @override
  String get lockEnterPinToContinue => 'Enter your PIN to continue';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get pinAtLeast4Digits => 'PIN must be at least 4 digits';

  @override
  String get pinDoNotMatch => 'PINs do not match';

  @override
  String get pinDescription =>
      'Choose a numeric PIN (stored securely on device). Used when app lock is enabled.';

  @override
  String get pinConfirmLabel => 'Confirm PIN';

  @override
  String get pinSave => 'Save PIN';

  @override
  String get pinSaving => 'Saving…';

  @override
  String get pinLabel => 'PIN';

  @override
  String get adsAdFree => 'You\'re ad-free!';

  @override
  String get adsHeroTitle => 'Enjoy an ad-free experience';

  @override
  String get adsHeroSubtitleActive =>
      'Thank you for your support. All ads have been permanently removed.';

  @override
  String get adsHeroSubtitleOffer =>
      'Remove all ads with a single one-time purchase.';

  @override
  String get adsWhatYouGet => 'What you get';

  @override
  String get adsBenefitBanners => 'No banner ads';

  @override
  String get adsBenefitInterstitials => 'No interstitial popups';

  @override
  String get adsBenefitAppOpen => 'No app-open ads';

  @override
  String get adsBenefitNative => 'No native ads in lists';

  @override
  String get adsBenefitOneTime => 'One-time purchase — pay once, forever';

  @override
  String get adsRestore => 'Restore previous purchase';

  @override
  String get adsNoPurchaseFound => 'No previous purchase found.';

  @override
  String get adsSuccessTitle => 'All ads have been removed';

  @override
  String get adsSuccessBody =>
      'Your ad-free experience is active. This applies to banners, interstitials, native ads, and app-open ads.';

  @override
  String get adsProcessing => 'Processing purchase…';

  @override
  String adsRemoveWithPrice(String price) {
    return 'Remove Ads — $price';
  }

  @override
  String get adsRemove => 'Remove Ads';

  @override
  String get adsPurchaseFailed => 'Purchase failed.';

  @override
  String get listFrom => 'From';

  @override
  String get listTo => 'To';

  @override
  String get listAccountLabel => 'Account';

  @override
  String get listSortLabel => 'Sort';

  @override
  String get listSearchHint => 'Search notes, category, amount…';

  @override
  String get listNoIncomeMatches => 'No income matches your filters';

  @override
  String get listNoIncomeToShow => 'No income to show';

  @override
  String get listNoExpenseMatches => 'No expenses match your filters';

  @override
  String get listNoExpenseToShow => 'No expenses to show';

  @override
  String listDeleteIncomeConfirmDetail(String category) {
    return 'Remove this \"$category\" income entry? If deleting would leave an account balance negative, the delete will be blocked.';
  }

  @override
  String listDeleteExpenseConfirmDetail(String category) {
    return 'Remove this expense from $category? The amount will be added back to the account.';
  }

  @override
  String listDatesRangeSummary(String a, String b) {
    return 'Dates $a–$b';
  }

  @override
  String get udharToReceive => 'To receive';

  @override
  String get udharToReceiveSubtitle => 'Money owed to you';

  @override
  String get udharToPay => 'To pay';

  @override
  String get udharToPaySubtitle => 'Money you owe';

  @override
  String get udharOpenIous => 'Open IOUs';

  @override
  String get formCategoryHint => 'e.g. Salary, Freelance, Gift';

  @override
  String get formEnterCategory => 'Please enter category';

  @override
  String get formTypeLabel => 'Type';

  @override
  String get udharLentLabel => 'Lent';

  @override
  String get udharBorrowedLabel => 'Borrowed';

  @override
  String get commonAdd => 'Add';

  @override
  String get accAddedSuccess => 'Account added successfully';

  @override
  String get accNameLabel => 'Account Name';

  @override
  String get accNameHint => 'e.g. HDFC Bank, SBI Savings';

  @override
  String get accEnterName => 'Please enter account name';

  @override
  String get accTypeLabel => 'Account Type';

  @override
  String get accInitialBalance => 'Initial Balance';

  @override
  String get accEnterInitialBalance => 'Please enter initial balance';

  @override
  String get accEnterValidAmount => 'Please enter a valid amount';

  @override
  String get accCreateButton => 'Create Account';

  @override
  String get catUpdatedSuccess => 'Category updated';

  @override
  String get catAddedSuccess => 'Category added successfully';

  @override
  String get catUpdateFailed => 'Failed to update category';

  @override
  String get catAddFailed => 'Failed to add category';

  @override
  String get catNameLabel => 'Name';

  @override
  String get catNameHint => 'Category Name';

  @override
  String get catEnterName => 'Please enter category name';

  @override
  String get catIconLabel => 'Icon';

  @override
  String get catColorLabel => 'Color';

  @override
  String get catSaveButton => 'Save Category';

  @override
  String get commonEdit => 'Edit';

  @override
  String get catNoCategories => 'No categories found';

  @override
  String get catDeleteConfirmTitle => 'Delete category?';

  @override
  String get catDeleteBuiltInError => 'Built-in categories cannot be deleted.';

  @override
  String get catDeleteConfirmBody =>
      'This cannot be undone if no expenses use it.';
}
