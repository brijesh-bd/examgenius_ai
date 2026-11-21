import 'dart:convert';
import 'dart:io';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/practice_test/presentation/widgets/option_tile.dart';
import 'package:examgenius_ai/features/practice_test/presentation/widgets/test_timer_chip.dart';
import 'package:examgenius_ai/features/shell/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads the bundled Poppins so text metrics match the real app (the default
/// test font is much narrower and would hide overflows).
Future<void> _loadPoppins() async {
  final loader = FontLoader('Poppins');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Poppins-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

const _user = {
  'id': 'u1',
  'name': 'Brijesh Kumar Vishwakarma',
  'mobile': '9876543210',
  'email': null,
  'targetExamId': 'rrb_ntpc',
};

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Size size,
  String locale = 'en',
  String theme = 'light',
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'session_user': jsonEncode(_user),
    'locale_code': locale,
    'theme_mode': theme,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const ExamGeniusApp(),
  ));
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1)); // mock repository latency
  await tester.pumpAndSettle();
}

/// Scrolls the whole dashboard so every section is laid out, failing on any
/// overflow / layout exception along the way.
Future<void> _scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 12; i++) {
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
}

void main() {
  setUpAll(_loadPoppins);

  const sizes = {
    'small 320x568': Size(320, 568),
    'standard 360x800': Size(360, 800),
    'large 412x915': Size(412, 915),
    'tablet 800x1280': Size(800, 1280),
  };

  for (final e in sizes.entries) {
    testWidgets('dashboard renders without overflow — ${e.key}', (tester) async {
      await _pumpDashboard(tester, size: e.value);
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(find.text('Railway'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _scrollThrough(tester);
      expect(find.text('Previous Year Papers'), findsOneWidget);
      expect(find.text('Go Premium'), findsNothing);
    });
  }

  testWidgets('Hindi + dark theme + 1.3x text on a small phone', (tester) async {
    await _pumpDashboard(
      tester,
      size: const Size(320, 640),
      locale: 'hi',
      theme: 'dark',
      textScale: 1.3,
    );
    expect(find.text('अपनी परीक्षा चुनें'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _scrollThrough(tester);
  });

  testWidgets('bottom navigation has the four tabs in order', (tester) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    final labels = tester
        .widget<CustomBottomNavigation>(find.byType(CustomBottomNavigation))
        .items
        .map((i) => i.label)
        .toList();
    expect(labels, ['Home', 'Practice', 'Saved', 'Analytics']);
  });

  testWidgets('Saved tab opens My Saved Practice (empty state)', (tester) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('Saved'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('My Saved Practice'), findsOneWidget);
    expect(find.text('No saved practice yet'), findsOneWidget);
    expect(find.byType(CustomBottomNavigation), findsOneWidget); // still in the shell
  });

  testWidgets('shows three exam categories and three module tiles',
      (tester) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    expect(find.text('Railway'), findsOneWidget);
    expect(find.text('SSC'), findsOneWidget);
    expect(find.text('Banking'), findsOneWidget);
    for (final t in ['Mock Tests', 'Daily Practice', 'Previous Year Papers']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('tapping a category opens its exam selection page', (tester) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('SSC'));
    await tester.pumpAndSettle();
    expect(find.text('Select the exam you are preparing for'), findsOneWidget);
    expect(find.text('SSC CGL'), findsOneWidget);
    expect(find.text('RRB NTPC'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Railway'));
    await tester.pumpAndSettle();
    expect(find.text('RRB NTPC'), findsOneWidget);
    expect(find.text('Current target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exam → syllabus → topic/level/count → generated questions', (tester) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('Railway'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RRB NTPC'));
    await tester.pumpAndSettle();

    // Full syllabus is listed; generate is disabled until everything is chosen.
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('General Intelligence & Reasoning'), findsOneWidget);
    FilledButton generateButton() =>
        tester.widget<FilledButton>(find.ancestor(
            of: find.text('Generate Questions'), matching: find.byType(FilledButton)));
    expect(generateButton().onPressed, isNull);

    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Time & Work'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Time & Work')); // topic card on the subject page
    await tester.pumpAndSettle();
    expect(find.text('Choose one or more topics · 1 selected'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget); // subject card subtitle
    await tester.ensureVisible(find.text('Medium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(generateButton().onPressed, isNull); // count still missing
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pumpAndSettle();
    expect(generateButton().onPressed, isNotNull);

    await tester.tap(find.text('Generate Questions'));
    await tester.pump();
    expect(find.textContaining('exam-level questions'), findsOneWidget); // loading
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Screen 1: one question at a time, no answer revealed before submit.
    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.textContaining('A can do a work in 12 days'), findsOneWidget);
    expect(find.byType(TestTimerChip), findsOneWidget);
    FilledButton submitButton() => tester.widget<FilledButton>(find.ancestor(
        of: find.text('Submit Test'), matching: find.byWidgetPredicate((w) => w is FilledButton)));
    expect(submitButton().onPressed, isNull);

    await tester.ensureVisible(find.text('8'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(find.text('1/5 answered'), findsOneWidget);
    expect(find.text('Correct!'), findsNothing); // never revealed during the test

    // Change answer, clear it, answer again.
    await tester.ensureVisible(find.byType(OptionTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OptionTile).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Clear Answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear Answer'));
    await tester.pumpAndSettle();
    expect(find.text('0/5 answered'), findsOneWidget);

    // Answer every question with Next; answers are kept when moving back.
    for (var i = 0; i < 5; i++) {
      await tester.ensureVisible(find.byType(OptionTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OptionTile).first);
      await tester.pumpAndSettle();
      if (i < 4) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }
    expect(find.text('Question 5 of 5'), findsOneWidget);
    expect(find.text('5/5 answered'), findsOneWidget);
    expect(submitButton().onPressed, isNotNull);

    // Palette jumps back to question 2.
    await tester.tap(find.byTooltip('Question Palette'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Q2,')));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 of 5'), findsOneWidget);

    // Screen 2: confirmation dialog with the summary; Cancel keeps the test.
    await tester.tap(find.text('Submit Test'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to submit your test?'), findsOneWidget);
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('Time Remaining'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to submit your test?'), findsNothing);

    // Confirm → submitting overlay → result screen with the backend score.
    await tester.tap(find.text('Submit Test'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(Dialog), matching: find.widgetWithText(FilledButton, 'Submit Test')));
    await tester.pump();
    expect(find.text('Submitting your test…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    // Screen 3: scorecard.
    expect(
        find.byWidgetPredicate((w) =>
            w is Text && (w.data == 'Test Completed' || w.data == 'Congratulations!')),
        findsOneWidget);
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('Correct vs Incorrect'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Back to Dashboard'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Performance Analysis'), findsOneWidget);
    expect(find.text('Topic-wise Accuracy'), findsOneWidget);
    // Screen 5: save practice — success only after the (mock) backend confirms.
    await tester.ensureVisible(find.text('Save Practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Practice'));
    await tester.pump();
    expect(find.text('Saving…'), findsOneWidget);
    expect(find.textContaining('Practice saved'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Saved to My Practice'), findsOneWidget);
    expect(find.textContaining('Practice saved'), findsOneWidget);
    await tester.pumpAndSettle(); // snackbar finishes sliding in
    await tester.pump(const Duration(seconds: 5)); // then auto-dismisses
    await tester.pumpAndSettle();

    // Screen 4: detailed review with filters, then back to the scorecard.
    await tester.ensureVisible(find.text('Review Answers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review Answers'));
    await tester.pumpAndSettle();
    expect(find.text('Answer Review'), findsOneWidget);
    expect(find.text('Q1'), findsOneWidget);
    expect(find.text('Correct answer'), findsWidgets);
    await tester.tap(find.textContaining('Unattempted ('));
    await tester.pumpAndSettle();
    expect(find.text('No questions in this filter.'), findsOneWidget); // all answered
    await tester.tap(find.textContaining('All ('));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Performance Analysis'), findsOneWidget);
    await tester.ensureVisible(find.text('Back to Dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
