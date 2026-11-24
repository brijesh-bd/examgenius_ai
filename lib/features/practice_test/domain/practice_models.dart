import 'package:flutter/foundation.dart';

import '../../question_generator/domain/generated_question.dart';
import 'practice_result.dart';

/// A question as the student sees it during a test.
///
/// Deliberately has NO correct answer or explanation: the backend keeps the
/// answer key and only reveals it after submission
/// (`POST /api/v1/practice/:sessionId/submit`).
@immutable
class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.topicId,
    required this.topicName,
    required this.text,
    required this.options,
  });

  final String id;
  final String topicId;
  final String topicName;
  final String text;
  final List<String> options;

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) =>
      PracticeQuestion(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        topicName: json['topicName'] as String,
        text: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
      );
}

/// A generated test, returned by `POST /api/v1/questions/generate`.
@immutable
class PracticeSession {
  const PracticeSession({
    required this.sessionId,
    required this.examId,
    required this.examName,
    required this.subjects,
    required this.topics,
    required this.difficulty,
    required this.questions,
    required this.requestedCount,
    this.timeLimit,
    this.isPreview = false,
    this.setId,
    this.questionSource,
  });

  /// Where the questions came from (null for retries / older sets).
  final QuestionSource? questionSource;

  final String sessionId;

  /// Library set this test belongs to (`null` for partial retries).
  final String? setId;
  final String examId;
  final String examName;
  final List<String> subjects;
  final List<String> topics;
  final Difficulty difficulty;
  final List<PracticeQuestion> questions;
  final int requestedCount;

  /// `null` = untimed test.
  final Duration? timeLimit;

  /// True while questions come from the bundled sample bank (no live AI).
  final bool isPreview;

  factory PracticeSession.fromJson(Map<String, dynamic> json) =>
      PracticeSession(
        sessionId: json['sessionId'] as String,
        setId: json['setId'] as String?,
        examId: json['examId'] as String,
        examName: json['examName'] as String,
        subjects: (json['subjects'] as List<dynamic>).cast<String>(),
        topics: (json['topics'] as List<dynamic>).cast<String>(),
        difficulty: Difficulty.fromJson(json['difficulty'] as String),
        questions: (json['questions'] as List<dynamic>)
            .map((q) => PracticeQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        requestedCount: json['requestedCount'] as int,
        timeLimit: json['timeLimitSeconds'] == null
            ? null
            : Duration(seconds: json['timeLimitSeconds'] as int),
        isPreview: json['isPreview'] as bool? ?? false,
        questionSource: json['questionSource'] == null
            ? null
            : QuestionSource.fromJson(json['questionSource'] as String),
      );
}

/// Contract the practice screens depend on. Scoring happens on the backend.
abstract interface class PracticeRepository {
  /// Generates questions for [request] and opens a test session.
  Future<PracticeSession> startSession(GenerationRequest request);

  /// Sends answers for scoring. The backend validates and scores; it must be
  /// idempotent per session so a repeated call returns the same result.
  Future<PracticeResult> submit(PracticeSubmission submission);

  /// Opens a new session with only [questionIds] from an earlier result
  /// (e.g. "Retry Wrong Questions"). The original attempt is left unchanged.
  Future<PracticeSession> retrySession(
    PracticeResult result,
    List<String> questionIds,
  );

  /// Per-topic totals across all of the student's results (`GET /practice/topic-stats`).
  Future<List<TopicStat>> topicStats();
}

/// Where a test's questions come from.
@immutable
sealed class SessionSource {
  const SessionSource();
}

/// Fresh AI generation from the syllabus screen.
final class GenerateSource extends SessionSource {
  const GenerateSource(this.request);
  final GenerationRequest request;

  @override
  bool operator ==(Object other) =>
      other is GenerateSource && other.request == request;
  @override
  int get hashCode => request.hashCode;
}

/// Practice Again on a My Learning Library set: same questions, new attempt.
final class LibrarySetSource extends SessionSource {
  const LibrarySetSource(this.setId, {this.examName = ''});
  final String setId;

  /// For the test screen title only (not part of equality).
  final String examName;

  @override
  bool operator ==(Object other) =>
      other is LibrarySetSource && other.setId == setId;
  @override
  int get hashCode => setId.hashCode;
}

/// Re-attempt of selected questions from an earlier result.
final class RetrySource extends SessionSource {
  const RetrySource(this.result, this.questionIds);
  final PracticeResult result;
  final List<String> questionIds;

  @override
  bool operator ==(Object other) =>
      other is RetrySource &&
      other.result.resultId == result.resultId &&
      listEquals(other.questionIds, questionIds);
  @override
  int get hashCode => Object.hash(result.resultId, Object.hashAll(questionIds));
}
