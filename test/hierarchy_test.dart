import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/network/api_client.dart';
import 'package:examgenius_ai/core/routes/app_routes.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_syllabus_repository.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/data/sample_outline_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/note_outline.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/note_view_screen.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/section_reader_screen.dart';
import 'package:examgenius_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Outline whose first chapter has nested subtopics (paths).
class _NestedOutlineRepo extends SampleOutlineRepository {
  _NestedOutlineRepo() : super(latency: Duration.zero);

  @override
  Future<NoteOutline> outline(OutlineKey k) async => NoteOutline(
    examId: k.examId,
    unitId: k.unitId,
    title: 'Mauryan Empire',
    status: 'approved',
    version: 1,
    language: k.language,
    mode: k.mode,
    chapters: const [
      OutlineChapter(
        id: 'mauryan',
        title: 'Mauryan Empire',
        sections: [
          OutlineSection(
            id: 'background',
            title: 'Background',
            state: SectionState.completed,
            contentStatus: ContentStatus.ready,
          ),
          OutlineSection(
            id: 'ashoka.kalinga',
            title: 'Kalinga War',
            state: SectionState.pending,
            path: ['Ashoka'],
            contentStatus: ContentStatus.incomplete,
          ),
          OutlineSection(
            id: 'ashoka.dhamma',
            title: 'Dhamma',
            state: SectionState.pending,
            path: ['Ashoka'],
          ),
        ],
      ),
    ],
    continueAt: (chapterId: 'mauryan', sectionId: 'ashoka.kalinga'),
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  OutlineRepository? outlines,
  String locale = 'en',
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
    'locale_code': locale,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        outlineRepositoryProvider.overrideWithValue(
          outlines ?? SampleOutlineRepository(latency: Duration.zero),
        ),
        studyNotesRepositoryProvider.overrideWithValue(
          MockStudyNotesRepository(latency: Duration.zero),
        ),
      ],
      child: const ExamGeniusApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 2)); // splash
  await tester.pumpAndSettle();
}

Future<void> _go(WidgetTester tester, String route) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).push(route);
  await tester.pumpAndSettle();
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2)); // mock delays
  await tester.pumpAndSettle();
}

