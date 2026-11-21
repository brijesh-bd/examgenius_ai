import '../../question_generator/domain/generated_question.dart';
import '../../question_generator/domain/question_generator_repository.dart';
import '../../question_generator/domain/syllabus.dart';
import '../domain/practice_models.dart';
import '../domain/practice_result.dart';

/// Stand-in for the backend until it is live. Acts like the server: keeps the
/// answer key private and hands the UI questions WITHOUT answers; scores on
/// submit with the standard marking scheme.
class MockPracticeRepository implements PracticeRepository {
  MockPracticeRepository(this._generator, this._syllabus);

  final QuestionGeneratorRepository _generator;
  final SyllabusRepository _syllabus;

  /// "Server-side" data per session. Never exposed before submission.
  final Map<String, _ServerSession> _sessions = {};
  final Map<String, PracticeResult> _results = {};
  int _seq = 0;

  /// Exam-standard pace used for the countdown: 60 s per question.
  static const perQuestion = Duration(seconds: 60);

  /// Marking scheme (backend default).
  static const correctMark = 1.0;
  static const negativeMark = 0.25;

  /// Simulated network time for submission.
  static const submitLatency = Duration(milliseconds: 800);

  @override
  Future<PracticeSession> startSession(GenerationRequest request) async {
    final set = await _generator.generate(request);
    final syllabus = await _syllabus.fetchSyllabus(request.examId);

    final subjectNames = {for (final s in syllabus.subjects) s.id: s.name};
    String topicName(String id) => syllabus.topicName(id) ?? id;

    final session = PracticeSession(
      sessionId: 'mock_${DateTime.now().millisecondsSinceEpoch}_${_seq++}',
      examId: request.examId,
      examName: request.examName,
      subjects: {
        for (final id in request.topicIds)
          subjectNames[subjectIdOf(id)] ?? subjectIdOf(id),
      }.toList(),
      topics: request.topicIds.map(topicName).toList(),
      difficulty: request.difficulty,
      requestedCount: request.count,
      questions: [
        for (final q in set.questions)
          PracticeQuestion(
            id: q.id,
            topicId: q.topicId,
            topicName: topicName(q.topicId),
            text: q.question,
            options: q.options,
          ),
      ],
      timeLimit: set.questions.isEmpty
          ? null
          : perQuestion * set.questions.length,
      isPreview: set.isPreview,
    );
    _sessions[session.sessionId] = _ServerSession(session, set.questions);
    return session;
  }

  @override
  Future<PracticeSession> retrySession(
    PracticeResult result,
    List<String> questionIds,
  ) async {
    await Future<void>.delayed(submitLatency);
    // Rebuilt from the scored result (the backend's stored attempt), so this
    // also works for saved practice after an app restart.
    final ids = questionIds.toSet();
    final picked = [
      for (final r in result.reviews)
        if (ids.contains(r.questionId))
          GeneratedQuestion(
            id: r.questionId,
            topicId: r.topicId,
            difficulty: result.difficulty,
            question: r.question,
            options: r.options,
            correctIndex: r.correctIndex,
            explanation: r.explanation,
          ),
    ];
    final names = {for (final r in result.reviews) r.questionId: r.topicName};
    final original = _sessions[result.sessionId]?.session;
    final session = PracticeSession(
      sessionId:
          'mock_retry_${DateTime.now().millisecondsSinceEpoch}_${_seq++}',
      examId: original?.examId ?? '',
      examName: result.examName,
      subjects: result.subjects,
      topics: result.topics,
      difficulty: result.difficulty,
      requestedCount: picked.length,
      questions: [
        for (final q in picked)
          PracticeQuestion(
            id: q.id,
            topicId: q.topicId,
            topicName: names[q.id] ?? q.topicId,
            text: q.question,
            options: q.options,
          ),
      ],
      timeLimit: picked.isEmpty ? null : perQuestion * picked.length,
      isPreview: original?.isPreview ?? true,
    );
    _sessions[session.sessionId] = _ServerSession(session, picked);
    return session;
  }

