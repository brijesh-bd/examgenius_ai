import 'package:flutter/foundation.dart';

import '../../question_generator/domain/generated_question.dart';

/// Body of `POST /api/v1/practice/:sessionId/submit`.
@immutable
class PracticeSubmission {
  const PracticeSubmission({
    required this.sessionId,
    required this.answers,
    required this.timeTaken,
    required this.autoSubmitted,
  });

  final String sessionId;

  /// questionId → selected option index (unanswered questions are absent).
  final Map<String, int> answers;
  final Duration timeTaken;

  /// True when the timer expired and the app submitted automatically.
  final bool autoSubmitted;

  Map<String, dynamic> toJson() => {
    'answers': answers,
    'timeTakenSeconds': timeTaken.inSeconds,
    'autoSubmitted': autoSubmitted,
  };
}

/// One question after scoring — answer key and explanation are revealed only
/// here, i.e. after submission.
@immutable
class QuestionReview {
  const QuestionReview({
    required this.questionId,
    required this.topicId,
    required this.topicName,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex,
    this.concept,
    this.tip,
    this.formula,
    this.steps = const [],
    this.wrongReason,
  });

  final String questionId;
  final String topicId;
  final String topicName;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final String explanation;
  final String? concept;
  final String? tip;

  /// Key formula (maths), e.g. "Work = Rate × Time".
  final String? formula;

  /// Step-by-step working (maths). Empty for factual subjects.
  final List<String> steps;

  /// Why the student's chosen option is wrong, when the backend provides it.
  final String? wrongReason;

  bool get attempted => selectedIndex != null;
  bool get isCorrect => selectedIndex == correctIndex;

  /// Review status used by the filters.
  ReviewStatus get status => !attempted
      ? ReviewStatus.unattempted
      : (isCorrect ? ReviewStatus.correct : ReviewStatus.incorrect);

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'topicId': topicId,
    'topicName': topicName,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
    'explanation': explanation,
    'concept': concept,
    'tip': tip,
    'formula': formula,
    'steps': steps,
    'wrongReason': wrongReason,
  };

  factory QuestionReview.fromJson(Map<String, dynamic> json) => QuestionReview(
    questionId: json['questionId'] as String,
    topicId: json['topicId'] as String,
    topicName: json['topicName'] as String,
    question: json['question'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    selectedIndex: json['selectedIndex'] as int?,
    explanation: json['explanation'] as String,
    concept: json['concept'] as String?,
    tip: json['tip'] as String?,
    formula: json['formula'] as String?,
    steps: (json['steps'] as List<dynamic>? ?? const []).cast<String>(),
    wrongReason: json['wrongReason'] as String?,
  );
}

/// Per-topic performance computed by the backend.
@immutable
class TopicStat {
  const TopicStat({
    required this.topicId,
    required this.topicName,
    required this.total,
    required this.correct,
  });

  final String topicId;
  final String topicName;
  final int total;
  final int correct;

  double get accuracy => total == 0 ? 0 : correct / total;

  Map<String, dynamic> toJson() => {
    'topicId': topicId,
    'topicName': topicName,
    'total': total,
    'correct': correct,
  };

  factory TopicStat.fromJson(Map<String, dynamic> json) => TopicStat(
    topicId: json['topicId'] as String,
    topicName: json['topicName'] as String,
    total: json['total'] as int,
    correct: json['correct'] as int,
  );
}

/// Scorecard returned by the backend. The app displays it; it never
/// computes scores itself.
@immutable
class PracticeResult {
  const PracticeResult({
    required this.resultId,
    required this.sessionId,
    required this.examName,
    required this.subjects,
    required this.topics,
    required this.difficulty,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.unattempted,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.timeTaken,
    required this.completedAt,
    required this.reviews,
    required this.topicStats,
    this.autoSubmitted = false,
  });

  final String resultId;
  final String sessionId;
  final String examName;
  final List<String> subjects;
  final List<String> topics;
  final Difficulty difficulty;
  final int total;
  final int correct;
  final int incorrect;
  final int unattempted;

  /// Correct × 1 − Incorrect × 0.25 (backend marking scheme).
  final double score;
  final double maxScore;

  /// 0..1 — correct ÷ attempted.
  final double accuracy;
  final Duration timeTaken;
  final DateTime completedAt;
  final List<QuestionReview> reviews;
  final List<TopicStat> topicStats;
  final bool autoSubmitted;

