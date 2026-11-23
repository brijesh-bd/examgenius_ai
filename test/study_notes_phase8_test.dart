import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/library/data/mock_library_repository.dart';
import 'package:examgenius_ai/features/library/domain/library_models.dart';
import 'package:examgenius_ai/features/library/presentation/providers/library_providers.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/notes_library.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/revision_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _content = NoteContent(
  overview: 'Overview of Percentage.',
  concepts: [NoteConcept('Percent', 'Per hundred.')],
  formulas: [
    NoteFormula('Percentage', 'P = part / whole × 100', 'share out of 100'),
  ],
  keyPoints: ['10% of x = x / 10'],
);

StudyNote _note(
  String id,
  String cat,
  String topic, {
  bool bookmarked = false,
  String personal = '',
}) => StudyNote(
  id: id,
  category: cat,
  examId: cat == 'ssc' ? 'ssc_cgl' : 'rrb_ntpc',
  examName: cat == 'ssc' ? 'SSC CGL' : 'RRB NTPC',
  subjectId: 'quant',
  subjectName: 'Quant',
  topicId: 'quant.$topic',
  topicName: topic,
  language: 'en',
  level: NoteLevel.examStandard,
  createdAt: DateTime(2026, 11, 20),
  content: _content,
  bookmarked: bookmarked,
  personalNote: personal,
);

/// Records the history call and serves one attempt.
class _HistoryLibrary extends MockLibraryRepository {
  _HistoryLibrary() : super(latency: Duration.zero);
  final calls = <String>[];

  @override
  Future<List<SetAttempt>> attempts(String setId) async {
    calls.add(setId);
    return [
      SetAttempt(
        id: 'att_1',
        resultId: 'res_1',
        attemptNo: 1,
        score: 7.5,
        maxScore: 10,
        accuracy: 0.8,
        completedAt: DateTime(2026, 11, 21, 10),
      ),
    ];
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required MockStudyNotesRepository notes,
  MockLibraryRepository? library,
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
      'targetExamId': 'rrb_ntpc',
    }),
    'locale_code': 'en',
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        studyNotesRepositoryProvider.overrideWithValue(notes),
        if (library != null)
          libraryRepositoryProvider.overrideWithValue(library),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> _openSscNotes(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('SSC Notes'), 200);
  await tester.tap(find.text('SSC Notes'));
  await tester.pumpAndSettle();
}

