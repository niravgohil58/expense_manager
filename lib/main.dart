import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/account_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/udhar_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/income_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/backup_provider.dart';
import 'presentation/providers/lock_provider.dart';
import 'presentation/screens/app_lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final sharedPrefs = await SharedPreferences.getInstance();
  final appPreferences = AppPreferences(sharedPrefs);
  runApp(MyApp(appPreferences: appPreferences));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appPreferences});

  final AppPreferences appPreferences;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(appPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => LockProvider(appPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => BackupProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
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
              MaterialApp.router(
                title: 'Expense Manager',
                debugShowCheckedModeBanner: false,
                themeMode: settings.themeMode,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                routerConfig: AppRouter.router,
              ),
              if (lock.needsLockOverlay)
                Positioned.fill(child: const AppLockScreen()),
            ],
          );
        },
      ),
    );
  }
}
