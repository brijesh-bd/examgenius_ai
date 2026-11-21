import 'generated_question.dart';
import 'syllabus.dart';

abstract interface class SyllabusRepository {
  Future<Syllabus> fetchSyllabus(String examId);
}

abstract interface class QuestionGeneratorRepository {
  Future<GeneratedQuestionSet> generate(GenerationRequest request);
}

/// Default level / size so a student only has to pick topics.
const kDefaultDifficulty = Difficulty.medium;
const kDefaultQuestionCount = 10;

/// Create Practice form. Level and count start with sensible defaults, so the
/// form is complete as soon as at least one topic is picked.
class GeneratorForm {
  const GeneratorForm({
    this.topicIds = const {},
    this.difficulty = kDefaultDifficulty,
    this.count = kDefaultQuestionCount,
    this.fresh = false,
    this.activeSubjectId,
  });

  final Set<String> topicIds;
  final Difficulty difficulty;
  final int count;

  /// Pro: request brand-new AI questions instead of the question bank.
  final bool fresh;

  /// Subject whose topics are shown (null = first subject).
  final String? activeSubjectId;

  bool get isComplete => topicIds.isNotEmpty;

  GeneratorForm copyWith({
    Set<String>? topicIds,
    Difficulty? difficulty,
    int? count,
    bool? fresh,
    String? activeSubjectId,
  }) => GeneratorForm(
    topicIds: topicIds ?? this.topicIds,
    difficulty: difficulty ?? this.difficulty,
    count: count ?? this.count,
    fresh: fresh ?? this.fresh,
    activeSubjectId: activeSubjectId ?? this.activeSubjectId,
  );
}
