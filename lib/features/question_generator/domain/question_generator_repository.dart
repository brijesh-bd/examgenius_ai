import 'generated_question.dart';
import 'syllabus.dart';

abstract interface class SyllabusRepository {
  Future<Syllabus> fetchSyllabus(String examId);
}

abstract interface class QuestionGeneratorRepository {
  Future<GeneratedQuestionSet> generate(GenerationRequest request);
}

/// Saved practice configuration ("Last Practice"), stored on the account.
/// Not an attempt — attempts live in practice sessions.
class LastPracticeConfig {
  const LastPracticeConfig({
    required this.examId,
    required this.mode,
    required this.topicIds,
    required this.difficulty,
    required this.count,
    required this.source,
    this.subjectIds = const [],
    this.language,
  });

  final String examId;
  final PracticeMode mode;
  final List<String> subjectIds;
  final List<String> topicIds;
  final Difficulty difficulty;
  final int count;
  final String? language;
  final QuestionSource source;

  factory LastPracticeConfig.fromJson(Map<String, dynamic> j) =>
      LastPracticeConfig(
        examId: j['examId'] as String,
        mode: PracticeMode.fromJson(j['mode'] as String?),
        subjectIds: (j['subjectIds'] as List<dynamic>? ?? const [])
            .cast<String>(),
        topicIds: (j['topicIds'] as List<dynamic>? ?? const []).cast<String>(),
        difficulty: Difficulty.fromJson(j['difficulty'] as String? ?? 'medium'),
        count: (j['count'] as num? ?? 10).toInt(),
        language: j['language'] as String?,
        source: QuestionSource.fromJson(j['source'] as String?),
      );

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'mode': mode.name,
    'subjectIds': subjectIds,
    'topicIds': topicIds,
    'difficulty': difficulty.name,
    'count': count,
    'language': language,
    'source': source.name,
  };

  factory LastPracticeConfig.fromRequest(
    GenerationRequest r, {
    String? language,
  }) => LastPracticeConfig(
    examId: r.examId,
    mode: r.mode,
    subjectIds: {for (final id in r.topicIds) subjectIdOf(id)}.toList(),
    topicIds: r.topicIds,
    difficulty: r.difficulty,
    count: r.count,
    language: language,
    source: r.source,
  );
}

/// Practice setup reads: bank availability and the saved Last Practice.
abstract interface class PracticeSetupRepository {
  /// Stored questions that match (`GET /questions/bank/availability`).
  Future<int> bankAvailability({
    required String examId,
    required PracticeMode mode,
    required List<String> topicIds,
    required Difficulty difficulty,
    required String language,
  });

  /// `GET /practice/last-config?examId=` (null when none yet).
  Future<LastPracticeConfig?> lastConfig(String examId);
}

/// Default level / size so a student only has to pick topics.
const kDefaultDifficulty = Difficulty.medium;
const kDefaultQuestionCount = 10;

/// Create Practice form. Level, count (10) and source (Question Bank) start
/// with defaults, so Quick Practice is ready at once and Topic-wise is ready
/// as soon as one topic is picked.
class GeneratorForm {
  const GeneratorForm({
    this.mode = PracticeMode.topics,
    this.topicIds = const {},
    this.difficulty = kDefaultDifficulty,
    this.count = kDefaultQuestionCount,
    this.source = QuestionSource.bank,
    this.activeSubjectId,
  });

  final PracticeMode mode;
  final Set<String> topicIds;
  final Difficulty difficulty;
  final int count;
  final QuestionSource source;

  /// Subject whose topics are shown (null = first subject).
  final String? activeSubjectId;

  bool get isComplete => mode == PracticeMode.quick || topicIds.isNotEmpty;

  GeneratorForm copyWith({
    PracticeMode? mode,
    Set<String>? topicIds,
    Difficulty? difficulty,
    int? count,
    QuestionSource? source,
    String? activeSubjectId,
  }) => GeneratorForm(
    mode: mode ?? this.mode,
    topicIds: topicIds ?? this.topicIds,
    difficulty: difficulty ?? this.difficulty,
    count: count ?? this.count,
    source: source ?? this.source,
    activeSubjectId: activeSubjectId ?? this.activeSubjectId,
  );
}