  Duration get averagePerQuestion => total == 0
      ? Duration.zero
      : Duration(seconds: (timeTaken.inSeconds / total).round());

  /// Topic accuracy at or above this is "strong".
  static const strongThreshold = 0.75;

  /// Topic accuracy below this is "weak".
  static const weakThreshold = 0.5;

  /// Topics sorted best → worst (ties keep backend order).
  List<TopicStat> get topicsByAccuracy =>
      [...topicStats]..sort((a, b) => b.accuracy.compareTo(a.accuracy));

  List<TopicStat> get strongTopics =>
      topicsByAccuracy.where((t) => t.accuracy >= strongThreshold).toList();

  List<TopicStat> get weakTopics => topicsByAccuracy.reversed
      .where((t) => t.accuracy < weakThreshold)
      .toList();

  /// Questions answered wrongly (for "Retry Wrong Questions").
  List<QuestionReview> get wrongReviews =>
      reviews.where((r) => r.attempted && !r.isCorrect).toList();

  /// "Congratulations" when the student did well overall.
  bool get isGoodResult => total > 0 && correct / total >= 0.6;

  Map<String, dynamic> toJson() => {
    'resultId': resultId,
    'sessionId': sessionId,
    'examName': examName,
    'subjects': subjects,
    'topics': topics,
    'difficulty': difficulty.name,
    'total': total,
    'correct': correct,
    'incorrect': incorrect,
    'unattempted': unattempted,
    'score': score,
    'maxScore': maxScore,
    'accuracy': accuracy,
    'timeTakenSeconds': timeTaken.inSeconds,
    'completedAt': completedAt.toIso8601String(),
    'autoSubmitted': autoSubmitted,
    'reviews': reviews.map((r) => r.toJson()).toList(),
    'topicStats': topicStats.map((t) => t.toJson()).toList(),
  };

  factory PracticeResult.fromJson(Map<String, dynamic> json) => PracticeResult(
    resultId: json['resultId'] as String,
    sessionId: json['sessionId'] as String,
    examName: json['examName'] as String,
    subjects: (json['subjects'] as List<dynamic>).cast<String>(),
    topics: (json['topics'] as List<dynamic>).cast<String>(),
    difficulty: Difficulty.fromJson(json['difficulty'] as String),
    total: json['total'] as int,
    correct: json['correct'] as int,
    incorrect: json['incorrect'] as int,
    unattempted: json['unattempted'] as int,
    score: (json['score'] as num).toDouble(),
    maxScore: (json['maxScore'] as num).toDouble(),
    accuracy: (json['accuracy'] as num).toDouble(),
    timeTaken: Duration(seconds: json['timeTakenSeconds'] as int),
    completedAt: DateTime.parse(json['completedAt'] as String),
    autoSubmitted: json['autoSubmitted'] as bool? ?? false,
    reviews: (json['reviews'] as List<dynamic>)
        .map((r) => QuestionReview.fromJson(r as Map<String, dynamic>))
        .toList(),
    topicStats: (json['topicStats'] as List<dynamic>)
        .map((t) => TopicStat.fromJson(t as Map<String, dynamic>))
        .toList(),
  );
}

enum ReviewStatus { correct, incorrect, unattempted }

/// Review screen filter.
enum ReviewFilter {
  all,
  correct,
  incorrect,
  unattempted;

  bool matches(QuestionReview r) => switch (this) {
    ReviewFilter.all => true,
    ReviewFilter.correct => r.status == ReviewStatus.correct,
    ReviewFilter.incorrect => r.status == ReviewStatus.incorrect,
    ReviewFilter.unattempted => r.status == ReviewStatus.unattempted,
  };

  /// Reviews matching this filter, keeping their original numbering.
  List<(int, QuestionReview)> apply(List<QuestionReview> reviews) => [
    for (final (i, r) in reviews.indexed)
      if (matches(r)) (i + 1, r),
  ];
}

/// Weakest topics of this exam for targeted practice: accuracy below
/// [threshold] with at least [minAttempts] questions seen, worst first.
List<String> pickWeakTopics(
  List<TopicStat> stats,
  Set<String> examTopicIds, {
  double threshold = 0.6,
  int minAttempts = 2,
  int max = 5,
}) {
  final weak =
      stats
          .where(
            (t) =>
                examTopicIds.contains(t.topicId) &&
                t.total >= minAttempts &&
                t.accuracy < threshold,
          )
          .toList()
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
  return weak.take(max).map((t) => t.topicId).toList();
}
