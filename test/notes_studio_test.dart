import 'dart:async';
import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/network/api_client.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/notes_studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails the next generation with a server error code (e.g. AI_OVERLOADED).
class _FailOnce extends MockStudyNotesRepository {
  _FailOnce(this.error) : super(latency: const Duration(milliseconds: 20));

  Object? error;
  final requests = <NotesRequest>[];

  @override
  Future<StudyNote> generate(NotesRequest request) async {
    requests.add(request);
    if (error case final e?) {
      error = null;
      throw e;
    }
    return super.generate(request);
  }
}

/// Streams one partial, then waits for [gate] before finishing.
class _Gated extends MockStudyNotesRepository {
  _Gated(this.gate) : super(latency: Duration.zero);

  final Future<void> gate;

  @override
  Stream<NotesStreamEvent> generateStream(
    NotesRequest request, {
    bool regenerate = false,
  }) async* {
    yield const NotesStatus(NotesStage.generating);
    yield const NotesPartial(NoteContent(overview: 'Partial overview so far'));
    await gate;
    final note = await generate(request);
    yield NotesDone(note, 'ai');
  }
}

Future<void> _pump(WidgetTester tester, MockStudyNotesRepository repo) async {
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
        studyNotesRepositoryProvider.overrideWithValue(repo),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
  await tester.tap(find.text('AI Study Notes'));
  await tester.pumpAndSettle();
}

Finder get _list => find.descendant(
  of: find.byType(NotesStudioScreen),
  matching: find.byType(ListView),
);

bool _selected(WidgetTester tester, String key) =>
    tester.widget<ChoiceChip>(find.byKey(ValueKey(key))).selected;

Future<void> _pickPercentage(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('subject_quant')));
  await tester.pumpAndSettle();
  await tester.dragUntilVisible(
    find.text('Percentage').hitTestable(),
    _list,
    const Offset(0, -150),
  );
  await tester.tap(find.text('Percentage'));
  await tester.pumpAndSettle();
}

void main() {
  test('complete request: coverage flag, no sections, exam level', () {
    const r = NotesRequest.complete(
      examId: 'rrb_ntpc',
      topicId: 'rm.percentage',
      language: 'hi',
    );
    expect(r.toJson(), {
      'examId': 'rrb_ntpc',
      'nodeId': 'rm.percentage',
      'language': 'hi',
      'level': 'exam',
      'coverage': 'complete',
    });
  });

  testWidgets('dropped connection: resumes once with the same request — no '
      'second generation, note saved once', (tester) async {
    final repo = MockStudyNotesRepository(latency: Duration.zero)
      ..dropNextStream = true;
    await _pump(tester, repo);
    await _pickPercentage(tester);
    await tester.tap(find.text('Generate complete notes'));
    await tester.pumpAndSettle();
    expect(repo.streamCalls, 2, reason: 'one automatic resume');
    expect(repo.saved, hasLength(1), reason: 'the resume found the saved note');
    expect(find.text('Saved to your Library'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // snackbar timer
  });

  testWidgets('notes appear while being written; real stage text', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repo = _Gated(gate.future);
    await _pump(tester, repo);
    await _pickPercentage(tester);
    await tester.tap(find.text('Generate complete notes'));
    await tester.pump();
    await tester.pump();
    // Partial content is on screen before the notes are finished.
    expect(find.byKey(const Key('liveNotes')), findsOneWidget);
    expect(find.text('Partial overview so far'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('generationStage'))).data,
      'Writing your notes · 1 parts so far',
    );
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Saved to your Library'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('category chips → exams of that category; a new category clears '
      'the exam, subject and topic', (tester) async {
    await _pump(tester, MockStudyNotesRepository(latency: Duration.zero));
    expect(_selected(tester, 'cat_railway'), isTrue);
    expect(_selected(tester, 'exam_rrb_ntpc'), isTrue);
    await _pickPercentage(tester);
    expect(find.byKey(const Key('topicOverview')), findsOneWidget);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('cat_banking')).hitTestable(),
      _list,
      const Offset(0, 300),
    );
    await tester.tap(find.byKey(const ValueKey('cat_banking')));
    await tester.pumpAndSettle();
    expect(_selected(tester, 'cat_banking'), isTrue);
    expect(find.byKey(const ValueKey('exam_ibps_po')), findsOneWidget);
    expect(find.byKey(const ValueKey('exam_rrb_ntpc')), findsNothing);
    expect(find.text('Subject'), findsNothing, reason: 'no exam chosen yet');
    expect(find.byKey(const Key('topicOverview')), findsNothing);
    expect(find.text('Select a topic to generate notes'), findsOneWidget);
  });

  testWidgets('overview failure never blocks generating the notes', (
    tester,
  ) async {
    final repo = MockStudyNotesRepository(latency: Duration.zero)
      ..failNextSummary = const ApiException('busy', statusCode: 503);
    await _pump(tester, repo);
    await _pickPercentage(tester);
    await tester.dragUntilVisible(
      find.textContaining('could not be loaded').hitTestable(),
      _list,
      const Offset(0, -200),
    );
    expect(
      find.text(
        'The overview could not be loaded. You can still generate the notes.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Generate complete notes'));
    await tester.pumpAndSettle();
    expect(repo.saved, hasLength(1));
    await tester.pump(const Duration(seconds: 5)); // snackbar timer
  });

  testWidgets('overloaded AI: specific message, selection kept, retry works', (
    tester,
  ) async {
    final repo = _FailOnce(
      const ApiException('overloaded', statusCode: 503, code: 'AI_OVERLOADED'),
    );
    await _pump(tester, repo);
    await _pickPercentage(tester);
    await tester.tap(find.text('Generate complete notes'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The AI model is overloaded right now (high demand). '
        'Please try again in a minute.',
      ),
      findsOneWidget,
    );
    expect(repo.saved, isEmpty);

    // Retry: same request object (same idempotency key on the server).
    await tester.tap(find.text('Generate complete notes'));
    await tester.pumpAndSettle();
    expect(repo.saved, hasLength(1));
    expect(identical(repo.requests[0], repo.requests[1]), isTrue);
    expect(repo.requests.last.complete, isTrue);
    expect(find.text('Saved to your Library'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // snackbar timer
  });
}
