import 'package:flutter/foundation.dart';

import '../../practice_test/domain/practice_models.dart';
import '../../practice_test/domain/practice_result.dart';
import '../../question_generator/domain/generated_question.dart';

/// `{id, name}` pair used for subjects/exams in a set and in filter options.
@immutable
class NamedRef {
  const NamedRef({required this.id, required this.name});

  final String id;
  final String name;

  factory NamedRef.fromJson(Map<String, dynamic> j) =>
      NamedRef(id: j['id'] as String, name: j['name'] as String);

  @override
  bool operator ==(Object other) => other is NamedRef && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// A topic in a set (or a topic filter option), linked to its subject.
@immutable
class TopicRef extends NamedRef {
  const TopicRef({required super.id, required super.name, this.subjectId});

  final String? subjectId;

  factory TopicRef.fromJson(Map<String, dynamic> j) => TopicRef(
    id: j['id'] as String,
    name: j['name'] as String,
    subjectId: j['subjectId'] as String?,
  );
}

/// Attempt summary kept on each set by the backend.
@immutable
class SetStats {
  const SetStats({
    this.attempts = 0,
    this.latestScore,
    this.latestMaxScore,
    this.latestAccuracy,
    this.latestResultId,
    this.bestScore,
    this.lastAttemptAt,
  });

  final int attempts;
  final double? latestScore;
  final double? latestMaxScore;
  final double? latestAccuracy;

  /// Scored result of the latest attempt — opens the answer review.
  final String? latestResultId;
  final double? bestScore;
  final DateTime? lastAttemptAt;

  bool get attempted => attempts > 0;

  factory SetStats.fromJson(Map<String, dynamic> j) {
    double? d(String k) => (j[k] as num?)?.toDouble();
    final last = j['lastAttemptAt'] as String?;
    return SetStats(
      attempts: (j['attempts'] as num?)?.toInt() ?? 0,
      latestScore: d('latestScore'),
      latestMaxScore: d('latestMaxScore'),
      latestAccuracy: d('latestAccuracy'),
      latestResultId: j['latestResultId'] as String?,
      bestScore: d('bestScore'),
      lastAttemptAt: last == null ? null : DateTime.parse(last).toLocal(),
    );
  }
}

/// One saved AI-generated practice set (`GET /library/sets`). The questions
/// stay on the server; answers are only revealed through scored attempts.
@immutable
class LibrarySet {
  const LibrarySet({
    required this.id,
    required this.category,
    required this.examId,
    required this.examName,
    required this.subjects,
    required this.topics,
    required this.difficulty,
    required this.language,
    required this.questionCount,
    required this.createdAt,
    this.stats = const SetStats(),
    this.isPreview = false,
  });

  final String id;

  /// `railway` / `ssc` / `banking` — the Library never mixes categories.
  final String category;
  final String examId;
  final String examName;
  final List<NamedRef> subjects;
  final List<TopicRef> topics;
  final Difficulty difficulty;

  /// `en` / `hi`.
  final String language;
  final int questionCount;
  final DateTime createdAt;
  final SetStats stats;
  final bool isPreview;

  factory LibrarySet.fromJson(Map<String, dynamic> j) => LibrarySet(
    id: j['id'] as String,
    category: j['category'] as String,
    examId: j['examId'] as String,
    examName: j['examName'] as String,
    subjects: [
      for (final s in j['subjects'] as List<dynamic>)
        NamedRef.fromJson(s as Map<String, dynamic>),
    ],
    topics: [
      for (final t in j['topics'] as List<dynamic>)
        TopicRef.fromJson(t as Map<String, dynamic>),
    ],
    difficulty: Difficulty.fromJson(j['difficulty'] as String),
    language: j['language'] as String? ?? 'en',
    questionCount: (j['questionCount'] as num).toInt(),
    createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
    stats: SetStats.fromJson((j['stats'] as Map<String, dynamic>?) ?? const {}),
    isPreview: j['isPreview'] as bool? ?? false,
  );
}

/// Per-category counts on the Library dashboard.
@immutable
class CategoryCount {
  const CategoryCount({
    required this.category,
    required this.sets,
    required this.questions,
    required this.attempted,
  });

  final String category;
  final int sets;
  final int questions;
  final int attempted;

