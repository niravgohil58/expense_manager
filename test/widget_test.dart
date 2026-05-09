import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expense_app/core/preferences/app_preferences.dart';
import 'package:expense_app/main.dart';
import 'package:expense_app/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('MyApp builds MaterialApp with SettingsProvider', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
