import 'package:examgenius_ai/features/practice_test/data/mock_practice_repository.dart';
import 'package:examgenius_ai/features/practice_test/domain/practice_models.dart';
import 'package:examgenius_ai/features/practice_test/domain/practice_result.dart';
import 'package:examgenius_ai/features/practice_test/presentation/providers/practice_providers.dart';
import 'package:examgenius_ai/features/practice_test/presentation/widgets/test_timer_chip.dart';
import 'package:examgenius_ai/features/practice_test/presentation/widgets/result_charts.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_question_generator_repository.dart';
import 'package:examgenius_ai/features/question_generator/data/mock_syllabus_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

PracticeSession _session({Duration? limit, int n = 3}) => PracticeSession(
      sessionId: 's1',
      examId: 'rrb_ntpc',
      examName: 'RRB NTPC',
      subjects: const ['Mathematics'],
      topics: const ['Time & Work'],
      difficulty: Difficulty.medium,
      requestedCount: n,
      timeLimit: limit,
      questions: [
        for (var i = 0; i < n; i++)
          PracticeQuestion(
            id: 'q$i',
            topicId: 'math.t',
            topicName: 'Time & Work',
            text: 'Question $i',
            options: const ['a', 'b', 'c', 'd'],
          ),
      ],
    );

void main() {
  scoringTests();
  resultHelpersTests();
  reviewTests();
  test('mock session hides answers and resolves names + timer', () async {
    final repo = MockPracticeRepository(
      MockQuestionGeneratorRepository(),
      MockSyllabusRepository(),
    );
    final s = await repo.startSession(const GenerationRequest(
      examId: 'rrb_ntpc',
      examName: 'RRB NTPC',
      topicIds: ['quant.time_work'],
      difficulty: Difficulty.medium,
      count: 5,
    ));
    expect(s.questions, isNotEmpty);
    expect(s.subjects, contains('Mathematics'));
    expect(s.topics, contains('Time & Work'));
    expect(s.timeLimit, MockPracticeRepository.perQuestion * s.questions.length);
    // PracticeQuestion has no answer fields at all — nothing to leak.
  });

  test('select, change, clear, navigate and submit gating', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final session = _session();
    final p = practiceTestProvider(session);
    c.listen(p, (_, _) {});
    final ctl = c.read(p.notifier);

    expect(c.read(p).allAnswered, isFalse);
    ctl.select(1);
    ctl.select(2); // change answer
    expect(c.read(p).answers, {'q0': 2});
    ctl.clear();
    expect(c.read(p).answers, isEmpty);

    ctl.select(0);
    ctl.next();
    ctl.select(1);
    ctl.next();
    ctl.next(); // stays on last
    expect(c.read(p).current, 2);
    ctl.select(3);
    expect(c.read(p).allAnswered, isTrue);

    ctl.previous();
    expect(c.read(p).selected, 1); // preserved
    ctl.goTo(99);
    expect(c.read(p).current, 1);
  });

  test('countdown ticks and flags time up, then locks answers', () {
    fakeAsync((async) {
      final c = ProviderContainer();
      final session = _session(limit: const Duration(seconds: 3));
      final p = practiceTestProvider(session);
      c.listen(p, (_, _) {});
      expect(c.read(p).remaining, const Duration(seconds: 3));
      async.elapse(const Duration(seconds: 1));
      expect(c.read(p).remaining, const Duration(seconds: 2));
      async.elapse(const Duration(seconds: 2));
      expect(c.read(p).timeUp, isTrue);
      expect(c.read(p).remaining, Duration.zero);
      c.read(p.notifier).select(0);
      expect(c.read(p).answers, isEmpty); // locked after time up
      c.dispose();
    });
  });

  test('formatCountdown', () {
    expect(formatCountdown(const Duration(seconds: 65)), '01:05');
    expect(formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
  });
}

class _CountingRepo implements PracticeRepository {
  _CountingRepo({this.fail = false});
  bool fail;
  int submits = 0;
  PracticeSubmission? last;

  @override
  Future<PracticeSession> startSession(GenerationRequest request) => throw UnimplementedError();

  @override
  Future<PracticeSession> retrySession(PracticeResult r, List<String> ids) =>
      throw UnimplementedError();

  @override
  Future<PracticeResult> submit(PracticeSubmission s) async {
    submits++;
    last = s;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (fail) throw Exception('network');
    return scoreSubmission(_session(), const [], s);
  }
}

