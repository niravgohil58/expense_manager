import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/screens.dart';
import '../../presentation/screens/add_income_screen.dart';
import '../../data/models/expense_model.dart';
import '../../presentation/widgets/bottom_nav_shell.dart';

/// Application router configuration using go_router
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpenseListScreen(),
            ),
          ),
          GoRoute(
            path: '/udhar',
            name: 'udhar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UdharHomeScreen(),
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportScreen(),
            ),
          ),
        ],
      ),
      // Routes outside shell (full screen)
      GoRoute(
        path: '/add-expense',
        name: 'add-expense',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          final expense = extra is Expense ? extra : null;
          return AddExpenseScreen(expense: expense);
        },
      ),
      GoRoute(
        path: '/add-income',
        name: 'add-income',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddIncomeScreen(),
      ),
      GoRoute(
        path: '/transfer',
        name: 'transfer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: '/add-udhar',
        name: 'add-udhar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddUdharScreen(),
      ),
      GoRoute(
        path: '/udhar/:id',
        name: 'udhar-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return UdharDetailScreen(udharId: id);
        },
      ),
      GoRoute(
        path: '/add-account',
        name: 'add-account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddAccountScreen(),
      ),
      GoRoute(
        path: '/manage-categories',
        name: 'manage-categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageCategoriesScreen(),
      ),
      GoRoute(
        path: '/add-category',
        name: 'add-category',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddCategoryScreen(),
      ),
    ],
  );
}
