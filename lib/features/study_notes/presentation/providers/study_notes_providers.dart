import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../localization/settings_providers.dart';
import '../../data/api_study_notes_repository.dart';
import '../../data/mock_study_notes_repository.dart';
import '../../../library/domain/library_models.dart' show LibraryFacets;
import '../../domain/learning_path.dart';
import '../../domain/notes_library.dart';
import '../../domain/study_note.dart';

/// Real backend by default; in-app mock under `flutter test` or USE_MOCK_BACKEND.
final studyNotesRepositoryProvider = Provider<StudyNotesRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) return MockStudyNotesRepository();
  return ApiStudyNotesRepository(ref.watch(apiClientProvider));
});

/// One saved note with its full content.
final studyNoteProvider = FutureProvider.autoDispose.family<StudyNote, String>(
  (ref, id) => ref.watch(studyNotesRepositoryProvider).fetch(id),
);

/// Bumped whenever a note is created/changed so note lists refresh.
class NotesRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final notesRevisionProvider = NotifierProvider<NotesRevision, int>(
  NotesRevision.new,
);

/// Create Notes form for one (exam, topic).
class NotesForm {
  const NotesForm({
    required this.language,
    this.level = NoteLevel.examStandard,
    required this.sections,
    this.generating = false,
    this.error,
  });

  final String language;
  final NoteLevel level;
  final Set<NoteSection> sections;
  final bool generating;
  final Object? error;

  bool get canGenerate => sections.isNotEmpty && !generating;

  NotesForm copyWith({
    String? language,
    NoteLevel? level,
    Set<NoteSection>? sections,
    bool? generating,
    Object? Function()? error,
  }) => NotesForm(
    language: language ?? this.language,
    level: level ?? this.level,
    sections: sections ?? this.sections,
    generating: generating ?? this.generating,
    error: error == null ? this.error : error(),
  );
}

/// Exam + topic (or unit) to create notes for. [language] / [level] prefill
/// the form, e.g. when coming from "What to Study Next" on another note.
/// Carried to Create Notes as the route `extra`.
typedef NotesPrefill = ({String? language, NoteLevel? level});

typedef NotesTarget = ({
  String examId,
  String topicId,
  String? language,
  NoteLevel? level,
});

class NotesFormController extends Notifier<NotesForm> {
  NotesFormController(this.target);

  final NotesTarget target;

  /// Same request object while the form is unchanged, so a retry after a
  /// failure reuses the idempotency key (no duplicate notes).
  NotesRequest? _pending;

  @override
  NotesForm build() => NotesForm(
    language:
        target.language ??
        (ref.read(localeProvider).languageCode == 'hi' ? 'hi' : 'en'),
    level: target.level ?? NoteLevel.examStandard,
    sections: NoteSection.defaults,
  );

  void _edit(NotesForm next) {
    _pending = null;
    state = next.copyWith(error: () => null);
  }

  void setLanguage(String code) => _edit(state.copyWith(language: code));
  void setLevel(NoteLevel level) => _edit(state.copyWith(level: level));

  void toggle(NoteSection s) {
    final next = {...state.sections};
    next.contains(s) ? next.remove(s) : next.add(s);
    _edit(state.copyWith(sections: next));
  }

  void resetSections() => _edit(state.copyWith(sections: NoteSection.defaults));

  /// Returns the saved note, or null on failure (the error is in [state]).
  Future<StudyNote?> generate() async {
    if (!state.canGenerate) return null;
    final request = _pending ??= NotesRequest(
      examId: target.examId,
      topicId: target.topicId,
      language: state.language,
      level: state.level,
      sections: state.sections,
    );
    state = state.copyWith(generating: true, error: () => null);
    try {
      final note = await ref
          .read(studyNotesRepositoryProvider)
          .generate(request);
      if (!ref.mounted) return note;
      _pending = null;
      state = state.copyWith(generating: false);
      ref.read(notesRevisionProvider.notifier).bump();
      return note;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(generating: false, error: () => e);
      }
      return null;
    }
  }
}

final notesFormProvider = NotifierProvider.autoDispose
    .family<NotesFormController, NotesForm, NotesTarget>(
      NotesFormController.new,
    );

// ── My Study Notes (Library) ────────────────────────────────────────────────

/// Note counts per category for the Library home.
final notesSummaryProvider = FutureProvider.autoDispose<NotesSummary>((ref) {
  ref.watch(notesRevisionProvider);
  return ref.watch(studyNotesRepositoryProvider).summary();
});

/// Filter options (exams / subjects / topics) from one category's notes.
final notesFacetsProvider = FutureProvider.autoDispose
    .family<LibraryFacets, String>((ref, category) {
      ref.watch(notesRevisionProvider);
      return ref.watch(studyNotesRepositoryProvider).facets(category);
    });