  factory CategoryCount.fromJson(Map<String, dynamic> j) => CategoryCount(
    category: j['category'] as String,
    sets: (j['sets'] as num).toInt(),
    questions: (j['questions'] as num).toInt(),
    attempted: (j['attempted'] as num?)?.toInt() ?? 0,
  );
}

/// `GET /library/summary`.
@immutable
class LibrarySummary {
  const LibrarySummary({
    required this.totalSets,
    required this.totalQuestions,
    required this.bookmarks,
    required this.notes,
    required this.categories,
    required this.recent,
  });

  final int totalSets;
  final int totalQuestions;
  final int bookmarks;
  final int notes;
  final List<CategoryCount> categories;
  final List<LibrarySet> recent;

  CategoryCount countFor(String category) => categories.firstWhere(
    (c) => c.category == category,
    orElse: () =>
        CategoryCount(category: category, sets: 0, questions: 0, attempted: 0),
  );

  factory LibrarySummary.fromJson(Map<String, dynamic> j) => LibrarySummary(
    totalSets: (j['totalSets'] as num).toInt(),
    totalQuestions: (j['totalQuestions'] as num).toInt(),
    bookmarks: (j['bookmarks'] as num?)?.toInt() ?? 0,
    notes: (j['notes'] as num?)?.toInt() ?? 0,
    categories: [
      for (final c in j['categories'] as List<dynamic>)
        CategoryCount.fromJson(c as Map<String, dynamic>),
    ],
    recent: [
      for (final s in j['recent'] as List<dynamic>)
        LibrarySet.fromJson(s as Map<String, dynamic>),
    ],
  );
}

enum LibrarySort { latest, oldest }

/// Filters of one category library. `null` = not filtered.
@immutable
class LibraryFilter {
  const LibraryFilter({
    this.examId,
    this.subjectId,
    this.topicId,
    this.difficulty,
    this.language,
    this.from,
    this.to,
    this.query = '',
    this.sort = LibrarySort.latest,
  });

  final String? examId;
  final String? subjectId;
  final String? topicId;
  final Difficulty? difficulty;
  final String? language;
  final DateTime? from;
  final DateTime? to;
  final String query;
  final LibrarySort sort;

  /// Any filter besides sort is set.
  bool get isActive =>
      examId != null ||
      subjectId != null ||
      topicId != null ||
      difficulty != null ||
      language != null ||
      from != null ||
      to != null ||
      query.trim().isNotEmpty;

  /// Copy with some fields changed; pass `() => null` to clear one.
  LibraryFilter copyWith({
    ValueGetter<String?>? examId,
    ValueGetter<String?>? subjectId,
    ValueGetter<String?>? topicId,
    ValueGetter<Difficulty?>? difficulty,
    ValueGetter<String?>? language,
    ValueGetter<DateTime?>? from,
    ValueGetter<DateTime?>? to,
    String? query,
    LibrarySort? sort,
  }) => LibraryFilter(
    examId: examId == null ? this.examId : examId(),
    subjectId: subjectId == null ? this.subjectId : subjectId(),
    topicId: topicId == null ? this.topicId : topicId(),
    difficulty: difficulty == null ? this.difficulty : difficulty(),
    language: language == null ? this.language : language(),
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    query: query ?? this.query,
    sort: sort ?? this.sort,
  );

  /// Query parameters for `GET /library/sets`.
  Map<String, String> toQuery() => {
    'examId': ?examId,
    'subjectId': ?subjectId,
    'topicId': ?topicId,
    if (difficulty != null) 'difficulty': difficulty!.name,
    'language': ?language,
    if (from != null) 'from': from!.toUtc().toIso8601String(),
    if (to != null) 'to': to!.toUtc().toIso8601String(),
    if (query.trim().isNotEmpty) 'q': query.trim(),
    'sort': sort.name,
  };

  /// Local filter with the same rules as the backend (used by the mock).
  bool matches(LibrarySet s) {
    final q = query.trim().toLowerCase();
    return (examId == null || s.examId == examId) &&
        (subjectId == null || s.subjects.any((x) => x.id == subjectId)) &&
        (topicId == null || s.topics.any((x) => x.id == topicId)) &&
        (difficulty == null || s.difficulty == difficulty) &&
        (language == null || s.language == language) &&
        (from == null || !s.createdAt.isBefore(from!)) &&
        (to == null || !s.createdAt.isAfter(to!)) &&
        (q.isEmpty ||
            s.examName.toLowerCase().contains(q) ||
            s.subjects.any((x) => x.name.toLowerCase().contains(q)) ||
            s.topics.any((x) => x.name.toLowerCase().contains(q)));
  }

