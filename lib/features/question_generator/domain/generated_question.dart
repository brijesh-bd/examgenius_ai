import 'package:flutter/foundation.dart';

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromJson(String value) =>
      Difficulty.values.firstWhere((d) => d.name == value, orElse: () => Difficulty.medium);
}

/// Body of `POST /api/v1/questions/generate`. The backend builds the AI prompt
/// from this (exam pattern + topics + level) — the app never talks to the AI
/// provider directly.
@immutable
class GenerationRequest {
  const GenerationRequest({
    required this.examId,
    required this.examName,
    required this.topicIds,
    required this.difficulty,
    required this.count,
  });

  final String examId;
  final String examName;
  final List<String> topicIds;
  final Difficulty difficulty;
  final int count;

  Map<String, dynamic> toJson() => {
        'examId': examId,
        'examName': examName,
        'topicIds': topicIds,
        'difficulty': difficulty.name,
        'count': count,
        // Asks the backend for questions matching the real exam's standard.
        'level': 'exam',
      };

  @override
  bool operator ==(Object other) =>
      other is GenerationRequest &&
      other.examId == examId &&
      other.difficulty == difficulty &&
      other.count == count &&
      listEquals(other.topicIds, topicIds);

  @override
  int get hashCode => Object.hash(examId, difficulty, count, Object.hashAll(topicIds));
}

@immutable
class GeneratedQuestion {
  const GeneratedQuestion({
    required this.id,
    required this.topicId,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String topicId;
  final Difficulty difficulty;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) => GeneratedQuestion(
        id: json['id'] as String,
        topicId: json['topicId'] as String,
        difficulty: Difficulty.fromJson(json['difficulty'] as String),
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );
}

/// Result of a generation call. [isPreview] is true while questions come from
/// the bundled sample bank instead of the live AI backend.
@immutable
class GeneratedQuestionSet {
  const GeneratedQuestionSet({
    required this.request,
    required this.questions,
    this.isPreview = false,
  });

  final GenerationRequest request;
  final List<GeneratedQuestion> questions;
  final bool isPreview;
}

/// Choices offered for "number of questions".
const kQuestionCountOptions = [5, 10, 20, 30];
