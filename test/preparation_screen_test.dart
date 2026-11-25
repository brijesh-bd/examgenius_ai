import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/routes/app_routes.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/question_generator/data/practice_setup_repositories.dart';
import 'package:examgenius_ai/features/question_generator/presentation/providers/question_generator_providers.dart';
import 'package:examgenius_ai/features/question_generator/presentation/widgets/concept_tree.dart';
import 'package:examgenius_ai/features/subscription/data/subscription_repositories.dart';
import 'package:examgenius_ai/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

/// Opens [route] (default: Railway Preparation).
Future<void> _open(
  WidgetTester tester, {
  String? route,
  bool pro = false,
  int setsUsed = 0,
  int aiSetsUsed = 0,
  int available = 100,
  String? targetExamId = 'rrb_ntpc',
}) async {
  tester.view.physicalSize = const Size(400, 900) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'session_user': jsonEncode({
      'id': 'u1',
      'name': 'Asha',
      'mobile': '9876543210',
      'email': null,
      'targetExamId': targetExamId,
    }),
    'locale_code': 'en',
  });
  _prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        subscriptionRepositoryProvider.overrideWithValue(
          MockSubscriptionRepository(pro: pro)
            ..setsUsedToday = setsUsed
            ..aiSetsUsedToday = aiSetsUsed,
        ),
        practiceSetupRepositoryProvider.overrideWithValue(
          MockPracticeSetupRepository(available: available),
        ),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .push(route ?? AppRoutes.prepareFor('railway'));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _pickTopic(WidgetTester tester) async {
  // Railway Mathematics uses the concept tree: pick one chapter.
  await _tap(tester, find.widgetWithText(ChoiceChip, 'Mathematics'));
  await _tap(tester, find.byKey(const ValueKey('check_rm.percentage')));
}

/// Lets the mock test generation and timers finish.
Future<void> _settleTest(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// Source of the request that was started (stored as the last practice).
String? _startedSource(String examId) {
  final raw = _prefs.getString('last_practice_v2_$examId');
  return raw == null ? null : (jsonDecode(raw) as Map)['source'] as String?;
}

bool _startEnabled(WidgetTester tester) {
  final b = tester.widget<ButtonStyleButton>(
    find
        .ancestor(
          of: find.textContaining('Start Practice'),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        )
        .first,
  );
  return b.onPressed != null;
}

bool _chipSelected(WidgetTester tester, String label) =>
    tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label)).selected;

