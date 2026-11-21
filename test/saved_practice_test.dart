import 'package:examgenius_ai/core/services/preferences_service.dart';
import 'package:examgenius_ai/features/practice_test/data/mock_saved_practice_repository.dart';
import 'package:examgenius_ai/features/practice_test/domain/practice_result.dart';
import 'package:examgenius_ai/features/practice_test/domain/saved_practice.dart';
import 'package:examgenius_ai/features/practice_test/presentation/providers/saved_practice_providers.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PracticeResult _result(String id) => PracticeResult(
      resultId: id,
      sessionId: 's_$id',
      examName: 'RRB NTPC',
      subjects: const ['Mathematics'],
      topics: const ['Time & Work'],
      difficulty: Difficulty.hard,
      total: 2,
      correct: 1,
      incorrect: 1,
      unattempted: 0,
      score: 0.75,
      maxScore: 2,
      accuracy: 0.5,
      timeTaken: const Duration(seconds: 90),
      completedAt: DateTime(2026, 11, 21, 19, 40),
      autoSubmitted: true,
      reviews: const [
        QuestionReview(
          questionId: 'q1',
          topicId: 'quant.tw',
          topicName: 'Time & Work',
          question: 'Q?',
          options: ['a', 'b', 'c', 'd'],
          correctIndex: 2,
          selectedIndex: 1,
          explanation: 'Because.',
          formula: 'W = R × T',
          steps: ['One.', 'Two.'],
          concept: 'Rates add.',
          tip: 'Use LCM.',
        ),
      ],
      topicStats: const [TopicStat(topicId: 'quant.tw', topicName: 'Time & Work', total: 2, correct: 1)],
    );

class _FlakyRepo implements SavedPracticeRepository {
  bool fail = true;
  int calls = 0;
  @override
  bool isSaved(String resultId) => false;
  @override
  Future<SavedPractice> save(PracticeResult r) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (fail) throw Exception('offline');
    return SavedPractice(id: 'x', savedAt: DateTime(2026), result: r);
  }

  @override
  Future<List<SavedPractice>> list() async => const [];
  @override
  Future<void> delete(String id) async {}
}

void main() {
  test('full result survives a JSON round trip', () {
    final r = _result('r1');
    final back = SavedPractice.fromJson(
      SavedPractice(id: 'a', savedAt: DateTime(2026, 11, 21), result: r).toJson(),
    ).result;
    expect(back.toJson(), r.toJson());
    expect(back.reviews.single.steps, ['One.', 'Two.']);
    expect(back.reviews.single.selectedIndex, 1);
    expect(back.difficulty, Difficulty.hard);
    expect(back.autoSubmitted, isTrue);
  });

  test('save persists, is idempotent, lists newest first, deletes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = MockSavedPracticeRepository(prefs);

    expect(repo.isSaved('r1'), isFalse);
    final a = await repo.save(_result('r1'));
    final again = await repo.save(_result('r1'));
    expect(again.id, a.id);
    await repo.save(_result('r2'));
    expect(repo.isSaved('r1'), isTrue);

    // A new repository over the same storage still sees them (survives restart).
    final reopened = MockSavedPracticeRepository(prefs);
    final list = await reopened.list();
    expect(list.map((s) => s.result.resultId), ['r2', 'r1']);

    await reopened.delete(a.id);
    expect((await reopened.list()).map((s) => s.result.resultId), ['r2']);
  });

  test('controller saves once; failure is reported and can be retried', () async {
    final repo = _FlakyRepo();
    final c = ProviderContainer(overrides: [savedPracticeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    final p = savePracticeProvider(_result('r1'));
    c.listen(p, (_, _) {});

    expect(await c.read(p.notifier).save(), isFalse);
    expect(c.read(p).error, isNotNull);
    expect(c.read(p).isSaved, isFalse);

    repo.fail = false;
    final first = c.read(p.notifier).save();
    c.read(p.notifier).save(); // double tap while saving: ignored
    expect(await first, isTrue);
    expect(await c.read(p.notifier).save(), isTrue); // already saved: no call
    expect(repo.calls, 2); // one failed + one successful
    expect(c.read(p).isSaved, isTrue);
  });

  test('controller starts as saved when the result was saved before', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await MockSavedPracticeRepository(prefs).save(_result('r9'));
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    final p = savePracticeProvider(_result('r9'));
    c.listen(p, (_, _) {});
    expect(c.read(p).isSaved, isTrue);
  });
}
