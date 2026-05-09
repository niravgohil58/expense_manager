import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/app_preferences.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/about_screen.dart';
import '../../presentation/screens/add_category_screen.dart';
import '../../presentation/screens/add_account_screen.dart';
import '../../presentation/screens/add_expense_screen.dart';
import '../../presentation/screens/add_income_screen.dart';
import '../../presentation/screens/add_udhar_screen.dart';
import '../../presentation/screens/budgets_screen.dart';
import '../../presentation/screens/expense_list_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/income_list_screen.dart';
import '../../presentation/screens/legal_document_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/manage_categories_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/recurring_template_form_screen.dart';
import '../../presentation/screens/recurring_templates_screen.dart';
import '../../presentation/screens/report_screen.dart';
import '../../presentation/screens/set_pin_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/transfer_history_screen.dart';
import '../../presentation/screens/transfer_screen.dart';
import '../../presentation/screens/udhar_detail_screen.dart';
import '../../presentation/screens/udhar_home_screen.dart';
import '../../presentation/widgets/bottom_nav_shell.dart';

/// Application router; call [create] once at startup (e.g. from [MyApp]).
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  static GoRouter get router {
    final r = _router;
    assert(r != null, 'AppRouter.create was not called');
    return r!;
  }

  static GoRouter create(AppPreferences prefs, AuthProvider authProvider) {
    _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final loc = state.matchedLocation;

        if (!authProvider.firebaseAuthEnabled) {
          if (!prefs.onboardingCompleted &&
              loc != '/onboarding' &&
              loc != '/terms' &&
              loc != '/privacy') {
            return '/onboarding';
          }
          return null;
        }

        final loggedIn = FirebaseAuth.instance.currentUser != null;
        const publicWhenLoggedOut = {'/login', '/terms', '/privacy'};

        if (!loggedIn) {
          if (publicWhenLoggedOut.contains(loc)) return null;
          return '/login';
        }

        if (loggedIn && loc == '/login') {
          return prefs.onboardingCompleted ? '/home' : '/onboarding';
        }

        if (!prefs.onboardingCompleted &&
            loc != '/onboarding' &&
            loc != '/terms' &&
            loc != '/privacy') {
          return '/onboarding';
        }

        return null;
      },
      errorBuilder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: const Text('Route')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No route for ${state.uri}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: Text(l10n?.errorGoHome ?? 'Go home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/login',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/terms',
          name: 'terms',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return LegalDocumentScreen(
              title: l10n.drawerTermsConditions,
              assetPath: 'assets/legal/terms_en.md',
            );
          },
        ),
        GoRoute(
          path: '/privacy',
          name: 'privacy',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            return LegalDocumentScreen(
              title: l10n.drawerPrivacyPolicy,
              assetPath: 'assets/legal/privacy_en.md',
            );
          },
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
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
              path: '/income',
              name: 'income',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: IncomeListScreen(),
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
        GoRoute(
          path: '/add-expense',
          name: 'add-expense',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra;
            final expense = extra is Expense ? extra : null;
            return AddExpenseScreen(expense: expense);
          },
        ),
        GoRoute(
          path: '/add-income',
          name: 'add-income',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra;
            final income = extra is Income ? extra : null;
            return AddIncomeScreen(income: income);
          },
        ),
        GoRoute(
          path: '/transfer',
          name: 'transfer',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const TransferScreen(),
        ),
        GoRoute(
          path: '/add-udhar',
          name: 'add-udhar',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AddUdharScreen(),
        ),
        GoRoute(
          path: '/udhar/:id',
          name: 'udhar-detail',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return UdharDetailScreen(udharId: id);
          },
        ),
        GoRoute(
          path: '/add-account',
          name: 'add-account',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AddAccountScreen(),
        ),
        GoRoute(
          path: '/manage-categories',
          name: 'manage-categories',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const ManageCategoriesScreen(),
        ),
        GoRoute(
          path: '/add-category',
          name: 'add-category',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AddCategoryScreen(),
        ),
        GoRoute(
          path: '/edit-category',
          name: 'edit-category',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra;
            final cat = extra is Category ? extra : null;
            return AddCategoryScreen(category: cat);
          },
        ),
        GoRoute(
          path: '/transfer-history',
          name: 'transfer-history',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const TransferHistoryScreen(),
        ),
        GoRoute(
          path: '/set-pin',
          name: 'set-pin',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const SetPinScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/budgets',
          name: 'budgets',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const BudgetsScreen(),
        ),
        GoRoute(
          path: '/recurring-templates',
          name: 'recurring-templates',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const RecurringTemplatesScreen(),
        ),
        GoRoute(
          path: '/recurring-templates/add',
          name: 'recurring-templates-add',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const RecurringTemplateFormScreen(),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
    return _router!;
  }
}