  @override
  bool operator ==(Object other) =>
      other is LibraryFilter &&
      other.examId == examId &&
      other.subjectId == subjectId &&
      other.topicId == topicId &&
      other.difficulty == difficulty &&
      other.language == language &&
      other.from == from &&
      other.to == to &&
      other.query == query &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    examId,
    subjectId,
    topicId,
    difficulty,
    language,
    from,
    to,
    query,
    sort,
  );
}

/// One page of `GET /library/sets`.
@immutable
class LibraryPage {
  const LibraryPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<LibrarySet> items;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;

  factory LibraryPage.fromJson(Map<String, dynamic> j) => LibraryPage(
    items: [
      for (final s in j['items'] as List<dynamic>)
        LibrarySet.fromJson(s as Map<String, dynamic>),
    ],
    total: (j['total'] as num).toInt(),
    page: (j['page'] as num).toInt(),
    pageSize: (j['pageSize'] as num).toInt(),
  );
}

/// Exams / subjects / topics present in one category's library — the filter
/// options. Subjects and topics carry the exams they occur in.
@immutable
class LibraryFacets {
  const LibraryFacets({
    this.exams = const [],
    this.subjects = const [],
    this.topics = const [],
  });

  final List<NamedRef> exams;
  final List<({NamedRef subject, Set<String> examIds})> subjects;
  final List<({TopicRef topic, Set<String> examIds})> topics;

  factory LibraryFacets.fromJson(Map<String, dynamic> j) {
    Set<String> ids(Map<String, dynamic> m) =>
        ((m['examIds'] as List<dynamic>?) ?? const []).cast<String>().toSet();
    return LibraryFacets(
      exams: [
        for (final e in j['exams'] as List<dynamic>)
          NamedRef.fromJson(e as Map<String, dynamic>),
      ],
      subjects: [
        for (final s
            in (j['subjects'] as List<dynamic>).cast<Map<String, dynamic>>())
          (subject: NamedRef.fromJson(s), examIds: ids(s)),
      ],
      topics: [
        for (final t
            in (j['topics'] as List<dynamic>).cast<Map<String, dynamic>>())
          (topic: TopicRef.fromJson(t), examIds: ids(t)),
      ],
    );
  }
}

/// My Learning Library backend (`/api/v1/library/*`).
abstract interface class LibraryRepository {
  Future<LibrarySummary> summary();

  /// One page of a category's sets (1-based [page]).
  Future<LibraryPage> listSets(
    String category,
    LibraryFilter filter, {
    int page = 1,
  });

  Future<LibraryFacets> facets(String category);

  /// Completes only after the backend confirmed the delete.
  Future<void> deleteSet(String setId);

  /// Practice Again: a new test with the set's original questions.
  Future<PracticeSession> startSet(String setId);

  /// A scored attempt (answers + explanations) for the review screen.
  Future<PracticeResult> fetchResult(String resultId);

  /// Every scored attempt of a set, newest first.
  Future<List<SetAttempt>> attempts(String setId);
}

/// One attempt in a set's practice history (no questions or answers).
class SetAttempt {
  const SetAttempt({
    required this.id,
    required this.resultId,
    required this.attemptNo,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.completedAt,
  });

  final String id;
  final String resultId;
  final int? attemptNo;
  final double score;
  final double maxScore;
  final double accuracy;
  final DateTime completedAt;

  factory SetAttempt.fromJson(Map<String, dynamic> j) => SetAttempt(
    id: j['id'] as String,
    resultId: j['resultId'] as String,
    attemptNo: (j['attemptNo'] as num?)?.toInt(),
    score: (j['score'] as num? ?? 0).toDouble(),
    maxScore: (j['maxScore'] as num? ?? 0).toDouble(),
    accuracy: (j['accuracy'] as num? ?? 0).toDouble(),
    completedAt:
        DateTime.tryParse(j['completedAt'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
  );
}