void main() {
  test('flashcards come from concepts and formulas', () {
    final cards = flashcardsFrom(_content);
    expect(cards.map((c) => c.front), ['Percent', 'Percentage']);
    expect(cards.last.back, contains('P = part / whole × 100'));
    expect(flashcardsFrom(const NoteContent(overview: 'x')), isEmpty);
  });

  test('notes view tabs map to backend query and local matching', () {
    const b = NotesFilter(view: NotesView.bookmarked);
    expect(b.toQuery()['bookmarked'], 'true');
    expect(b.isActive, isFalse); // a tab, not a filter
    expect(b.matches(_note('a', 'ssc', 'x', bookmarked: true)), isTrue);
    expect(b.matches(_note('a', 'ssc', 'x')), isFalse);
    const p = NotesFilter(view: NotesView.personal);
    expect(p.toQuery()['hasPersonalNote'], 'true');
    expect(p.matches(_note('a', 'ssc', 'x', personal: 'mine')), isTrue);
    expect(p.matches(_note('a', 'ssc', 'x', personal: '  ')), isFalse);
  });

  testWidgets('bookmark, personal note, tabs, flashcards and delete', (
    tester,
  ) async {
    final repo =
        MockStudyNotesRepository(latency: const Duration(milliseconds: 20))
          ..add(_note('s1', 'ssc', 'Percentage'))
          ..add(_note('s2', 'ssc', 'Ratio'))
          ..add(_note('r1', 'railway', 'Railway Topic', bookmarked: true));
    await _pump(tester, notes: repo);
    await _openSscNotes(tester);

    // Bookmarked tab is empty for SSC (the Railway bookmark never shows here).
    await tester.tap(find.text('Bookmarked'));
    await tester.pumpAndSettle();
    expect(find.text('No bookmarked notes here yet'), findsOneWidget);
    expect(find.text('Railway Topic'), findsNothing);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Open a note → bookmark it (saved on the backend first).
    await tester.tap(find.text('Percentage'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Note bookmarked'), findsOneWidget);
    expect(repo.saved.firstWhere((n) => n.id == 's1').bookmarked, isTrue);
    expect(find.byTooltip('Remove bookmark'), findsOneWidget);

    // Personal note.
    await tester.tap(find.text('Add personal note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Use the 10% trick');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Personal note saved'), findsOneWidget);
    expect(find.text('Use the 10% trick'), findsOneWidget);
    expect(
      repo.saved.firstWhere((n) => n.id == 's1').personalNote,
      'Use the 10% trick',
    );

    // Flashcards: front, then tap to flip.
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Percent'), findsOneWidget);
    await tester.tap(find.text('Percent'));
    await tester.pumpAndSettle();
    expect(find.text('Per hundred.'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Back in the list: tabs reflect the saved changes.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookmarked'));
    await tester.pumpAndSettle();
    expect(find.text('Percentage'), findsOneWidget);
    expect(find.text('Ratio'), findsNothing);
    await tester.tap(find.text('Personal notes'));
    await tester.pumpAndSettle();
    expect(find.text('Percentage'), findsOneWidget);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Delete only after confirming.
    await tester.tap(find.text('Ratio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete note'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this note?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete note'));
    await tester.pumpAndSettle();
    expect(find.text('Note deleted'), findsOneWidget);
    expect(find.text('Ratio'), findsNothing);
    expect(repo.saved.map((n) => n.id), isNot(contains('s2')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed bookmark keeps the old state and shows the error', (
    tester,
  ) async {
    final repo = _FailingUpdates(latency: Duration.zero)
      ..add(_note('s1', 'ssc', 'Percentage'));
    await _pump(tester, notes: repo);
    await _openSscNotes(tester);
    await tester.tap(find.text('Percentage'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Note bookmarked'), findsNothing);
    expect(find.byTooltip('Bookmark'), findsOneWidget); // unchanged
  });

  testWidgets('Practice History lists attempts of a set', (tester) async {
    final library = _HistoryLibrary()
      ..add(
        LibrarySet(
          id: 'set1',
          category: 'ssc',
          examId: 'ssc_cgl',
          examName: 'SSC CGL',
          subjects: const [NamedRef(id: 'quant', name: 'Quant')],
          topics: const [
            TopicRef(
              id: 'quant.percentage',
              name: 'Percentage',
              subjectId: 'quant',
            ),
          ],
          difficulty: Difficulty.medium,
          language: 'en',
          questionCount: 10,
          createdAt: DateTime(2026, 11, 20),
          stats: const SetStats(
            attempts: 1,
            latestScore: 7.5,
            latestMaxScore: 10,
            latestAccuracy: 0.8,
            latestResultId: 'res_1',
          ),
        ),
      );
    await _pump(
      tester,
      notes: MockStudyNotesRepository(latency: Duration.zero),
      library: library,
    );
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SSC Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(library.calls, ['set1']);
    expect(find.text('Practice history'), findsOneWidget);
    expect(find.text('Attempt 1'), findsOneWidget);
    expect(find.textContaining('Score 7.5/10 · Accuracy 80%'), findsOneWidget);
  });
}

class _FailingUpdates extends MockStudyNotesRepository {
  _FailingUpdates({super.latency});

  @override
  Future<StudyNote> update(
    String id, {
    bool? bookmarked,
    String? personalNote,
  }) => Future.error(Exception('offline'));
}
