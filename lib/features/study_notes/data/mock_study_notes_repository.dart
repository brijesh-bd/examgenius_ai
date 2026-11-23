import '../../../core/network/api_client.dart';
import '../../library/domain/library_models.dart';
import '../../question_generator/data/mock_syllabus_repository.dart';
import '../../question_generator/domain/question_generator_repository.dart';
import '../domain/learning_path.dart';
import '../domain/notes_library.dart';
import '../domain/study_note.dart';

/// In-memory notes for `flutter test` / USE_MOCK_BACKEND. Builds a small note
/// from the request so the full screen flow can be exercised offline.
class MockStudyNotesRepository implements StudyNotesRepository {
  MockStudyNotesRepository({
    this.latency = const Duration(milliseconds: 400),
    this.fail = false,
    SyllabusRepository? syllabus,
  }) : _syllabus = syllabus ?? MockSyllabusRepository();

  /// The app's existing (mock) syllabus — the path is built from it, like the
  /// backend builds it from its syllabus mapping. No units in the mock.
  final SyllabusRepository _syllabus;

  /// Completed path items per exam.
  final Map<String, Set<String>> _completed = {};

  final Duration latency;

  /// Simulates a failed generation (nothing is saved).
  bool fail;

  final Map<String, StudyNote> _notes = {};
  int _seq = 0;

  List<StudyNote> get saved => _notes.values.toList();

  /// Seeds a saved note (tests).
  void add(StudyNote note) => _notes[note.id] = note;

  static const _pageSize = 20;

  @override
  Future<NotesPage> list(
    String category,
    NotesFilter filter, {
    int page = 1,
  }) async {
    await Future<void>.delayed(latency);
    final all =
        _notes.values
            .where((n) => n.category == category && filter.matches(n))
            .toList()
          ..sort(
            (a, b) => filter.sort == LibrarySort.latest
                ? b.createdAt.compareTo(a.createdAt)
                : a.createdAt.compareTo(b.createdAt),
          );
    final start = (page - 1) * _pageSize;
    return NotesPage(
      items: all.skip(start).take(_pageSize).toList(),
      total: all.length,
      page: page,
      hasMore: start + _pageSize < all.length,
    );
  }

  @override
  Future<LibraryFacets> facets(String category) async {
    await Future<void>.delayed(latency);
    final notes = _notes.values.where((n) => n.category == category);
    final exams = <String, NamedRef>{};
    final subjects = <String, ({NamedRef subject, Set<String> examIds})>{};
    final topics = <String, ({TopicRef topic, Set<String> examIds})>{};
    for (final n in notes) {
      exams[n.examId] = NamedRef(id: n.examId, name: n.examName);
      (subjects[n.subjectId] ??= (
        subject: NamedRef(id: n.subjectId, name: n.subjectName),
        examIds: <String>{},
      )).examIds.add(n.examId);
      (topics[n.topicId] ??= (
        topic: TopicRef(
          id: n.topicId,
          name: n.topicName,
          subjectId: n.subjectId,
        ),
        examIds: <String>{},
      )).examIds.add(n.examId);
    }
    return LibraryFacets(
      exams: exams.values.toList(),
      subjects: subjects.values.toList(),
      topics: topics.values.toList(),
    );
  }

  @override
  Future<NotesSummary> summary() async {
    await Future<void>.delayed(latency);
    final by = <String, int>{};
    for (final n in _notes.values) {
      by[n.category] = (by[n.category] ?? 0) + 1;
    }
    return NotesSummary(total: _notes.length, byCategory: by);
  }

