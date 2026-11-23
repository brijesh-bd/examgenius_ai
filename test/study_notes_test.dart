import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(
  WidgetTester tester,
  MockStudyNotesRepository repo,
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
        studyNotesRepositoryProvider.overrideWithValue(repo),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
}

/// Home → AI Study Notes → Railway → RRB NTPC → Percentage → Create Notes.
Future<void> _openCreateNotes(WidgetTester tester) async {
  await tester.tap(find.text('AI Study Notes'));
  await tester.pumpAndSettle();
  expect(find.text('Choose a category'), findsOneWidget);
  await tester.tap(find.text('Railway'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('RRB NTPC'));
  await tester.pumpAndSettle();
  expect(find.text('Mathematics'), findsOneWidget); // existing syllabus
  await tester.scrollUntilVisible(find.text('Percentage'), 200);
  await tester.tap(find.text('Percentage'));
  await tester.pumpAndSettle();
  expect(find.text('Create Notes'), findsOneWidget);
}

void main() {
  test('NoteContent.fromJson reads the backend shape', () {
    final n = StudyNote.fromJson({
      'id': 'n1',
      'category': 'ssc',
      'examId': 'ssc_cgl',
      'examName': 'SSC CGL',
      'subjectId': 'quant',
      'subjectName': 'Quant',
      'topicId': 'quant.percentage',
      'topicName': 'Percentage',
      'language': 'hi',
      'explanationLevel': 'advanced',
      'contentVersion': 1,
      'createdAt': '2026-11-23T10:00:00.000Z',
      'content': {
        'overview': 'o',
        'graphs': [
          {
            'title': 'g',
            'xLabel': 'x',
            'yLabel': 'y',
            'points': [
              {'x': 1, 'y': 2.5},
            ],
            'caption': '',
          },
        ],
        'tables': [
          {
            'title': 't',
            'headers': ['a', 'b'],
            'rows': [
              ['1', '2'],
            ],
          },
        ],
        'mcqs': [
          {
            'question': 'q',
            'options': ['a', 'b', 'c', 'd'],
            'correctIndex': 2,
            'explanation': 'e',
          },
        ],
      },
    });
    expect(n.level, NoteLevel.advanced);
    expect(n.content!.graphs.single.points.single.y, 2.5);
    expect(n.content!.tables.single.rows.single, ['1', '2']);
    expect(n.content!.mcqs.single.correctIndex, 2);
    expect(n.content!.tips, isEmpty);
  });

  test('NotesRequest sends sections in a stable order', () {
    final r = NotesRequest(
      examId: 'rrb_ntpc',
      topicId: 'quant.percentage',
      language: 'en',
      level: NoteLevel.basic,
      sections: {NoteSection.mcqs, NoteSection.explanation},
    );
    expect(r.toJson()['sections'], ['explanation', 'mcqs']);
    expect(r.toJson()['level'], 'basic');
  });

  testWidgets(
    'Home → AI Study Notes → topic → generate → notes with contents',
    (tester) async {
      final repo = MockStudyNotesRepository(
        latency: const Duration(milliseconds: 50),
      );
      await _pumpApp(tester, repo);
      expect(
        find.text('Daily Practice'),
        findsNothing,
      ); // card replaced on Home
      await _openCreateNotes(tester);

      expect(find.text('Exam Standard'), findsOneWidget);
      // Turn on graphs (off by default).
      await tester.tap(find.text('Graphs (where useful)'));
      await tester.pump();

      await tester.tap(find.text('Generate Complete Notes'));
      await tester.pumpAndSettle();

      expect(repo.saved, hasLength(1));
      expect(find.text('Contents'), findsOneWidget);
      expect(find.text('Saved to your Library'), findsOneWidget);
      for (final s in [
        'Topic Overview',
        'Detailed Explanation',
        'Formulas & Tables',
      ]) {
        expect(find.text(s), findsWidgets);
      }

      // MCQ answer hidden until asked.
      await tester.tap(
        find.text('Important Questions & MCQs').first,
      ); // TOC jump
      await tester.pumpAndSettle();
      expect(find.text('Because B1.'), findsNothing);
      await tester.ensureVisible(find.text('Show answer'));
      await tester.tap(find.text('Show answer'));
      await tester.pumpAndSettle();
      expect(find.text('Because B1.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed generation shows an error and saves nothing', (
    tester,
  ) async {
    final repo = MockStudyNotesRepository(
      latency: const Duration(milliseconds: 50),
      fail: true,
    );
    await _pumpApp(tester, repo);
    await _openCreateNotes(tester);
    await tester.tap(find.text('Generate Complete Notes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Notes could not be generated. Nothing was saved.'),
      findsOneWidget,
    );
    expect(find.text('Saved to your Library'), findsNothing);
    expect(find.text('Contents'), findsNothing);
    expect(repo.saved, isEmpty);
  });

  testWidgets(
    "Library: My Study Notes per category, filters, search, open full note",
    (tester) async {
      StudyNote note(
        String id,
        String cat,
        String exam,
        String topic, {
        String lang = "en",
      }) => StudyNote(
        id: id,
        category: cat,
        examId: exam,
        examName: exam.toUpperCase(),
        subjectId: "quant",
        subjectName: "Quant",
        topicId: "quant.$topic",
        topicName: topic,
        language: lang,
        level: NoteLevel.examStandard,
        createdAt: DateTime(2026, 11, 20),
        content: NoteContent(overview: "Overview of $topic."),
      );
      final repo =
          MockStudyNotesRepository(latency: const Duration(milliseconds: 30))
            ..add(note("r1", "railway", "rrb_ntpc", "Railway Topic"))
            ..add(note("s1", "ssc", "ssc_cgl", "Percentage"))
            ..add(note("s2", "ssc", "ssc_cgl", "Ratio", lang: "hi"));
      await _pumpApp(tester, repo);

      await tester.tap(find.text("Library"));
      await tester.pumpAndSettle();
      expect(find.text("My Practice Sets"), findsOneWidget);
      await tester.scrollUntilVisible(find.text("SSC Notes"), 200);
      expect(find.text("My Study Notes"), findsOneWidget);
      expect(find.text("2 notes"), findsOneWidget);
      expect(find.text("1 note"), findsOneWidget);

      await tester.tap(find.text("SSC Notes"));
      await tester.pumpAndSettle();
      expect(find.text("Percentage"), findsOneWidget);
      expect(find.text("Ratio"), findsOneWidget);
      expect(find.text("Railway Topic"), findsNothing); // categories never mix
      expect(find.textContaining("Created"), findsNWidgets(2));

      // Language filter.
      final languageChip = find.widgetWithText(FilterChip, "Language");
      await tester.ensureVisible(languageChip); // filter row scrolls sideways
      await tester.pumpAndSettle();
      await tester.tap(languageChip);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text("हिन्दी"),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Ratio"), findsOneWidget);
      expect(find.text("Percentage"), findsNothing);
      await tester.tap(find.text("Clear filters"));
      await tester.pumpAndSettle();

      // Search.
      await tester.enterText(find.byType(TextField), "perc");
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text("Percentage"), findsOneWidget);
      expect(find.text("Ratio"), findsNothing);

      // Open the full note.
      await tester.tap(find.text("Percentage"));
      await tester.pumpAndSettle();
      expect(find.text("Contents"), findsOneWidget);
      expect(find.text("Overview of Percentage."), findsOneWidget);
      // Learning path for this note loads in the background (mock syllabus).
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets("Library: empty notes category offers Create notes", (
    tester,
  ) async {
    await _pumpApp(tester, MockStudyNotesRepository(latency: Duration.zero));
    await tester.tap(find.text("Library"));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text("Banking Notes"), 200);
    await tester.tap(find.text("Banking Notes"));
    await tester.pumpAndSettle();
    expect(find.text("No Banking notes yet"), findsOneWidget);
    expect(find.text("Create notes"), findsOneWidget);
  });
}
