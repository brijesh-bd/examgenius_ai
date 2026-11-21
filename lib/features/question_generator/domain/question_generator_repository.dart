import 'generated_question.dart';
import 'syllabus.dart';

abstract interface class SyllabusRepository {
  Future<Syllabus> fetchSyllabus(String examId);
}

abstract interface class QuestionGeneratorRepository {
  Future<GeneratedQuestionSet> generate(GenerationRequest request);
}

/// Form state for the generator: every field must be filled before generating.
class GeneratorForm {
  const GeneratorForm({
    this.topicIds = const {},
    this.difficulty,
    this.count,
    this.multiSelect = true,
  });

  final Set<String> topicIds;
  final Difficulty? difficulty;
  final int? count;

  /// Topic picking mode: true = many topics per subject, false = one per subject.
  final bool multiSelect;

  bool get isComplete => topicIds.isNotEmpty && difficulty != null && count != null;

  GeneratorForm copyWith({
    Set<String>? topicIds,
    Difficulty? difficulty,
    int? count,
    bool? multiSelect,
  }) =>
      GeneratorForm(
        topicIds: topicIds ?? this.topicIds,
        difficulty: difficulty ?? this.difficulty,
        count: count ?? this.count,
        multiSelect: multiSelect ?? this.multiSelect,
      );
}