  @override
  Future<StudyNote> generate(NotesRequest request) async {
    await Future<void>.delayed(latency);
    if (fail) {
      throw const ApiException(
        'The AI notes were incomplete.',
        statusCode: 502,
      );
    }
    final on = request.sections;
    final path = await _path(request.examId, request.topicId.split('.').first);
    final item = path?.item(request.topicId);
    final next = path == null
        ? const <LearningItem>[]
        : [
            for (
              var n = path.nextAfter(request.topicId);
              n != null &&
                  n.order <= (path.item(request.topicId)?.order ?? 0) + 3;
              n = path.nextAfter(n.id)
            )
              n,
          ];
    final note = StudyNote(
      id: 'note_${++_seq}',
      category: request.examId.startsWith('rrb')
          ? 'railway'
          : request.examId.startsWith('ssc')
          ? 'ssc'
          : 'banking',
      examId: request.examId,
      examName: request.examId,
      subjectId: request.topicId.split('.').first,
      subjectName: path?.subjectName ?? request.topicId.split('.').first,
      topicId: request.topicId,
      topicName: item?.fullName ?? request.topicId,
      language: request.language,
      level: request.level,
      createdAt: DateTime.now(),
      model: 'mock',
      content: NoteContent(
        overview: 'Overview of ${request.topicId}.',
        explanation: on.contains(NoteSection.explanation)
            ? const [NoteParagraph('Core idea', 'Explanation body.')]
            : const [],
        formulas: on.contains(NoteSection.formulas)
            ? const [
                NoteFormula(
                  'Simple interest',
                  'SI = P × R × T / 100',
                  'P principal',
                ),
              ]
            : const [],
        tables: on.contains(NoteSection.formulas)
            ? const [
                NoteTable(
                  'Compare',
                  ['Term', 'Meaning'],
                  [
                    ['P', 'Principal'],
                  ],
                ),
              ]
            : const [],
        flowcharts: on.contains(NoteSection.diagrams)
            ? const [
                NoteFlowchart('Steps', ['Read', 'Apply formula', 'Check']),
              ]
            : const [],
        graphs: on.contains(NoteSection.graphs)
            ? const [
                NoteGraph(
                  title: 'Growth',
                  xLabel: 'Years',
                  yLabel: 'Amount',
                  points: [
                    NotePoint(0, 100),
                    NotePoint(1, 110),
                    NotePoint(2, 121),
                  ],
                  caption: '',
                ),
              ]
            : const [],
        tips: on.contains(NoteSection.tips)
            ? const ['Use 10% chunks.']
            : const [],
        mcqs: on.contains(NoteSection.mcqs)
            ? const [
                NoteMcq(
                  question: 'Mock question?',
                  options: ['A1', 'B1', 'C1', 'D1'],
                  correctIndex: 1,
                  explanation: 'Because B1.',
                ),
              ]
            : const [],
        nextTopics: [for (final n in next) NoteNextTopic(n.fullName, id: n.id)],
      ),
    );
    _notes[note.id] = note;
    return note;
  }

  @override
  Future<StudyNote> update(
    String id, {
    bool? bookmarked,
    String? personalNote,
  }) async {
    await Future<void>.delayed(latency);
    final n = _notes[id];
    if (n == null) throw const ApiException('Note not found', statusCode: 404);
    return _notes[id] = n.copyWith(
      bookmarked: bookmarked,
      personalNote: personalNote,
    );
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(latency);
    if (_notes.remove(id) == null) {
      throw const ApiException('Note not found', statusCode: 404);
    }
  }

  Future<LearningPath?> _path(String examId, String subjectId) async {
    final syllabus = await _syllabus.fetchSyllabus(examId);
    final subject = syllabus.subjects
        .where((s) => s.id == subjectId)
        .firstOrNull;
    if (subject == null) return null;
    final done = _completed[examId] ?? const <String>{};
    String? currentId;
    final items = <LearningItem>[];
    for (final (i, t) in subject.topics.indexed) {
      final notes =
          _notes.values
              .where((n) => n.examId == examId && n.topicId == t.id)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      var status = LearningStatus.upcoming;
      if (done.contains(t.id)) {
        status = LearningStatus.completed;
      } else if (currentId == null) {
        currentId = t.id;
        status = LearningStatus.current;
      }
      items.add(
        LearningItem(
          id: t.id,
          name: t.name,
          topicId: t.id,
          topicName: t.name,
          order: i + 1,
          status: status,
          completedAt: status == LearningStatus.completed
              ? DateTime.now()
              : null,
          latestNoteId: notes.firstOrNull?.id,
          notesCount: notes.length,
        ),
      );
    }
    return LearningPath(
      examId: examId,
      examName: examId,
      category: examId.startsWith('rrb')
          ? 'railway'
          : examId.startsWith('ssc')
          ? 'ssc'
          : 'banking',
      subjectId: subject.id,
      subjectName: subject.name,
      currentId: currentId,
      items: items,
    );
  }

  @override
  Future<LearningPath> learningPath(String examId, String subjectId) async {
    await Future<void>.delayed(latency);
    final p = await _path(examId, subjectId);
    if (p == null) {
      throw const ApiException('Subject not found', statusCode: 404);
    }
    return p;
  }

  @override
  Future<LearningPath> setCompleted(
    String examId,
    String itemId, {
    required bool completed,
  }) async {
    await Future<void>.delayed(latency);
    final set = _completed.putIfAbsent(examId, () => {});
    completed ? set.add(itemId) : set.remove(itemId);
    return learningPath(examId, itemId.split('.').first);
  }

  @override
  Future<StudyNote> fetch(String id) async {
    await Future<void>.delayed(latency);
    final n = _notes[id];
    if (n == null) throw const ApiException('Note not found', statusCode: 404);
    return n;
  }
}
