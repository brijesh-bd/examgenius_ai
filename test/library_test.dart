import 'dart:convert';

import 'package:examgenius_ai/app.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/library/data/mock_library_repository.dart';
import 'package:examgenius_ai/features/library/domain/library_models.dart';
import 'package:examgenius_ai/features/library/presentation/providers/library_providers.dart';
import 'package:examgenius_ai/features/library/presentation/widgets/library_set_card.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

LibrarySet _set(
  String id, {
  required String category,
  required String examId,
  required String examName,
  Difficulty difficulty = Difficulty.medium,
  String language = 'en',
  DateTime? createdAt,
  SetStats stats = const SetStats(),
}) => LibrarySet(
  id: id,
  category: category,
  examId: examId,
  examName: examName,
  subjects: const [NamedRef(id: 'quant', name: 'Quantitative Aptitude')],
  topics: const [
    TopicRef(id: 'quant.percentage', name: 'Percentage', subjectId: 'quant'),
  ],
  difficulty: difficulty,
  language: language,
  questionCount: 10,
  createdAt: createdAt ?? DateTime(2026, 11, 20),
  stats: stats,
);

void main() {
  group('models', () {
    test('LibrarySet.fromJson reads the backend shape', () {
      final s = LibrarySet.fromJson({
        'id': 's1',
        'category': 'banking',
        'examId': 'ibps_po',
        'examName': 'IBPS PO',
        'subjects': [
          {'id': 'quant', 'name': 'Quant'},
        ],
        'topics': [
          {'id': 'quant.si', 'name': 'Simple Interest', 'subjectId': 'quant'},
        ],
        'difficulty': 'hard',
        'language': 'hi',
        'questionCount': 5,
        'isPreview': false,
        'createdAt': '2026-11-20T10:00:00.000Z',
        'stats': {
          'attempts': 2,
          'latestScore': 3.5,
          'latestMaxScore': 5,
          'latestAccuracy': 0.8,
          'latestResultId': 'res_1',
          'bestScore': 4,
          'lastAttemptAt': '2026-11-21T10:00:00.000Z',
        },
      });
      expect(s.category, 'banking');
      expect(s.difficulty, Difficulty.hard);
      expect(s.topics.single.subjectId, 'quant');
      expect(s.stats.attempted, isTrue);
      expect(s.stats.latestScore, 3.5);
      expect(s.stats.latestResultId, 'res_1');
    });

    test('filter → query parameters; clearing with () => null', () {
      final f = const LibraryFilter().copyWith(
        examId: () => 'rrb_ntpc',
        difficulty: () => Difficulty.easy,
        query: ' time ',
        sort: LibrarySort.oldest,
      );
      expect(f.toQuery(), {
        'examId': 'rrb_ntpc',
        'difficulty': 'easy',
        'q': 'time',
        'sort': 'oldest',
      });
      expect(f.isActive, isTrue);
      expect(f.copyWith(examId: () => null).examId, isNull);
      expect(const LibraryFilter(sort: LibrarySort.oldest).isActive, isFalse);
    });
  });

  group('mock repository', () {
    test('categories never mix; filters and sort apply', () async {
      final repo = MockLibraryRepository(latency: Duration.zero)
        ..add(
          _set(
            'r1',
            category: 'railway',
            examId: 'rrb_ntpc',
            examName: 'RRB NTPC',
            createdAt: DateTime(2026, 1, 1),
          ),
        )
        ..add(
          _set(
            'r2',
            category: 'railway',
            examId: 'rrb_je',
            examName: 'RRB JE',
            difficulty: Difficulty.hard,
            createdAt: DateTime(2026, 2, 1),
          ),
        )
        ..add(
          _set(
            'b1',
            category: 'banking',
            examId: 'ibps_po',
            examName: 'IBPS PO',
          ),
        );

      final railway = await repo.listSets('railway', const LibraryFilter());
      expect(railway.items.map((s) => s.id), ['r2', 'r1']); // latest first
      final banking = await repo.listSets('banking', const LibraryFilter());
      expect(banking.items.map((s) => s.id), ['b1']);

      final hard = await repo.listSets(
        'railway',
        const LibraryFilter(difficulty: Difficulty.hard),
      );
      expect(hard.items.map((s) => s.id), ['r2']);
      final oldest = await repo.listSets(
        'railway',
        const LibraryFilter(sort: LibrarySort.oldest),
      );
      expect(oldest.items.first.id, 'r1');
      final search = await repo.listSets(
        'railway',
        const LibraryFilter(query: 'je'),
      );
      expect(search.items.map((s) => s.id), ['r2']);

      final facets = await repo.facets('railway');
      expect(
        facets.exams.map((e) => e.id),
        containsAll(['rrb_ntpc', 'rrb_je']),
      );
      expect(facets.exams.any((e) => e.id == 'ibps_po'), isFalse);

      final summary = await repo.summary();
      expect(summary.totalSets, 3);
      expect(summary.countFor('railway').sets, 2);
      expect(summary.countFor('ssc').sets, 0);
    });
  });

  testWidgets(
    'Library tab: category counts, Banking library shows only Banking, delete after confirm',
    (tester) async {
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
      final repo =
          MockLibraryRepository(latency: const Duration(milliseconds: 50))
            ..add(
              _set(
                'r1',
                category: 'railway',
                examId: 'rrb_ntpc',
                examName: 'RRB NTPC',
              ),
            )
            ..add(
              _set(
                'b1',
                category: 'banking',
                examId: 'ibps_po',
                examName: 'IBPS PO',
                stats: const SetStats(
                  attempts: 1,
                  latestScore: 7,
                  latestMaxScore: 10,
                  latestAccuracy: 0.7,
                  latestResultId: 'res_b1',
                ),
              ),
            )
            ..add(
              _set(
                'b2',
                category: 'banking',
                examId: 'ibps_clerk',
                examName: 'IBPS Clerk',
                difficulty: Difficulty.easy,
              ),
            );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            libraryRepositoryProvider.overrideWithValue(repo),
          ],
          child: const ExamGeniusApp(),
        ),
      );
      await tester.pump(const Duration(seconds: 2)); // splash
      await tester.pumpAndSettle();

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('My Learning Library'), findsOneWidget);
      expect(find.text('Recently generated'), findsOneWidget);
      expect(find.text('Banking Library'), findsOneWidget);
      expect(find.textContaining('2 sets'), findsOneWidget); // banking
      expect(find.textContaining('1 set ·'), findsOneWidget); // railway

      await tester.tap(find.text('Banking Library'));
      await tester.pumpAndSettle();
      final cards = tester.widgetList<LibrarySetCard>(
        find.byType(LibrarySetCard, skipOffstage: false),
      );
      expect(cards.map((c) => c.set.category).toSet(), {'banking'});
      expect(find.text('IBPS PO'), findsOneWidget);
      expect(find.text('RRB NTPC'), findsNothing);
      expect(find.text('Not attempted'), findsOneWidget); // b2
      expect(find.textContaining('Latest score: 7/10'), findsOneWidget); // b1

      // Difficulty filter.
      await tester.tap(find.text('Difficulty'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Easy').last);
      await tester.pumpAndSettle();
      expect(find.text('IBPS Clerk'), findsOneWidget);
      expect(find.text('IBPS PO'), findsNothing);

      // Review before any attempt → explained, no answers shown.
      await tester.tap(find.text('Review'));
      await tester.pump();
      expect(find.textContaining('Attempt this set first'), findsOneWidget);
      await tester.pumpAndSettle();

      // Delete only after confirming; removed once the (mock) backend confirms.
      await tester.tap(find.text('Delete').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete this practice?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('IBPS Clerk'), findsNothing);
      expect(find.text('Practice deleted.'), findsOneWidget);
      expect(find.text('No practice sets match these filters'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