  @override
  Future<PracticeResult> submit(PracticeSubmission submission) async {
    await Future<void>.delayed(submitLatency);
    // Idempotent: a repeated submit returns the first result.
    final existing = _results[submission.sessionId];
    if (existing != null) return existing;

    final server = _sessions[submission.sessionId];
    if (server == null) {
      throw StateError('Unknown session ${submission.sessionId}');
    }
    final result = scoreSubmission(
      server.session,
      server.questions,
      submission,
    );
    _results[submission.sessionId] = result;
    return result;
  }

  @override
  Future<List<TopicStat>> topicStats() async {
    final totals = <String, TopicStat>{};
    for (final r in _results.values) {
      for (final t in r.topicStats) {
        final prev = totals[t.topicId];
        totals[t.topicId] = TopicStat(
          topicId: t.topicId,
          topicName: t.topicName,
          total: (prev?.total ?? 0) + t.total,
          correct: (prev?.correct ?? 0) + t.correct,
        );
      }
    }
    return totals.values.toList();
  }
}

class _ServerSession {
  const _ServerSession(this.session, this.questions);
  final PracticeSession session;
  final List<GeneratedQuestion> questions;
}

/// Backend scoring, mirrored for the mock (unit tested). Ignores answers for
/// unknown question ids or out-of-range options.
PracticeResult scoreSubmission(
  PracticeSession session,
  List<GeneratedQuestion> questions,
  PracticeSubmission submission,
) {
  final names = {for (final q in session.questions) q.id: q.topicName};
  var correct = 0, incorrect = 0;
  final reviews = <QuestionReview>[];
  final topicTotals = <String, int>{};
  final topicCorrect = <String, int>{};
  final topicNames = <String, String>{};

  for (final q in questions) {
    var picked = submission.answers[q.id];
    if (picked != null && (picked < 0 || picked >= q.options.length)) {
      picked = null;
    }
    final ok = picked == q.correctIndex;
    if (picked != null) ok ? correct++ : incorrect++;
    topicTotals[q.topicId] = (topicTotals[q.topicId] ?? 0) + 1;
    if (ok) topicCorrect[q.topicId] = (topicCorrect[q.topicId] ?? 0) + 1;
    topicNames[q.topicId] = names[q.id] ?? q.topicId;
    reviews.add(
      QuestionReview(
        questionId: q.id,
        topicId: q.topicId,
        topicName: topicNames[q.topicId]!,
        question: q.question,
        options: q.options,
        correctIndex: q.correctIndex,
        selectedIndex: picked,
        explanation: q.explanation,
        steps: mockSteps(q),
      ),
    );
  }

  final total = questions.length;
  final attempted = correct + incorrect;
  return PracticeResult(
    resultId: 'res_${submission.sessionId}',
    sessionId: submission.sessionId,
    examName: session.examName,
    subjects: session.subjects,
    topics: session.topics,
    difficulty: session.difficulty,
    total: total,
    correct: correct,
    incorrect: incorrect,
    unattempted: total - attempted,
    score:
        correct * MockPracticeRepository.correctMark -
        incorrect * MockPracticeRepository.negativeMark,
    maxScore: total * MockPracticeRepository.correctMark,
    accuracy: attempted == 0 ? 0 : correct / attempted,
    timeTaken: submission.timeTaken,
    completedAt: DateTime.now(),
    autoSubmitted: submission.autoSubmitted,
    reviews: reviews,
    topicStats: [
      for (final id in topicTotals.keys)
        TopicStat(
          topicId: id,
          topicName: topicNames[id]!,
          total: topicTotals[id]!,
          correct: topicCorrect[id] ?? 0,
        ),
    ],
  );
}

/// Subjects whose explanations are shown as step-by-step working.
const _mathSubjects = {'quant', 'math', 'maths', 'arithmetic'};

/// Mock-only: splits a maths explanation into steps ("A. B. C." → 3 steps).
/// The live backend returns `steps` (and `formula`) from the AI directly.
List<String> mockSteps(GeneratedQuestion q) {
  if (!_mathSubjects.contains(subjectIdOf(q.topicId))) return const [];
  final parts = q.explanation
      .split(RegExp(r'(?<=[.;])\s+(?=[A-Z0-9])'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return parts.length < 2 ? const [] : parts;
}
