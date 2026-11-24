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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ExamGeniusApp(),
    ),
  );
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
    testWidgets('dashboard renders without overflow — ${e.key}', (
      tester,
    ) async {
      await _pumpDashboard(tester, size: e.value);
      expect(find.text('Choose your exam'), findsOneWidget);
      expect(find.text('Railway'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _scrollThrough(tester);
      expect(find.text('Previous Year Papers'), findsOneWidget);
      expect(find.text('Go Premium'), findsNothing);
    });
  }

  testWidgets('Hindi + dark theme + 1.3x text on a small phone', (
    tester,
  ) async {
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
    expect(labels, ['Home', 'Practice', 'Library', 'Analytics']);
  });

  testWidgets('Library tab opens My Learning Library (empty state)', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('Library'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('My Learning Library'), findsOneWidget);
    expect(find.text('Your Library is empty'), findsOneWidget);
    expect(find.text('Railway Library'), findsOneWidget);
    expect(
      find.byType(CustomBottomNavigation),
      findsOneWidget,
    ); // still in the shell
  });

  testWidgets('shows three exam categories and three module tiles', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    expect(find.text('Railway'), findsOneWidget);
    expect(find.text('SSC'), findsOneWidget);
    expect(find.text('Banking'), findsOneWidget);
    for (final t in ['Mock Tests', 'AI Study Notes', 'Previous Year Papers']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('tapping a category opens its preparation screen', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('SSC'));
    await tester.pumpAndSettle();
    expect(find.text('SSC Preparation'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'SSC CGL'), findsOneWidget);
    expect(find.text('RRB NTPC'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Railway'));
    await tester.pumpAndSettle();
    expect(find.text('Railway Preparation'), findsOneWidget);
    // The target exam is preselected.
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'RRB NTPC'))
          .selected,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('category → exam → subject → topic → count → practice set', (
    tester,
  ) async {
    await _pumpDashboard(tester, size: const Size(360, 800));
    await tester.tap(find.text('Railway'));
    await tester.pumpAndSettle();

    // One preparation screen: exam chips, subjects, no shortcuts.
    expect(find.text('Railway Preparation'), findsOneWidget);
    expect(find.text('Quick 10'), findsNothing);
    expect(find.text('Weak topics'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Mathematics'), findsOneWidget);
    expect(find.text('Choose a subject to see its topics'), findsOneWidget);
    FilledButton generateButton(String label) => tester.widget<FilledButton>(
      find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
    );
    // 10 questions by default, Question Bank source, nothing picked yet.
    expect(generateButton('Start Practice – 10 Questions').onPressed, isNull);

    // Subject chip → its topics appear inline (no new page, no going back).
    await tester.tap(find.widgetWithText(ChoiceChip, 'Mathematics'));
    await tester.pumpAndSettle();
    expect(find.text('Select at least 1 topic to start'), findsOneWidget);
    await tester.ensureVisible(find.textContaining('Show all'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Show all'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Time & Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Time & Work'));
    await tester.pumpAndSettle();
    expect(find.text('Topics · 1 selected'), findsOneWidget);
    expect(find.text('Select at least 1 topic to start'), findsNothing);
    expect(
      generateButton('Start Practice – 10 Questions').onPressed,
      isNotNull,
    );

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pumpAndSettle();
    // 20 / 30 / 40 are above the Free maximum of 10 (mock plan is Free).
    expect(find.widgetWithText(ActionChip, '20'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '40'), findsOneWidget);

    await tester.tap(find.text('Start Practice – 5 Questions'));
    await tester.pump();
    expect(
      find.textContaining('exam-level questions'),
      findsOneWidget,
    ); // loading
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Screen 1: one question at a time, no answer revealed before submit.
    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.textContaining('A can do a work in 12 days'), findsOneWidget);
    expect(find.byType(TestTimerChip), findsOneWidget);
    FilledButton submitButton() => tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Submit Test'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(submitButton().onPressed, isNull);

    await tester.ensureVisible(find.text('8'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(find.text('1/5 answered'), findsOneWidget);
    expect(
      find.text('Correct!'),
      findsNothing,
    ); // never revealed during the test

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
    expect(
      find.text('Are you sure you want to submit your test?'),
      findsOneWidget,
    );
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('Time Remaining'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.text('Are you sure you want to submit your test?'),
      findsNothing,
    );

    // Confirm → submitting overlay → result screen with the backend score.
    await tester.tap(find.text('Submit Test'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(FilledButton, 'Submit Test'),
      ),
    );
    await tester.pump();
    expect(find.text('Submitting your test…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    // Screen 3: scorecard.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.data == 'Test Completed' || w.data == 'Congratulations!'),
      ),
      findsOneWidget,
    );
    expect(find.text('Total Questions'), findsOneWidget);
    expect(find.text('Correct vs Incorrect'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Back to Dashboard'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Performance Analysis'), findsOneWidget);
    expect(find.text('Topic-wise Accuracy'), findsOneWidget);
    // The set is saved to the Library automatically — no manual Save step.
    expect(find.text('Save Practice'), findsNothing);
    await tester.ensureVisible(find.text('Open Library'));
    await tester.pumpAndSettle();
    expect(find.text('Saved to your Library automatically'), findsOneWidget);

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
    expect(
      find.text('No questions in this filter.'),
      findsOneWidget,
    ); // all answered
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
