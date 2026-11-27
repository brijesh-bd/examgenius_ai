import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/study_notes/data/mock_study_notes_repository.dart';
import 'package:examgenius_ai/features/study_notes/domain/learning_path.dart';
import 'package:examgenius_ai/features/study_notes/domain/study_note.dart';
import 'package:examgenius_ai/features/study_notes/presentation/providers/study_notes_providers.dart';
import 'package:examgenius_ai/core/routes/app_routes.dart';
import 'package:examgenius_ai/features/study_notes/presentation/screens/notes_studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

LearningItem _item(String id, int order, {String? topicId, String? unit}) =>
    LearningItem(
      id: id,
      name: unit ?? id,
      topicId: topicId ?? id,
      topicName: topicId ?? id,
      unitName: unit,
      order: order,
      status: LearningStatus.upcoming,
    );

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
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

/// Waits for background loads (mock syllabus has a fixed delay).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  group('models', () {
    test('next topics: syllabus-linked objects and legacy strings', () {
      final c = NoteContent.fromJson({
        'overview': 'o',
        'nextTopics': [
          {'id': 'quant.average', 'name': 'Average'},
          'Old free text',
          {'name': ''},
          42,
        ],
      });
      expect(c.nextTopics.map((t) => t.name), ['Average', 'Old free text']);
      expect(c.nextTopics.first.id, 'quant.average');
      expect(c.nextTopics.last.id, isNull);
    });

    test('path: next item, units, whole broad topic, progress', () {
      final p = LearningPath(
        examId: 'e',
        examName: 'E',
        category: 'banking',
        subjectId: 's',
        subjectName: 'S',
        currentId: 's.a',
        items: [
          _item('s.a', 1),
          _item('s.ds.arrays', 2, topicId: 's.ds', unit: 'Arrays'),
          _item('s.ds.trees', 3, topicId: 's.ds', unit: 'Trees'),
          _item('s.net', 4),
        ],
      );
      expect(p.nextAfter('s.a')!.id, 's.ds.arrays');
      expect(p.nextAfter('s.ds.arrays')!.id, 's.ds.trees');
      // Whole broad topic → the item after its last unit.
      expect(p.nextAfter('s.ds')!.id, 's.net');
      expect(p.nextAfter('s.net'), isNull);
      expect(p.item('s.ds.trees')!.fullName, 's.ds: Trees');
      expect(p.completed, 0);
      expect(p.total, 4);
    });
  });

  testWidgets(
    'next topic is tappable with prefill; mark completed; continue; learning path restores progress',
    (tester) async {
      final repo = MockStudyNotesRepository(
        latency: const Duration(milliseconds: 20),
      );
      await _pump(tester, repo);

      // A syllabus topic link (e.g. "study next") opens AI Study Notes with
      // RRB NTPC › Mathematics › Percentage preselected; generate in Hindi.
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push(AppRoutes.notesCreateFor('rrb_ntpc', 'quant.percentage'));
      await _settle(tester);
      expect(find.byType(NotesStudioScreen), findsOneWidget);
      await tester.dragUntilVisible(
        find.text('हिन्दी').hitTestable(),
        find.descendant(
          of: find.byType(NotesStudioScreen),
          matching: find.byType(ListView),
        ),
        const Offset(0, -200),
      );
      await tester.tap(find.text('हिन्दी'));
      await tester.pump();
      await tester.tap(find.text('Generate complete notes'));
      await _settle(tester);
      // The path panel loads after the mock syllabus delay.
      await _settle(tester);

      // Notes page: position in the path + progress.
      expect(find.textContaining('Topic 5 of'), findsOneWidget);
      expect(find.textContaining('0 of'), findsOneWidget);

      // "What to Study Next" rows come from the syllabus and open AI Study
      // Notes with exam, subject, topic and language filled in.
      await _tapVisible(tester, find.text('Ratio & Proportion'));
      expect(find.byType(NotesStudioScreen), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('subject_quant')))
            .selected,
        isTrue,
      ); // subject, not re-picked
      expect(find.text('Ratio & Proportion'), findsWidgets); // overview title
      final lang = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );
      expect(lang.selected, {'hi'});

      // Android back → the same note.
      await tester.pageBack();
      await _settle(tester);
      expect(find.text('Contents'), findsOneWidget);

      // Mark as completed (saved on the backend), progress updates.
      await tester.scrollUntilVisible(
        find.text('Mark as completed'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Mark as completed'));
      await _settle(tester);
      expect(find.text('Marked as completed'), findsOneWidget);
      expect(find.textContaining('1 of'), findsOneWidget);

      // Learning path: completed / current / upcoming, restored from the backend.
      final pathLink = find.text('Learning path').first;
      await tester.ensureVisible(pathLink);
      await tester.pumpAndSettle();
      await tester.tap(pathLink);
      await _settle(tester);
      expect(find.text('Upcoming').evaluate().isEmpty, isFalse);
      expect(find.textContaining('1 of'), findsOneWidget);
      expect(find.textContaining('Current:'), findsOneWidget); // first topic
      await tester.scrollUntilVisible(
        find.textContaining('Completed · Notes ready'),
        200,
      ); // Percentage
      expect(find.text('Upcoming'), findsWidgets);
      await tester.pageBack();
      await _settle(tester);

      // Continue to Next Topic → AI Study Notes for the next syllabus topic.
      await tester.ensureVisible(find.text('Continue to Next Topic'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue to Next Topic'));
      await _settle(tester);
      expect(find.byType(NotesStudioScreen), findsOneWidget);
      expect(find.text('Ratio & Proportion'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
