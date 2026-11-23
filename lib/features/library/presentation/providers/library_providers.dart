import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../data/api_library_repository.dart';
import '../../data/mock_library_repository.dart';
import '../../domain/library_models.dart';

/// Real backend by default; in-memory mock under `flutter test` or USE_MOCK_BACKEND.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) return MockLibraryRepository();
  return ApiLibraryRepository(ref.watch(apiClientProvider));
});

/// Bumped whenever Library data changes elsewhere (a set was generated, an
/// attempt submitted). The Library tab stays alive in the bottom-nav stack,
/// so its providers watch this to reload instead of showing stale data.
class LibraryRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final libraryRevisionProvider = NotifierProvider<LibraryRevision, int>(
  LibraryRevision.new,
);

final librarySummaryProvider = FutureProvider.autoDispose<LibrarySummary>((
  ref,
) {
  ref.watch(libraryRevisionProvider);
  return ref.watch(libraryRepositoryProvider).summary();
});

/// Filter options (exams / subjects / topics) of one category.
final libraryFacetsProvider = FutureProvider.autoDispose
    .family<LibraryFacets, String>((ref, category) {
      ref.watch(libraryRevisionProvider);
      return ref.watch(libraryRepositoryProvider).facets(category);
    });

/// Practice history of one set.
final setAttemptsProvider = FutureProvider.autoDispose
    .family<List<SetAttempt>, String>((ref, setId) {
      ref.watch(libraryRevisionProvider);
      return ref.watch(libraryRepositoryProvider).attempts(setId);
    });

/// Current filters of one category library.
class LibraryFilterController extends Notifier<LibraryFilter> {
  LibraryFilterController(this.category);

  final String category;

  @override
  LibraryFilter build() => const LibraryFilter();

  void set(LibraryFilter filter) => state = filter;

  /// Changing the exam clears subject/topic picks that may not belong to it.
  void setExam(String? examId) => state = state.copyWith(
    examId: () => examId,
    subjectId: () => null,
    topicId: () => null,
  );

  /// Changing the subject clears a topic from another subject.
  void setSubject(String? subjectId) =>
      state = state.copyWith(subjectId: () => subjectId, topicId: () => null);

  void reset() => state = LibraryFilter(sort: state.sort);
}

final libraryFilterProvider = NotifierProvider.autoDispose
    .family<LibraryFilterController, LibraryFilter, String>(
      LibraryFilterController.new,
    );

/// Loaded sets of one category for the current filter, page by page.
@immutable
class LibraryListState {
  const LibraryListState({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<LibrarySet> items;
  final int total;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final Object? loadMoreError;

  LibraryListState copyWith({
    List<LibrarySet>? items,
    int? total,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    Object? loadMoreError,
    bool clearError = false,
  }) => LibraryListState(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
  );
}

class LibraryListController extends AsyncNotifier<LibraryListState> {
  LibraryListController(this.category);

  final String category;

  LibraryRepository get _repo => ref.read(libraryRepositoryProvider);

  @override
  Future<LibraryListState> build() async {
    ref.watch(libraryRevisionProvider);
    final filter = ref.watch(libraryFilterProvider(category));
    final page = await ref
        .watch(libraryRepositoryProvider)
        .listSets(category, filter);
    return LibraryListState(
      items: page.items,
      total: page.total,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Appends the next page. Errors are kept on the state (shown with retry)
  /// so the items already loaded stay visible.
  Future<void> loadMore() async {
    final s = state.value;
    if (s == null || !s.hasMore || s.loadingMore) return;
    state = AsyncData(s.copyWith(loadingMore: true, clearError: true));
    final filter = ref.read(libraryFilterProvider(category));
    try {
      final next = await _repo.listSets(category, filter, page: s.page + 1);
      if (!ref.mounted) return;
      final seen = s.items.map((e) => e.id).toSet();
      state = AsyncData(
        s.copyWith(
          items: [...s.items, ...next.items.where((e) => !seen.contains(e.id))],
          total: next.total,
          page: next.page,
          hasMore: next.hasMore,
          loadingMore: false,
        ),
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(s.copyWith(loadingMore: false, loadMoreError: e));
    }
  }

  /// Deletes on the backend first; the card disappears only after the
  /// server confirmed. Returns false on failure (nothing changes locally).
  Future<bool> delete(String setId) async {
    try {
      await _repo.deleteSet(setId);
    } on Object {
      return false;
    }
    if (!ref.mounted) return true;
    final s = state.value;
    if (s != null) {
      state = AsyncData(
        s.copyWith(
          items: s.items.where((e) => e.id != setId).toList(),
          total: s.total - 1,
        ),
      );
    }
    // Totals and filter options elsewhere change too.
    ref
      ..invalidate(librarySummaryProvider)
      ..invalidate(libraryFacetsProvider(category));
    return true;
  }
}

final libraryListProvider = AsyncNotifierProvider.autoDispose
    .family<LibraryListController, LibraryListState, String>(
      LibraryListController.new,
    );
