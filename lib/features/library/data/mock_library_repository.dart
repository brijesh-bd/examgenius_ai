import '../../practice_test/domain/practice_models.dart';
import '../../practice_test/domain/practice_result.dart';
import '../domain/library_models.dart';

/// In-memory Library for `flutter test` / USE_MOCK_BACKEND. Starts empty —
/// tests add sets with [add]. Same filter and sort rules as the backend.
class MockLibraryRepository implements LibraryRepository {
  MockLibraryRepository({this.latency = const Duration(milliseconds: 150)});

  final Duration latency;
  final List<LibrarySet> _sets = [];

  static const pageSize = 20;

  void add(LibrarySet set) => _sets.add(set);

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<LibrarySummary> summary() async {
    await _wait();
    final byCategory = <String, CategoryCount>{};
    for (final s in _sets) {
      final c = byCategory[s.category];
      byCategory[s.category] = CategoryCount(
        category: s.category,
        sets: (c?.sets ?? 0) + 1,
        questions: (c?.questions ?? 0) + s.questionCount,
        attempted: (c?.attempted ?? 0) + (s.stats.attempted ? 1 : 0),
      );
    }
    final recent = [..._sets]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return LibrarySummary(
      totalSets: _sets.length,
      totalQuestions: _sets.fold(0, (n, s) => n + s.questionCount),
      bookmarks: 0,
      notes: 0,
      categories: byCategory.values.toList(),
      recent: recent.take(5).toList(),
    );
  }

  @override
  Future<LibraryPage> listSets(
    String category,
    LibraryFilter filter, {
    int page = 1,
  }) async {
    await _wait();
    final all =
        _sets.where((s) => s.category == category && filter.matches(s)).toList()
          ..sort(
            (a, b) => filter.sort == LibrarySort.oldest
                ? a.createdAt.compareTo(b.createdAt)
                : b.createdAt.compareTo(a.createdAt),
          );
    return LibraryPage(
      items: all.skip((page - 1) * pageSize).take(pageSize).toList(),
      total: all.length,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<LibraryFacets> facets(String category) async {
    await _wait();
    final sets = _sets.where((s) => s.category == category);
    final exams = <String, NamedRef>{};
    final subjects = <String, (NamedRef, Set<String>)>{};
    final topics = <String, (TopicRef, Set<String>)>{};
    for (final s in sets) {
      exams[s.examId] = NamedRef(id: s.examId, name: s.examName);
      for (final x in s.subjects) {
        (subjects[x.id] ??= (x, <String>{})).$2.add(s.examId);
      }
      for (final t in s.topics) {
        (topics[t.id] ??= (t, <String>{})).$2.add(s.examId);
      }
    }
    return LibraryFacets(
      exams: exams.values.toList(),
      subjects: [
        for (final e in subjects.values) (subject: e.$1, examIds: e.$2),
      ],
      topics: [for (final e in topics.values) (topic: e.$1, examIds: e.$2)],
    );
  }

  @override
  Future<void> deleteSet(String setId) async {
    await _wait();
    final before = _sets.length;
    _sets.removeWhere((s) => s.id == setId);
    if (_sets.length == before) throw StateError('Practice set not found');
  }

  @override
  Future<PracticeSession> startSet(String setId) async {
    await _wait();
    throw UnsupportedError('Practice Again needs the backend');
  }

  @override
  Future<List<SetAttempt>> attempts(String setId) async {
    await _wait();
    return const [];
  }

  @override
  Future<PracticeResult> fetchResult(String resultId) async {
    await _wait();
    throw UnsupportedError('Review needs the backend');
  }
}