void main() {
  recommendationTests();
  testWidgets(
    'learning path: nested chapters → sections, progress and readiness, open section',
    (tester) async {
      await _pumpApp(tester);
      await _go(tester, AppRoutes.notesPathFor('rrb_ntpc', 'quant'));

      // The first topic has an outline: expandable with separate progress / readiness.
      expect(find.textContaining('0 of 5 sections studied'), findsWidgets);
      expect(find.textContaining('Content ready: 0 of 5'), findsWidgets);
      expect(
        find.textContaining('Next recommended: Sample section 1.1'),
        findsOneWidget,
      );

      await tester.tap(find.textContaining('0 of 5 sections studied').first);
      await tester.pumpAndSettle();
      expect(find.text('Sample chapter 1: Introduction'), findsOneWidget);
      await tester.tap(find.text('Sample chapter 1: Introduction'));
      await tester.pumpAndSettle();
      expect(find.text('Sample section 1.2: Key terms'), findsOneWidget);
      expect(find.text('Not prepared yet'), findsWidgets);

      // Collapse again.
      await tester.tap(find.text('Sample chapter 1: Introduction'));
      await tester.pumpAndSettle();
      expect(find.text('Sample section 1.2: Key terms'), findsNothing);

      // Next recommended opens the section reader.
      await tester.tap(find.textContaining('Next recommended'));
      await _settle(tester);
      expect(find.text('Section 1 of 5'), findsOneWidget);
      await _settle(tester);
    },
  );

  testWidgets(
    'outline: nested subtopics; content coverage separate from progress',
    (tester) async {
      await _pumpApp(tester, outlines: _NestedOutlineRepo());
      await _go(
        tester,
        AppRoutes.notesOutlineFor(
          'ssc_cgl',
          'general_awareness.history.ancient',
        ),
      );
      expect(
        find.text('Content coverage: 1 of 3 sections ready'),
        findsOneWidget,
      );
      expect(find.text('1 of 3 sections completed'), findsOneWidget);
      expect(
        find.text('Ashoka'),
        findsOneWidget,
        reason: 'one subtopic heading for two sections',
      );
      expect(find.textContaining('Incomplete — retry'), findsOneWidget);
      await _settle(tester);
    },
  );

  testWidgets('outline in Hindi', (tester) async {
    await _pumpApp(tester, outlines: _NestedOutlineRepo(), locale: 'hi');
    await _go(
      tester,
      AppRoutes.notesOutlineFor('ssc_cgl', 'general_awareness.history.ancient'),
    );
    expect(find.text('सामग्री कवरेज: 3 में से 1 सेक्शन तैयार'), findsOneWidget);
    expect(find.textContaining('अधूरी'), findsOneWidget);
    await _settle(tester);
  });

  testWidgets(
    'reader: "being prepared" (202) → Check again loads the section',
    (tester) async {
      final repo = SampleOutlineRepository(latency: Duration.zero)
        ..failNext = const SectionGeneratingException();
      await _pumpApp(tester, outlines: repo);
      await _go(tester, AppRoutes.notesOutlineFor('rrb_ntpc', 'unit.x'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('This section is being prepared'), findsOneWidget);
      await tester.tap(find.text('Check again'));
      await tester.pumpAndSettle();
      expect(find.text('This section is being prepared'), findsNothing);
      expect(find.text('Sample section 1.1: Overview'), findsWidgets);
      await _settle(tester);
    },
  );

  testWidgets(
    'reader: incomplete after repairs (422) lists what is missing; retry',
    (tester) async {
      final repo = SampleOutlineRepository(latency: Duration.zero)
        ..failNext = const ApiException(
          'incomplete',
          statusCode: 422,
          code: 'CONTENT_INCOMPLETE',
          details: {
            'missingConcepts': ['james_prinsep', 'third_council'],
            'missingBlocks': ['timeline'],
          },
        );
      await _pumpApp(tester, outlines: repo);
      await _go(tester, AppRoutes.notesOutlineFor('rrb_ntpc', 'unit.x'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('could not be completed to our quality standard'),
        findsOneWidget,
      );
      expect(
        find.text('Still missing: james prinsep, third council, timeline'),
        findsOneWidget,
      );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Sample section 1.1: Overview'), findsWidgets);
      await _settle(tester);
    },
  );

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  StudyNote note(NoteContent content) => StudyNote(
    id: 'n1',
    category: 'ssc',
    examId: 'ssc_cgl',
    examName: 'SSC CGL',
    subjectId: 'general_awareness',
    subjectName: 'General Awareness',
    topicId: 't',
    topicName: 'Ashoka',
    language: 'en',
    level: NoteLevel.examStandard,
    createdAt: DateTime(2026),
    content: content,
  );

  testWidgets('status chips never claim more than the server says', (
    tester,
  ) async {
    OpenedSection opened({
      String? status,
      String? review,
      String? verification,
      String? basis,
    }) => (
      note: note(const NoteContent(overview: 'o')),
      source: 'cache',
      isSample: false,
      contentStatus: status,
      review: review,
      verification: verification,
      coverageBasis: basis,
    );
    await tester.pumpWidget(
      host(
        ContentStatusBanner(
          opened: opened(
            status: 'published',
            review: 'auto',
            verification: 'unverified',
            basis: 'structure_only',
          ),
        ),
      ),
    );
    expect(find.text('AI-checked · not human-reviewed'), findsOneWidget);
    expect(find.text('Facts not independently verified'), findsOneWidget);
    expect(find.textContaining('structure only'), findsOneWidget);

    await tester.pumpWidget(
      host(
        ContentStatusBanner(
          opened: opened(
            status: 'approved',
            review: 'human',
            verification: 'sources_listed',
            basis: 'manifest',
          ),
        ),
      ),
    );
    expect(find.text('Reviewed by an expert'), findsOneWidget);
    expect(find.text('Facts not independently verified'), findsNothing);

    await tester.pumpWidget(
      host(
        ContentStatusBanner(
          opened: opened(status: 'ready_for_review', review: 'auto'),
        ),
      ),
    );
    expect(find.text('Preview — awaiting review'), findsOneWidget);
  });

  testWidgets(
    'reader blocks: objectives, timeline, SQL output, derivations, practice, key facts',
    (tester) async {
      tester.view.physicalSize = const Size(400, 3000) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final content = NoteContent.fromJson({
        'overview': 'Overview text',
        'objectives': ['Explain the Kalinga War'],
        'timeline': [
          {'period': 'c. 261 BCE', 'event': 'Kalinga War'},
        ],
        'keyFacts': ['Edicts are in Brahmi'],
        'sqlExamples': [
          {
            'query': 'SELECT name FROM emp',
            'input': 'emp(name)',
            'output': {
              'headers': ['name'],
              'rows': [
                ['Asha'],
              ],
            },
            'explanation': 'Returns every name',
          },
        ],
        'derivations': [
          {
            'formula': 'A = P(1 + r)^n',
            'steps': ['After one year: P(1 + r)'],
          },
        ],
        'practice': [
          {'question': 'Fix: He go home.', 'answer': 'He goes home.'},
        ],
        'relatedConcepts': ['Dhamma'],
        'furtherLearning': ['Read the Rock Edicts'],
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyNotesRepositoryProvider.overrideWithValue(
              MockStudyNotesRepository(latency: Duration.zero),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: NoteViewScreen(noteId: 'n1', initial: note(content)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final t in [
        'Learning Objectives',
        'Timeline',
        'SQL Examples',
        'Derivations',
        'Important Facts',
        'Practice Exercises',
        'Related Concepts',
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      expect(find.text('c. 261 BCE'), findsOneWidget);
      expect(find.text('Expected output'), findsOneWidget);
      expect(find.text('Asha'), findsOneWidget);
      expect(find.text('1. After one year: P(1 + r)'), findsOneWidget);

      await tester.ensureVisible(find.text('Show answer'));
      await tester.tap(find.text('Show answer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('He goes home.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
  );
}

/// Sample outlines plus recommendations (continue + revise from practice).
class _RecsRepo extends SampleOutlineRepository {
  _RecsRepo(this.reviseTopicId, this.reviseName)
    : super(latency: Duration.zero);
  final String reviseTopicId;
  final String reviseName;

  @override
  Future<LearningRecommendations> recommendations({
    required String examId,
    required String subjectId,
    required String language,
  }) async => LearningRecommendations(
    items: 10,
    itemsCompleted: 1,
    continueSections: [
      (
        name: 'Sample section 1.2: Key terms',
        ref: (unitId: 'u', chapterId: 'ch1', sectionId: 's2'),
      ),
    ],
    revise: [
      ReviseTopic(
        topicId: reviseTopicId,
        name: reviseName,
        accuracy: 0.25,
        attempted: 8,
        studied: false,
      ),
    ],
  );
}

void recommendationTests() {
  testWidgets(
    'learning path: continue where you left off; revise weak topics from practice',
    (tester) async {
      // Real async: the mock syllabus has a delay that fake time never runs.
      final syllabus = (await tester.runAsync(
        () => MockSyllabusRepository().fetchSyllabus('rrb_ntpc'),
      ))!;
      final quant = syllabus.subjects.firstWhere((s) => s.id == 'quant');
      final weak = quant.topics[1];
      await _pumpApp(tester, outlines: _RecsRepo(weak.id, weak.name));
      await _go(tester, AppRoutes.notesPathFor('rrb_ntpc', 'quant'));

      expect(find.text('Continue where you left off'), findsOneWidget);
      expect(find.text('Revise these topics'), findsOneWidget);
      expect(
        find.textContaining('25% accuracy in practice (8 questions)'),
        findsOneWidget,
      );
      expect(find.textContaining('Study the notes'), findsOneWidget);

      // Revise → opens that topic's notes (Create Notes for a topic without notes).
      await tester.tap(find.textContaining('25% accuracy'));
      await tester.pumpAndSettle();
      expect(find.text('Create Notes'), findsOneWidget);
      await _settle(tester);
    },
  );
}
