// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the widget tree, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firefighter_safety_data_hub/main.dart';
import 'package:firefighter_safety_data_hub/screens/login_page.dart';
import 'package:firefighter_safety_data_hub/screens/main_navigation.dart';
import 'package:firefighter_safety_data_hub/screens/user_consent_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Logged-out app shows LoginPage', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      // Skip the one-time consent gate for this test.
      'user_consent_accepted': true,
    });
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('First-launch app shows UserConsentPage', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(UserConsentPage), findsOneWidget);
  });

  testWidgets('MainNavigation shows when pumped directly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigation(),
      ),
    );
    // Post-frame location prompt; avoid pumpAndSettle (repeating progress animations in tabs).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MainNavigation), findsOneWidget);
  });
}
