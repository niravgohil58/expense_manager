import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/ads/ads_controller.dart';
import 'core/config/firebase_auth_platform.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/preferences/app_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/account_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/backup_provider.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/income_provider.dart';
import 'presentation/providers/lock_provider.dart';
import 'presentation/providers/recurring_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/udhar_provider.dart';
import 'presentation/widgets/ads/ads_lifecycle_wrapper.dart';
import 'presentation/screens/app_lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final sharedPrefs = await SharedPreferences.getInstance();
  await AppPreferences.migrateInstallPrefs(sharedPrefs);
  await AppPreferences.migrateLegalTermsGrandfather(sharedPrefs);
  final appPreferences = AppPreferences(sharedPrefs);

  if (firebaseAuthSupportedPlatform) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      // Native Android often registers [DEFAULT] via google-services before Dart runs;
      // Dart's Firebase.apps can still look empty, so initializeApp throws duplicate-app.
      final code = e.code.toLowerCase();
      if (!code.contains('duplicate')) rethrow;
    }
  }

  final authProvider = AuthProvider(
    prefs: appPreferences,
    firebaseAuthEnabled: firebaseAuthSupportedPlatform,
  );

  final adsController = (Platform.isAndroid || Platform.isIOS)
      ? AdsController.mobile()
      : AdsController.disabled();

  final runAdsBootstrap =
      adsController.isSupported && firebaseAuthSupportedPlatform;
  debugPrint(
    '[ExpenseAds] main: runAdsBootstrap=$runAdsBootstrap '
    '(mobile=${adsController.isSupported}, firebasePlatform=$firebaseAuthSupportedPlatform)',
  );
  if (runAdsBootstrap) {
    await adsController.bootstrap();
  }
  debugPrint('[ExpenseAds] main: after ads bootstrap');

  if (Platform.isAndroid || Platform.isIOS) {
    await LocalNotificationService.instance.initialize();
    await LocalNotificationService.instance.rescheduleFromPrefs(appPreferences);
  }

  runApp(MyApp(
    appPreferences: appPreferences,
    authProvider: authProvider,
    adsController: adsController,
  ));
}

ThemeData _themeForLockOverlay(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return buildDarkTheme();
    case ThemeMode.light:
      return buildLightTheme();
    case ThemeMode.system:
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark
          ? buildDarkTheme()
          : buildLightTheme();
  }
}

Locale _localeForLockOverlay() {
  const supported = AppLocalizations.supportedLocales;
  final platform = WidgetsBinding.instance.platformDispatcher.locale;
  for (final locale in supported) {
    if (locale.languageCode == platform.languageCode) {
      return locale;
    }
  }
  return supported.first;
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.appPreferences,
    required this.authProvider,
    required this.adsController,
  });

  final AppPreferences appPreferences;
  final AuthProvider authProvider;
  final AdsController adsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router =
      AppRouter.create(widget.appPreferences, widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppPreferences>.value(value: widget.appPreferences),
        ChangeNotifierProvider.value(value: widget.adsController),
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(widget.appPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => LockProvider(widget.appPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => BackupProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => RecurringProvider()),
        ChangeNotifierProxyProvider<AccountProvider, ExpenseProvider>(
          create: (context) => ExpenseProvider(
            accountProvider: context.read<AccountProvider>(),
          ),
          update: (context, accountProvider, previous) =>
              previous ?? ExpenseProvider(accountProvider: accountProvider),
        ),
        ChangeNotifierProxyProvider<AccountProvider, UdharProvider>(
          create: (context) => UdharProvider(
            accountProvider: context.read<AccountProvider>(),
          ),
          update: (context, accountProvider, previous) =>
              previous ?? UdharProvider(accountProvider: accountProvider),
        ),
        ChangeNotifierProxyProvider<AccountProvider, IncomeProvider>(
          create: (context) => IncomeProvider(
            accountProvider: context.read<AccountProvider>(),
          ),
          update: (context, accountProvider, previous) =>
              previous ?? IncomeProvider(accountProvider: accountProvider),
        ),
      ],
      child: Consumer2<LockProvider, SettingsProvider>(
        builder: (context, lock, settings, _) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              AdsLifecycleWrapper(
                router: _router,
                child: MaterialApp.router(
                  title: 'Expense Manager',
                  debugShowCheckedModeBanner: false,
                  themeMode: settings.themeMode,
                  theme: buildLightTheme(),
                  darkTheme: buildDarkTheme(),
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale == null) return supportedLocales.first;
                    for (final supported in supportedLocales) {
                      if (supported.languageCode == locale.languageCode) {
                        return supported;
                      }
                    }
                    return supportedLocales.first;
                  },
                  routerConfig: _router,
                ),
              ),
              if (lock.needsLockOverlay)
                Positioned.fill(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Localizations(
                      locale: _localeForLockOverlay(),
                      delegates: AppLocalizations.localizationsDelegates,
                      child: Theme(
                        data: _themeForLockOverlay(settings.themeMode),
                        child: const AppLockScreen(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