void scoringTests() {
  GeneratedQuestion q(String id, int correct) => GeneratedQuestion(
        id: id,
        topicId: 'math.t',
        difficulty: Difficulty.medium,
        question: id,
        options: const ['a', 'b', 'c', 'd'],
        correctIndex: correct,
        explanation: 'because',
      );

  test('scoring: +1 correct, −0.25 incorrect, 0 unattempted; accuracy over attempted', () {
    final bank = [q('q0', 0), q('q1', 1), q('q2', 2), q('q3', 3)];
    final r = scoreSubmission(
      _session(n: 4),
      bank,
      const PracticeSubmission(
        sessionId: 's1',
        answers: {'q0': 0, 'q1': 1, 'q2': 0, 'q9': 1}, // q3 skipped, q9 unknown
        timeTaken: Duration(seconds: 120),
        autoSubmitted: false,
      ),
    );
    expect(r.correct, 2);
    expect(r.incorrect, 1);
    expect(r.unattempted, 1);
    expect(r.score, 1.75);
    expect(r.maxScore, 4);
    expect(r.accuracy, closeTo(2 / 3, 1e-9));
    expect(r.averagePerQuestion, const Duration(seconds: 30));
    expect(r.reviews.map((e) => e.selectedIndex), [0, 1, 0, null]);
    expect(r.topicStats.single.correct, 2);
  });

  test('submit sends once even when tapped repeatedly; answers lock', () async {
    final repo = _CountingRepo();
    final c = ProviderContainer(overrides: [practiceRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    final p = practiceTestProvider(_session());
    c.listen(p, (_, _) {});
    final ctl = c.read(p.notifier);
    ctl.select(1);

    final first = ctl.submit();
    ctl.submit();
    ctl.select(2); // ignored while submitting
    await first;
    await ctl.submit(); // ignored after success
    expect(repo.submits, 1);
    expect(repo.last!.answers, {'q0': 1});
    expect(c.read(p).result, isNotNull);
    expect(c.read(p).locked, isTrue);
  });

  test('failed submit exposes the error and allows retry', () async {
    final repo = _CountingRepo(fail: true);
    final c = ProviderContainer(overrides: [practiceRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    final p = practiceTestProvider(_session());
    c.listen(p, (_, _) {});
    await c.read(p.notifier).submit();
    expect(c.read(p).submitError, isNotNull);
    expect(c.read(p).submitting, isFalse);
    repo.fail = false;
    await c.read(p.notifier).submit();
    expect(c.read(p).submitError, isNull);
    expect(c.read(p).result, isNotNull);
    expect(repo.submits, 2);
  });

  test('mock repository is idempotent per session', () async {
    final repo = MockPracticeRepository(MockQuestionGeneratorRepository(), MockSyllabusRepository());
    final s = await repo.startSession(const GenerationRequest(
      examId: 'rrb_ntpc',
      examName: 'RRB NTPC',
      topicIds: ['quant.time_work'],
      difficulty: Difficulty.medium,
      count: 5,
    ));
    final sub = PracticeSubmission(
      sessionId: s.sessionId,
      answers: const {},
      timeTaken: const Duration(seconds: 10),
      autoSubmitted: true,
    );
    final a = await repo.submit(sub);
    final b = await repo.submit(sub);
    expect(identical(a, b), isTrue);
    expect(a.unattempted, s.questions.length);
    expect(a.score, 0);
    expect(a.autoSubmitted, isTrue);
  });
}

void resultHelpersTests() {
  PracticeResult result(List<TopicStat> stats, {int correct = 6, int total = 10}) => PracticeResult(
        resultId: 'r',
        sessionId: 's',
        examName: 'RRB NTPC',
        subjects: const ['Mathematics'],
        topics: const [],
        difficulty: Difficulty.medium,
        total: total,
        correct: correct,
        incorrect: 2,
        unattempted: total - correct - 2,
        score: correct - 0.5,
        maxScore: total.toDouble(),
        accuracy: correct / (correct + 2),
        timeTaken: const Duration(minutes: 5),
        completedAt: DateTime(2026, 11, 21),
        reviews: const [],
        topicStats: stats,
      );

  test('strong / weak topics and ordering', () {
    const a = TopicStat(topicId: 'a', topicName: 'A', total: 4, correct: 4); // 100%
    const b = TopicStat(topicId: 'b', topicName: 'B', total: 4, correct: 1); // 25%
    const c = TopicStat(topicId: 'c', topicName: 'C', total: 4, correct: 2); // 50%
    final r = result([a, b, c]);
    expect(r.topicsByAccuracy.map((t) => t.topicId), ['a', 'c', 'b']);
    expect(r.strongTopics.map((t) => t.topicId), ['a']);
    expect(r.weakTopics.map((t) => t.topicId), ['b']); // 50% is not weak
    expect(r.isGoodResult, isTrue);
    expect(result(const [], correct: 5).isGoodResult, isFalse);
    expect(r.averagePerQuestion, const Duration(seconds: 30));
  });

  test('score and percent formatting', () {
    expect(scoreText(8), '8');
    expect(scoreText(7.75), '7.75');
    expect(scoreText(7.5), '7.5');
    expect(scoreText(-0.25), '-0.25');
    expect(percentText(2 / 3), '67%');
  });
}

void reviewTests() {
  QuestionReview rev(String id, int? selected) => QuestionReview(
        questionId: id,
        topicId: 'quant.t',
        topicName: 'T',
        question: id,
        options: const ['a', 'b', 'c', 'd'],
        correctIndex: 0,
        selectedIndex: selected,
        explanation: 'x',
      );

  test('review filters keep original question numbers', () {
    final reviews = [rev('q1', 0), rev('q2', 1), rev('q3', null), rev('q4', 2)];
    expect(ReviewFilter.all.apply(reviews).map((e) => e.$1), [1, 2, 3, 4]);
    expect(ReviewFilter.correct.apply(reviews).map((e) => e.$1), [1]);
    expect(ReviewFilter.incorrect.apply(reviews).map((e) => e.$1), [2, 4]);
    expect(ReviewFilter.unattempted.apply(reviews).map((e) => e.$1), [3]);
  });

  test('mock maths steps split sentences; non-maths stays a paragraph', () {
    GeneratedQuestion g(String topic, String exp) => GeneratedQuestion(
          id: 'g',
          topicId: topic,
          difficulty: Difficulty.easy,
          question: 'q',
          options: const ['a', 'b'],
          correctIndex: 0,
          explanation: exp,
        );
    expect(mockSteps(g('quant.pct', 'Number = 45 ÷ 0.20 = 225. 35% of 225 = 78.75.')),
        ['Number = 45 ÷ 0.20 = 225.', '35% of 225 = 78.75.']);
    expect(mockSteps(g('gk.history', 'Fact one. Fact two.')), isEmpty);
    expect(mockSteps(g('quant.pct', 'Single step.')), isEmpty);
  });

  test('retry opens a new session with only the chosen questions', () async {
    final repo = MockPracticeRepository(MockQuestionGeneratorRepository(), MockSyllabusRepository());
    final s = await repo.startSession(const GenerationRequest(
      examId: 'rrb_ntpc',
      examName: 'RRB NTPC',
      topicIds: ['quant.time_work'],
      difficulty: Difficulty.medium,
      count: 5,
    ));
    final wrong = {for (final q in s.questions) q.id: 3}; // option D for all
    final result = await repo.submit(PracticeSubmission(
      sessionId: s.sessionId,
      answers: wrong,
      timeTaken: const Duration(seconds: 30),
      autoSubmitted: false,
    ));
    final ids = result.wrongReviews.map((w) => w.questionId).toList();
    expect(ids, isNotEmpty);
    final retry = await repo.retrySession(result, ids);
    expect(retry.sessionId, isNot(s.sessionId));
    expect(retry.questions.map((q) => q.id), ids);
    // The retry can be submitted and scored on its own; original unchanged.
    final r2 = await repo.submit(PracticeSubmission(
      sessionId: retry.sessionId,
      answers: const {},
      timeTaken: const Duration(seconds: 5),
      autoSubmitted: false,
    ));
    expect(r2.total, ids.length);
    expect(identical(await repo.submit(PracticeSubmission(
      sessionId: s.sessionId, answers: wrong,
      timeTaken: const Duration(seconds: 30), autoSubmitted: false)), result), isTrue);
  });

  test('session sources compare by value', () {
    const req = GenerationRequest(
        examId: 'e', examName: 'E', topicIds: ['a'], difficulty: Difficulty.easy, count: 5);
    expect(const GenerateSource(req), const GenerateSource(req));
  });
}
