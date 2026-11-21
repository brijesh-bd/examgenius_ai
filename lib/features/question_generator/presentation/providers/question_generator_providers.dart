import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../data/api_syllabus_repository.dart';
import '../../data/mock_question_generator_repository.dart';
import '../../data/mock_syllabus_repository.dart';
import '../../domain/generated_question.dart';
import '../../domain/question_generator_repository.dart';
import '../../domain/syllabus.dart';

final syllabusRepositoryProvider = Provider<SyllabusRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) return MockSyllabusRepository();
  return ApiSyllabusRepository(ref.watch(apiClientProvider));
});

final questionGeneratorRepositoryProvider =
    Provider<QuestionGeneratorRepository>(
      (ref) => MockQuestionGeneratorRepository(),
    );

final syllabusProvider = FutureProvider.autoDispose.family<Syllabus, String>(
  (ref, examId) => ref.watch(syllabusRepositoryProvider).fetchSyllabus(examId),
);

/// Topic / difficulty / count chosen on the syllabus screen, per exam.
class GeneratorFormController extends Notifier<GeneratorForm> {
  GeneratorFormController(this.examId);

  final String examId;

  @override
  GeneratorForm build() => const GeneratorForm();

  void toggleTopic(String topicId) {
    final next = {...state.topicIds};
    if (!next.remove(topicId)) next.add(topicId);
    state = state.copyWith(topicIds: next);
  }

  /// Mode-aware pick: multiple → toggle; single → this topic replaces any
  /// other selected topic of the same subject (tap again to clear).
  void selectTopic(String topicId) {
    if (state.multiSelect) return toggleTopic(topicId);
    final subject = subjectIdOf(topicId);
    final wasOn = state.topicIds.contains(topicId);
    final next = {
      for (final id in state.topicIds)
        if (subjectIdOf(id) != subject) id,
      if (!wasOn) topicId,
    };
    state = state.copyWith(topicIds: next);
  }

  /// Switching to single keeps only the first selected topic of each subject.
  void setMultiSelect(bool multi) {
    if (multi == state.multiSelect) return;
    var ids = state.topicIds;
    if (!multi) {
      final seen = <String>{};
      ids = {
        for (final id in state.topicIds)
          if (seen.add(subjectIdOf(id))) id,
      };
    }
    state = state.copyWith(multiSelect: multi, topicIds: ids);
  }

  /// Selects every topic of [subject] (multiple mode only).
  void selectAllIn(SyllabusSubject subject) {
    if (!state.multiSelect) return;
    state = state.copyWith(
      topicIds: {...state.topicIds, ...subject.topics.map((t) => t.id)},
    );
  }

  /// Clears the selection for [subject] only.
  void clearSubject(SyllabusSubject subject) => state = state.copyWith(
    topicIds: {
      for (final id in state.topicIds)
        if (subjectIdOf(id) != subject.id) id,
    },
  );

  void clearTopics() => state = state.copyWith(topicIds: const {});

  void setDifficulty(Difficulty d) => state = state.copyWith(difficulty: d);

  void setCount(int count) => state = state.copyWith(count: count);

  /// Builds the request, or `null` while the form is incomplete.
  GenerationRequest? buildRequest({
    required String examName,
    required Syllabus syllabus,
  }) {
    if (!state.isComplete) return null;
    // Keep syllabus order so identical selections produce equal requests.
    final ordered = [
      for (final s in syllabus.subjects)
        for (final t in s.topics)
          if (state.topicIds.contains(t.id)) t.id,
    ];
    return GenerationRequest(
      examId: examId,
      examName: examName,
      topicIds: ordered,
      difficulty: state.difficulty!,
      count: state.count!,
    );
  }
}

final generatorFormProvider = NotifierProvider.autoDispose
    .family<GeneratorFormController, GeneratorForm, String>(
      GeneratorFormController.new,
    );