void main() {
  testWidgets('category: exam chips, target exam selected, removed options '
      'absent, Start disabled', (tester) async {
    await _open(tester);
    expect(find.text('Railway Preparation'), findsOneWidget);
    for (final n in ['RRB NTPC', 'RRB Group D', 'RRB ALP', 'RRB JE']) {
      expect(find.widgetWithText(ChoiceChip, n), findsOneWidget);
    }
    expect(_chipSelected(tester, 'RRB NTPC'), isTrue);
    expect(find.widgetWithText(ChoiceChip, 'Mathematics'), findsOneWidget);
    for (final t in [
      'Quick start',
      'Last practice',
      'Weak topics',
      'Custom',
      'Easy',
      'Hard',
      'Question Bank',
    ]) {
      expect(find.text(t), findsNothing, reason: t);
    }
    expect(find.text('Choose a subject to see its topics'), findsOneWidget);
    expect(_startEnabled(tester), isFalse);
  });

  testWidgets('switching exam updates subjects and clears topics', (
    tester,
  ) async {
    await _open(tester);
    await _pickTopic(tester);
    expect(_startEnabled(tester), isTrue);
    const technical = 'Basic Science & Engineering';
    expect(find.widgetWithText(ChoiceChip, technical), findsNothing);

    await _tap(tester, find.widgetWithText(ChoiceChip, 'RRB ALP'));
    expect(_chipSelected(tester, 'RRB ALP'), isTrue);
    expect(find.widgetWithText(ChoiceChip, technical), findsOneWidget);
    expect(find.byType(ConceptTree), findsNothing, reason: 'subject cleared');
    expect(_startEnabled(tester), isFalse);
  });

  testWidgets('subject switch clears topics; select all and clear', (
    tester,
  ) async {
    await _open(tester);
    await _pickTopic(tester);
    expect(find.text('Chapters & concepts · 1 concept'), findsOneWidget);

    await _tap(tester, find.widgetWithText(ChoiceChip, 'General Awareness'));
    expect(find.textContaining('selected'), findsNothing);
    expect(find.textContaining('concept'), findsNothing);
    expect(_startEnabled(tester), isFalse);

    await _tap(tester, find.text('Select all'));
    bool allOn() => tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .every((c) => c.selected);
    expect(allOn(), isTrue);
    expect(_startEnabled(tester), isTrue);
    await _tap(tester, find.text('Clear'));
    expect(
      tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .any((c) => c.selected),
      isFalse,
    );
  });

  testWidgets('Free: 5/10 open, 20/30/40 locked with upgrade', (tester) async {
    await _open(tester, setsUsed: 1);
    for (final n in [5, 10]) {
      expect(find.widgetWithText(ChoiceChip, '$n'), findsOneWidget);
    }
    for (final n in [20, 30, 40]) {
      expect(find.widgetWithText(ActionChip, '$n'), findsOneWidget);
    }
    expect(find.text('1 of 2 practice sets left today'), findsOneWidget);
    await _tap(tester, find.widgetWithText(ActionChip, '20'));
    expect(find.text('See Pro plans'), findsOneWidget);
  });

  testWidgets('Premium: up to 40, button shows the count', (tester) async {
    await _open(tester, pro: true);
    for (final n in [5, 10, 20, 30, 40]) {
      expect(find.widgetWithText(ChoiceChip, '$n'), findsOneWidget);
    }
    await _tap(tester, find.widgetWithText(ChoiceChip, '40'));
    expect(find.text('Start Practice – 40 Questions'), findsOneWidget);
  });

  testWidgets('new student, bank has enough: starts from the bank', (
    tester,
  ) async {
    await _open(tester, targetExamId: null);
    await _pickTopic(tester);
    await _tap(tester, find.text('Start Practice – 10 Questions'));
    await _settleTest(tester);
    expect(find.text('Railway Preparation'), findsNothing, reason: 'opened');
    expect(_startedSource('rrb_ntpc'), 'bank');
  });

  testWidgets('bank short, AI set left: uses AI automatically', (tester) async {
    await _open(tester, available: 4);
    await _pickTopic(tester);
    await _tap(tester, find.text('Start Practice – 10 Questions'));
    await _settleTest(tester);
    expect(find.text('Not enough stored questions'), findsNothing);
    expect(_startedSource('rrb_ntpc'), 'ai');
  });

  testWidgets('bank short, no AI left: explains, offers available only', (
    tester,
  ) async {
    await _open(tester, available: 4, aiSetsUsed: 1);
    await _pickTopic(tester);
    await _tap(tester, find.text('Start Practice – 10 Questions'));
    expect(find.text('Not enough stored questions'), findsOneWidget);
    expect(find.text('Use AI-generated questions'), findsNothing);
    await _tap(tester, find.text('Change selection'));
    expect(find.text('Railway Preparation'), findsOneWidget);
    expect(_startedSource('rrb_ntpc'), isNull, reason: 'nothing started');

    await _tap(tester, find.text('Start Practice – 10 Questions'));
    await _tap(tester, find.text('Practise 4 questions'));
    await _settleTest(tester);
    expect(_startedSource('rrb_ntpc'), 'bank');
  });

  testWidgets('daily sets used: explains before sending anything', (
    tester,
  ) async {
    await _open(tester, setsUsed: 2);
    await _pickTopic(tester);
    await _tap(tester, find.text('Start Practice – 10 Questions'));
    expect(find.text("You have used today's free sets"), findsOneWidget);
    expect(_startedSource('rrb_ntpc'), isNull);
  });

  testWidgets('old /syllabus/:examId link opens that exam in its category', (
    tester,
  ) async {
    await _open(tester, route: AppRoutes.syllabusFor('ssc_cgl'));
    expect(find.text('SSC Preparation'), findsOneWidget);
    expect(_chipSelected(tester, 'SSC CGL'), isTrue);
  });

  testWidgets("SSC: exam → subject → concept tree → start practice", (
    tester,
  ) async {
    await _open(tester, route: AppRoutes.prepareFor("ssc"), targetExamId: null);
    expect(find.text("SSC Preparation"), findsOneWidget);
    for (final n in [
      "SSC CGL",
      "SSC JE (Civil, Electrical, Mechanical)",
      "SSC Selection Post (Graduation)",
    ]) {
      expect(find.widgetWithText(ChoiceChip, n), findsOneWidget);
    }
    // JE shows its three engineering disciplines as separate subjects.
    await _tap(
      tester,
      find.widgetWithText(ChoiceChip, "SSC JE (Civil, Electrical, Mechanical)"),
    );
    expect(
      find.widgetWithText(
        ChoiceChip,
        "General Engineering (Civil & Structural)",
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ChoiceChip, "General Engineering (Electrical)"),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ChoiceChip, "Quantitative Aptitude"),
      findsNothing,
    );

    await _tap(tester, find.widgetWithText(ChoiceChip, "SSC CGL"));
    await _tap(
      tester,
      find.widgetWithText(ChoiceChip, "General Intelligence & Reasoning"),
    );
    expect(find.byType(ConceptTree), findsOneWidget);
    expect(find.textContaining("official verification pending"), findsNothing);
    await _tap(tester, find.byKey(const ValueKey("check_sr.semantic_analogy")));
    expect(find.text("Chapters & concepts · 1 concept"), findsOneWidget);
    await _tap(tester, find.text("Start Practice – 10 Questions"));
    await _settleTest(tester);
    expect(
      find.text("SSC Preparation"),
      findsNothing,
      reason: "practice opened",
    );
    expect(_startedSource("ssc_cgl"), isNotNull);
  });
}
