import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expense_app/core/preferences/app_preferences.dart';
import 'package:expense_app/core/router/app_router.dart';
import 'package:expense_app/main.dart';
import 'package:expense_app/presentation/providers/auth_provider.dart';

/// Smoke: shell routes mount without throwing (no golden snapshots).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('shell routes resolve via GoRouter', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AppPreferences.keyOnboardingCompleted: true,
    });
    final appPrefs = AppPreferences(await SharedPreferences.getInstance());

    await tester.pumpWidget(MyApp(
      appPreferences: appPrefs,
      authProvider: AuthProvider(
        prefs: appPrefs,
        firebaseAuthEnabled: false,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    for (final path in ['/home', '/income', '/expenses', '/udhar', '/reports']) {
      AppRouter.router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MaterialApp), findsOneWidget);
    }
  });
}
