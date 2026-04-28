import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/account_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/udhar_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/income_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AccountProvider(),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // Added this provider
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
      child: MaterialApp.router(
        title: 'Expense Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
