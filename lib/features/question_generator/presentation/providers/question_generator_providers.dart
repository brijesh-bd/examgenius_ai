import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/services/preferences_service.dart';
import '../../data/api_syllabus_repository.dart';
import '../../data/mock_question_generator_repository.dart';
import '../../data/mock_syllabus_repository.dart';
import '../../data/practice_setup_repositories.dart';
import '../../data/concept_hierarchy_repository.dart';
import '../../domain/generated_question.dart';
import '../../domain/question_generator_repository.dart';
import '../../domain/concept_hierarchy.dart';
import '../../domain/syllabus.dart';

final syllabusRepositoryProvider = Provider<SyllabusRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) return MockSyllabusRepository();
  return ApiSyllabusRepository(ref.watch(apiClientProvider));
});

final questionGeneratorRepositoryProvider =
    Provider<QuestionGeneratorRepository>(
      (ref) => MockQuestionGeneratorRepository(),
    );

final practiceSetupRepositoryProvider = Provider<PracticeSetupRepository>((
  ref,
) {
  if (ref.watch(useMockBackendProvider)) return MockPracticeSetupRepository();
  return ApiPracticeSetupRepository(ref.watch(apiClientProvider));
});

final syllabusProvider = FutureProvider.autoDispose.family<Syllabus, String>(
  (ref, examId) => ref.watch(syllabusRepositoryProvider).fetchSyllabus(examId),
);

final conceptHierarchyRepositoryProvider = Provider<ConceptHierarchyRepository>(
  (ref) {
    if (ref.watch(useMockBackendProvider)) {
      return MockConceptHierarchyRepository();
    }
    return ApiConceptHierarchyRepository(ref.watch(apiClientProvider));
  },
);

/// Concept hierarchy of a Railway exam's Mathematics (null for other exams).
/// Which exam's subject tree to load.
typedef ConceptKey = ({String examId, String subjectId});

/// Hierarchical syllabus of one exam's subject (null = flat topics only).
final conceptHierarchyProvider = FutureProvider.autoDispose
    .family<ConceptHierarchy?, ConceptKey>(
      (ref, key) => ref
          .watch(conceptHierarchyRepositoryProvider)
          .fetchTree(key.examId, key.subjectId),
    );

/// Practice type / topics / level / count / source on Create Practice, per exam.
class GeneratorFormController extends Notifier<GeneratorForm> {
  GeneratorFormController(this.examId);

  final String examId;

  @override
  GeneratorForm build() => const GeneratorForm();

  void setMode(PracticeMode mode) => state = state.copyWith(mode: mode);

  void toggleTopic(String topicId) {
    final next = {...state.topicIds};
    if (!next.remove(topicId)) next.add(topicId);
    state = state.copyWith(topicIds: next);
  }

  /// Shows [subjectId]'s topics (selection in other subjects is kept).
  void setActiveSubject(String subjectId) =>
      state = state.copyWith(activeSubjectId: subjectId);

  /// Preparation screen: one subject at a time, so switching subject clears
  /// the topics picked in the previous one.
  void selectSubject(String subjectId) => state = state.copyWith(
    activeSubjectId: subjectId,
    topicIds: const {},
    nodeIds: const {},
  );

  /// Selects / clears a concept-tree node (parents include their children).
  void toggleNode(ConceptHierarchy tree, String nodeId) =>
      state = state.copyWith(nodeIds: tree.toggle(nodeId, state.nodeIds));

  void clearNodes() => state = state.copyWith(nodeIds: const {});

  /// Selects / clears the whole subject (every chapter of [tree]).
  void toggleWholeSubject(ConceptHierarchy tree) {
    final all = {for (final c in tree.chapters) c.id};
    final everything = tree.conceptsOf(all);
    state = state.copyWith(
      nodeIds: tree.conceptsOf(state.nodeIds).length == everything.length
          ? const {}
          : all,
    );
  }

  /// Selects every topic of [subject] (or only [visible] ones while searching).
  void selectAllIn(SyllabusSubject subject, {Iterable<String>? visible}) {
    state = state.copyWith(
      topicIds: {
        ...state.topicIds,
        ...(visible ?? subject.topics.map((t) => t.id)),
      },
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

  void setSource(QuestionSource source) =>
      state = state.copyWith(source: source);

  /// Builds the request, or `null` while the form is incomplete.
  GenerationRequest? buildRequest({
    required String examName,
    required Syllabus syllabus,
    ConceptHierarchy? mathTree,
  }) {
    if (!state.isComplete) return null;
    if (mathTree != null &&
        state.mode != PracticeMode.quick &&
        state.nodeIds.isNotEmpty) {
      return GenerationRequest(
        examId: examId,
        examName: examName,
        // Chapter-level ids keep bank stats/Last Practice meaningful.
        topicIds: const [],
        subjectId: mathTree.subjectId,
        selectedNodeIds: mathTree.ordered(mathTree.normalise(state.nodeIds)),
        difficulty: state.difficulty,
        count: state.count,
        source: state.source,
        mode: state.mode,
      );
    }
    // Keep syllabus order so identical selections produce equal requests.
    final ordered = state.mode == PracticeMode.quick
        ? <String>[]
        : [
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
      source: state.source,
      mode: state.mode,
    );
  }
}

final generatorFormProvider = NotifierProvider.autoDispose
    .family<GeneratorFormController, GeneratorForm, String>(
      GeneratorFormController.new,
    );

/// Local cache of the Last Practice configuration per exam: instant display
/// and offline fallback. The account copy on the server is the source of truth.
class LastPracticeStore {
  LastPracticeStore(this._prefs);

  final SharedPreferences _prefs;
  static String _key(String examId) => 'last_practice_v2_$examId';

  LastPracticeConfig? read(String examId) {
    final raw = _prefs.getString(_key(examId));
    if (raw == null) return null;
    try {
      return LastPracticeConfig.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      return null;
    }
  }

  Future<void> save(LastPracticeConfig c) =>
      _prefs.setString(_key(c.examId), jsonEncode(c.toJson()));
}

final lastPracticeStoreProvider = Provider<LastPracticeStore>(
  (ref) => LastPracticeStore(ref.watch(sharedPreferencesProvider)),
);

/// Last Practice for an exam: the server's copy (cross-device), cached
/// locally; the cache is used when the server cannot be reached.
final lastPracticeProvider = FutureProvider.autoDispose
    .family<LastPracticeConfig?, String>((ref, examId) async {
      final store = ref.read(lastPracticeStoreProvider);
      try {
        final remote = await ref
            .read(practiceSetupRepositoryProvider)
            .lastConfig(examId);
        if (remote != null) await store.save(remote);
        return remote ?? store.read(examId);
      } on Object {
        return store.read(examId);
      }
    });
