import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/services/preferences_service.dart';
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

  /// Shows [subjectId]'s topics (selection in other subjects is kept).
  void setActiveSubject(String subjectId) =>
      state = state.copyWith(activeSubjectId: subjectId);

  /// Selects every topic of [subject].
  void selectAllIn(SyllabusSubject subject) {
    state = state.copyWith(
      topicIds: {...state.topicIds, ...subject.topics.map((t) => t.id)},
    );
  }

  /// Fills the whole form at once (quick-start shortcuts).
  void applyPreset({
    required Set<String> topicIds,
    Difficulty? difficulty,
    int? count,
  }) {
    state = GeneratorForm(
      topicIds: topicIds,
      difficulty: difficulty ?? state.difficulty,
      count: count ?? state.count,
      fresh: state.fresh,
      activeSubjectId: topicIds.isEmpty
          ? state.activeSubjectId
          : subjectIdOf(topicIds.first),
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

  void setFresh(bool fresh) => state = state.copyWith(fresh: fresh);

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
      difficulty: state.difficulty,
      count: state.count,
      fresh: state.fresh,
    );
  }
}

final generatorFormProvider = NotifierProvider.autoDispose
    .family<GeneratorFormController, GeneratorForm, String>(
      GeneratorFormController.new,
    );

/// The student's last practice setup per exam ("Last practice" shortcut).
/// Topic ids / level / count only — nothing sensitive.
class LastPracticeStore {
  LastPracticeStore(this._prefs);

  final SharedPreferences _prefs;
  static String _key(String examId) => 'last_practice_v1_$examId';

  ({Set<String> topicIds, Difficulty difficulty, int count})? read(
    String examId,
  ) {
    final raw = _prefs.getString(_key(examId));
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (
        topicIds: (j['topicIds'] as List<dynamic>).cast<String>().toSet(),
        difficulty: Difficulty.fromJson(j['difficulty'] as String),
        count: (j['count'] as num).toInt(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> save(GenerationRequest r) => _prefs.setString(
    _key(r.examId),
    jsonEncode({
      'topicIds': r.topicIds,
      'difficulty': r.difficulty.name,
      'count': r.count,
    }),
  );
}

final lastPracticeStoreProvider = Provider<LastPracticeStore>(
  (ref) => LastPracticeStore(ref.watch(sharedPreferencesProvider)),
);