class NotesFilterController extends Notifier<NotesFilter> {
  NotesFilterController(this.category);

  final String category;

  @override
  NotesFilter build() => const NotesFilter();

  void set(NotesFilter filter) => state = filter;

  /// Changing the exam clears subject/topic picks that may not belong to it.
  void setExam(String? examId) => state = state.copyWith(
    examId: () => examId,
    subjectId: () => null,
    topicId: () => null,
  );

  void setSubject(String? subjectId) =>
      state = state.copyWith(subjectId: () => subjectId, topicId: () => null);

  void reset() => state = NotesFilter(sort: state.sort, view: state.view);
}

final notesFilterProvider = NotifierProvider.autoDispose
    .family<NotesFilterController, NotesFilter, String>(
      NotesFilterController.new,
    );

/// Loaded notes of one category for the current filter, page by page.
class NotesListState {
  const NotesListState({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<StudyNote> items;
  final int total;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final Object? loadMoreError;
}

class NotesListController extends AsyncNotifier<NotesListState> {
  NotesListController(this.category);

  final String category;

  @override
  Future<NotesListState> build() async {
    ref.watch(notesRevisionProvider);
    final filter = ref.watch(notesFilterProvider(category));
    final p = await ref
        .watch(studyNotesRepositoryProvider)
        .list(category, filter);
    return NotesListState(
      items: p.items,
      total: p.total,
      page: p.page,
      hasMore: p.hasMore,
    );
  }

  /// Appends the next page; an error stays on the state with a retry button
  /// so already loaded notes remain visible.
  Future<void> loadMore() async {
    final s = state.value;
    if (s == null || !s.hasMore || s.loadingMore) return;
    NotesListState copy({bool loading = false, Object? error}) =>
        NotesListState(
          items: s.items,
          total: s.total,
          page: s.page,
          hasMore: s.hasMore,
          loadingMore: loading,
          loadMoreError: error,
        );
    state = AsyncData(copy(loading: true));
    try {
      final next = await ref
          .read(studyNotesRepositoryProvider)
          .list(
            category,
            ref.read(notesFilterProvider(category)),
            page: s.page + 1,
          );
      if (!ref.mounted) return;
      final seen = s.items.map((n) => n.id).toSet();
      state = AsyncData(
        NotesListState(
          items: [...s.items, ...next.items.where((n) => !seen.contains(n.id))],
          total: next.total,
          page: next.page,
          hasMore: next.hasMore,
        ),
      );
    } on Object catch (e) {
      if (ref.mounted) state = AsyncData(copy(error: e));
    }
  }
}

final notesListProvider = AsyncNotifierProvider.autoDispose
    .family<NotesListController, NotesListState, String>(
      NotesListController.new,
    );

/// Bookmark / personal note / delete. Each call returns only after the
/// backend confirmed; then every notes list and count refreshes.
class NoteActions {
  NoteActions(this._ref);

  final Ref _ref;

  StudyNotesRepository get _repo => _ref.read(studyNotesRepositoryProvider);

  Future<StudyNote> setBookmarked(StudyNote note, bool value) =>
      _saved(_repo.update(note.id, bookmarked: value));

  Future<StudyNote> savePersonalNote(StudyNote note, String text) =>
      _saved(_repo.update(note.id, personalNote: text.trim()));

  Future<void> delete(StudyNote note) async {
    await _repo.delete(note.id);
    _ref.read(notesRevisionProvider.notifier).bump();
  }

  Future<StudyNote> _saved(Future<StudyNote> request) async {
    final updated = await request;
    _ref.read(notesRevisionProvider.notifier).bump();
    return updated;
  }
}

final noteActionsProvider = Provider<NoteActions>(NoteActions.new);

// ── Learning path ───────────────────────────────────────────────────────────

typedef PathKey = ({String examId, String subjectId});

/// Ordered topics/units of one subject with the student's saved progress.
/// Reloads when notes or progress change ([notesRevisionProvider]).
final learningPathProvider = FutureProvider.autoDispose
    .family<LearningPath, PathKey>((ref, key) {
      ref.watch(notesRevisionProvider);
      return ref
          .watch(studyNotesRepositoryProvider)
          .learningPath(key.examId, key.subjectId);
    });

/// Saves completion on the backend first; then every path view refreshes.
Future<void> setLearningItemCompleted(
  WidgetRef ref, {
  required String examId,
  required String itemId,
  required bool completed,
}) async {
  await ref
      .read(studyNotesRepositoryProvider)
      .setCompleted(examId, itemId, completed: completed);
  ref.read(notesRevisionProvider.notifier).bump();
}
