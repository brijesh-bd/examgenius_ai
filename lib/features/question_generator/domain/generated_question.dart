import 'package:flutter/foundation.dart';

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromJson(String value) => Difficulty.values.firstWhere(
    (d) => d.name == value,
    orElse: () => Difficulty.medium,
  );
}

/// Where a practice set's questions come from.
/// bank: stored questions only (never AI). ai: a fresh AI-generated set
/// (counts as one AI set; not previous-year questions).
enum QuestionSource {
  bank,
  ai;

  static QuestionSource fromJson(String? v) =>
      v == 'ai' ? QuestionSource.ai : QuestionSource.bank;
}

/// quick: mixed set across the exam's subjects (no topics picked).
/// topics: the student's chosen subjects/topics.
enum PracticeMode {
  quick,
  topics;

  static PracticeMode fromJson(String? v) =>
      v == 'quick' ? PracticeMode.quick : PracticeMode.topics;
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
    this.source = QuestionSource.bank,
    this.mode = PracticeMode.topics,
    this.subjectId,
    this.selectedNodeIds = const [],
  });

  final String examId;
  final String examName;

  /// Railway Mathematics: exact syllabus node ids (parents are expanded to
  /// their concepts on the server). Empty for topic-level practice.
  final String? subjectId;
  final List<String> selectedNodeIds;

  /// Empty in [PracticeMode.quick] (the server picks across subjects).
  final List<String> topicIds;
  final Difficulty difficulty;
  final int count;
  final QuestionSource source;
  final PracticeMode mode;

  GenerationRequest copyWith({
    List<String>? topicIds,
    int? count,
    QuestionSource? source,
  }) => GenerationRequest(
    examId: examId,
    examName: examName,
    topicIds: topicIds ?? this.topicIds,
    difficulty: difficulty,
    count: count ?? this.count,
    source: source ?? this.source,
    mode: mode,
    subjectId: subjectId,
    selectedNodeIds: selectedNodeIds,
  );

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'examName': examName,
    'mode': mode.name,
    'topicIds': topicIds,
    if (subjectId != null) 'subjectId': subjectId,
    if (selectedNodeIds.isNotEmpty) 'selectedNodeIds': selectedNodeIds,
    'difficulty': difficulty.name,
    'count': count,
    'source': source.name,
    // Asks the backend for questions matching the real exam's standard.
    'level': 'exam',
  };

  @override
  bool operator ==(Object other) =>
      other is GenerationRequest &&
      other.examId == examId &&
      other.difficulty == difficulty &&
      other.count == count &&
      other.source == source &&
      other.mode == mode &&
      listEquals(other.topicIds, topicIds) &&
      listEquals(other.selectedNodeIds, selectedNodeIds);

  @override
  int get hashCode => Object.hash(
    examId,
    difficulty,
    count,
    source,
    mode,
    Object.hashAll(topicIds),
    Object.hashAll(selectedNodeIds),
  );
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

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) =>
      GeneratedQuestion(
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

/// Choices offered for "number of questions" (plan limits come from the server).
const kQuestionCountOptions = [5, 10, 20, 30, 40];
