import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/network/api_client.dart';
import 'package:examgenius_ai/core/routes/app_routes.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/data/sample_outline_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/note_outline.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpOutline(
  WidgetTester tester,
  SampleOutlineRepository repo,
) async {
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
      'targetExamId': 'rrb_ntpc',
    }),
    'locale_code': 'en',
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        outlineRepositoryProvider.overrideWithValue(repo),
        studyNotesRepositoryProvider.overrideWithValue(
          MockStudyNotesRepository(latency: Duration.zero),
        ),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first))
      .push(AppRoutes.notesOutlineFor('rrb_ntpc', 'unit.x'));
  await tester.pumpAndSettle();
}

/// A topic without any chapter index; building one leaves it pending review.
class _NoIndexRepository extends SampleOutlineRepository {
  _NoIndexRepository() : super(latency: Duration.zero);

  int requests = 0;

  @override
  Future<NoteOutline> outline(OutlineKey k) async => throw ApiException(
    'No outline',
    statusCode: 404,
    code: requests == 0 ? 'NO_OUTLINE' : 'OUTLINE_PENDING_REVIEW',
  );

  @override
  Future<ChapterIndexStatus> requestChapterIndex(
    String examId,
    String unitId,
  ) async {
    requests++;
    return ChapterIndexStatus.pendingReview;
  }
}

void main() {
  test('outline JSON: AI-reviewed index and revision plan', () {
    final o = NoteOutline.fromJson({
      'examId': 'ibps_po',
      'unitId': 'quant.percentage',
      'source': 'ai_reviewed',
      'revisionPlan': ['Revise fractions', 'Timed practice'],
      'chapters': const [],
    });
    expect(o.fromAi, isTrue);
    expect(o.revisionPlan, ['Revise fractions', 'Timed practice']);
    expect(
      NoteOutline.fromJson({'examId': 'x', 'unitId': 'y'}).fromAi,
      isFalse,
    );
  });

  testWidgets('chapter builder: no index → build → waiting for review', (
    tester,
  ) async {
    final repo = _NoIndexRepository();
    await _pumpOutline(tester, repo);
    expect(find.text('No chapter index for this topic yet'), findsOneWidget);

    await tester.tap(find.text('Build chapter index'));
    await tester.pumpAndSettle();
    expect(repo.requests, 1);
    expect(find.text('Chapter index waiting for review'), findsOneWidget);
    expect(find.text('Build chapter index'), findsNothing);
  });

  testWidgets('outline: sample label, sections, read, complete, next', (
    tester,
  ) async {
    await _pumpOutline(tester, SampleOutlineRepository(latency: Duration.zero));

    expect(find.textContaining('Not AI-generated'), findsOneWidget);
    expect(find.text('Draft outline — under review'), findsOneWidget);
    expect(find.text('0 of 5 sections completed'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // Fixture content is always labelled.
    expect(find.textContaining('Not AI-generated'), findsOneWidget);
    expect(find.text('Section 1 of 5'), findsOneWidget);

    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsWidgets);

    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Section 2 of 5'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 sections completed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // mock delays
  });

  testWidgets('quota exhausted: friendly message, stays on section, retry', (
    tester,
  ) async {
    final repo = SampleOutlineRepository(latency: Duration.zero)
      ..failNext = const ApiException(
        'The AI service has reached its usage limit.',
        statusCode: 503,
        code: 'AI_QUOTA_EXHAUSTED',
      );
    await _pumpOutline(tester, repo);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("Today's AI limit has been reached"),
      findsOneWidget,
    );
    expect(
      find.text('Section 1 of 5'),
      findsOneWidget,
      reason: 'selection kept',
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Today's AI limit"), findsNothing);
    expect(find.text('Sample section 1.1: Overview'), findsWidgets);
    await tester.pump(const Duration(seconds: 2)); // mock delays
  });
}
