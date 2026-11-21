import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/shell/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(p)],
    child: const ExamGeniusApp(),
  ));
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first launch shows language onboarding', (tester) async {
    await pumpApp(tester, {});
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('login leads to dashboard with bottom nav', (tester) async {
    await pumpApp(tester, {'onboarding_done': true});
    expect(find.text('Email or Mobile Number'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '9876543210');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CustomBottomNavigation), findsOneWidget);
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('invalid login shows validation errors', (tester) async {
    await pumpApp(tester, {'onboarding_done': true});
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('This field is required'), findsNWidgets(2));
  });

  testWidgets('validation errors clear as soon as the fields are filled', (tester) async {
    await pumpApp(tester, {'onboarding_done': true});
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('This field is required'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).at(0), '9876543210');
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget); // email/mobile error gone
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.pump();
    expect(find.text('This field is required'), findsNothing);
  });

  testWidgets('login shows only the mobile OTP option', (tester) async {
    await pumpApp(tester, {'onboarding_done': true});
    expect(find.text('Continue with Mobile OTP'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Continue with Email OTP'), findsNothing);
  });

  testWidgets('forgot password: validate, send, confirmation, back to login', (tester) async {
    await pumpApp(tester, {'onboarding_done': true});
    await tester.ensureVisible(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send Reset Link'), findsOneWidget);

    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('Enter a valid email or 10-digit mobile number'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'student@example.com');
    await tester.pump();
    expect(find.text('Enter a valid email or 10-digit mobile number'), findsNothing);

    await tester.tap(find.text('Send Reset Link'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Check your inbox'), findsOneWidget);
    expect(
        find.text('We have sent password reset instructions to student@example.com'),
        findsOneWidget);

    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Email or Mobile Number'), findsOneWidget);
  });
}
