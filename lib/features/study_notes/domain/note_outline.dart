import 'study_note.dart';
import 'syllabus_tree.dart';

export 'syllabus_tree.dart';

/// Section-by-section study notes built on a curated outline
/// (`/notes/outlines/*`, `/notes/sections/*`).

enum LearningMode {
  quick,
  detailed,
  complete;

  String get wire => name;
}

enum SectionState {
  pending,
  generated,
  completed,
  failed;

  static SectionState fromWire(String? v) =>
      values.firstWhere((s) => s.name == v, orElse: () => pending);
}

/// Shared content readiness of a section (not the student's progress).
enum ContentStatus {
  ready,
  notGenerated,
  generating,
  incomplete,
  validationFailed,
  failed;

  static ContentStatus fromWire(String? v) => switch (v) {
    'ready' => ready,
    'generating' => generating,
    'incomplete' => incomplete,
    'validation_failed' => validationFailed,
    'failed' => failed,
    _ => notGenerated,
  };

  bool get isProblem =>
      this == incomplete || this == validationFailed || this == failed;
}

class OutlineSection {
  const OutlineSection({
    required this.id,
    required this.title,
    required this.state,
    this.origin = 'curated',
    this.noteId,
    this.cached = false,
    this.error,
    this.path = const [],
    this.contentStatus = ContentStatus.notGenerated,
  });

  /// Subtopic titles above this section (nested outlines); empty when flat.
  final List<String> path;

  /// Shared content status — separate from this student's [state].
  final ContentStatus contentStatus;

  final String id;
  final String title;

  /// `curated`, `recommended` or `ai_suggested` (labelled in the app).
  final String origin;
  final SectionState state;
  final String? noteId;

  /// Content already exists in the shared cache (opening it uses no AI).
  final bool cached;
  final String? error;

  factory OutlineSection.fromJson(Map<String, dynamic> j) => OutlineSection(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    origin: j['origin'] as String? ?? 'curated',
    state: SectionState.fromWire(j['state'] as String?),
    noteId: j['noteId'] as String?,
    cached: j['cached'] == true,
    error: j['error'] as String?,
    path: (j['path'] as List<dynamic>? ?? const []).cast<String>(),
    contentStatus: ContentStatus.fromWire(
      j['contentStatus'] as String? ?? (j['cached'] == true ? 'ready' : null),
    ),
  );
}

class OutlineChapter {
  const OutlineChapter({
    required this.id,
    required this.title,
    required this.sections,
    this.weight,
  });

  final String id;
  final String title;

  /// How often it is tested: high / medium / low.
  final String? weight;
  final List<OutlineSection> sections;

  int get completed =>
      sections.where((s) => s.state == SectionState.completed).length;
  bool get complete => completed == sections.length;

  factory OutlineChapter.fromJson(Map<String, dynamic> j) => OutlineChapter(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    weight: j['weight'] as String?,
    sections: [
      for (final s in j['sections'] as List<dynamic>? ?? const [])
        OutlineSection.fromJson(s as Map<String, dynamic>),
    ],
  );
}

typedef SectionRef = ({String chapterId, String sectionId});

class NoteOutline {
  const NoteOutline({
    required this.examId,
    required this.unitId,
    required this.title,
    required this.status,
    required this.version,
    required this.language,
    required this.mode,
    required this.chapters,
    this.continueAt,
    this.isSample = false,
    this.fromAi = false,
    this.revisionPlan = const [],
  });

  final String examId;
  final String unitId;
  final String title;

  /// `approved`, or `draft` (only visible in review / development).
  final String status;
  final int version;
  final String language;
  final LearningMode mode;
  final List<OutlineChapter> chapters;

  /// First section not completed yet.
  final SectionRef? continueAt;

  /// Development fixture (USE_MOCK_BACKEND) — never real study material.
  final bool isSample;

  /// AI-built chapter index, approved by a reviewer (Chapter Builder).
  final bool fromAi;

  /// Final revision steps (Chapter Builder indexes).
  final List<String> revisionPlan;

  bool get isDraft => status != 'approved';

  List<(OutlineChapter, OutlineSection)> get ordered => [
    for (final c in chapters)
      for (final s in c.sections) (c, s),
  ];

  int get total => ordered.length;
  int get completed => chapters.fold(0, (n, c) => n + c.completed);

  /// Sections whose shared content is ready (content coverage).
  int get contentReady =>
      ordered.where((e) => e.$2.contentStatus == ContentStatus.ready).length;

  /// Never claimed unless every planned section is completed.
  bool get coverageComplete => total > 0 && completed == total;

  int indexOf(SectionRef r) => ordered.indexWhere(
    (e) => e.$1.id == r.chapterId && e.$2.id == r.sectionId,
  );

  (OutlineChapter, OutlineSection)? at(int i) =>
      i >= 0 && i < ordered.length ? ordered[i] : null;

  factory NoteOutline.fromJson(Map<String, dynamic> j) {
    final next = j['continue'];
    return NoteOutline(
      examId: j['examId'] as String,
      unitId: j['unitId'] as String,
      title: j['title'] as String? ?? '',
      status: j['status'] as String? ?? 'approved',
      version: (j['version'] as num? ?? 1).toInt(),
      language: j['language'] as String? ?? 'en',
      mode: LearningMode.values.firstWhere(
        (m) => m.wire == j['mode'],
        orElse: () => LearningMode.complete,
      ),
      chapters: [
        for (final c in j['chapters'] as List<dynamic>? ?? const [])
          OutlineChapter.fromJson(c as Map<String, dynamic>),
      ],
      continueAt: next is Map
          ? (
              chapterId: next['chapterId'] as String,
              sectionId: next['sectionId'] as String,
            )
          : null,
      fromAi: j['source'] == 'ai_reviewed',
      revisionPlan: [
        for (final s in j['revisionPlan'] as List<dynamic>? ?? const [])
          s as String,
      ],
    );
  }
}

/// Result of asking for a chapter index: `approved` (open it now) or
/// `pending_review` (built by AI, waiting for a reviewer).
enum ChapterIndexStatus { approved, pendingReview }

/// Which outline view: one exam unit in one language and learning mode.
typedef OutlineKey = ({
  String examId,
  String unitId,
  String language,
  LearningMode mode,
});

/// A section opened for reading. [isSample] = development fixture content:
/// shown with a label, never saved, never marked as verified.
/// [contentStatus]: published / approved / ready_for_review;
/// [review]: auto (AI-checked) / human; [verification]: unverified /
/// sources_listed; [coverageBasis]: manifest / structure_only.
typedef OpenedSection = ({
  StudyNote note,
  String source,
  bool isSample,
  String? contentStatus,
  String? review,
  String? verification,
  String? coverageBasis,
});

/// The server is still preparing this section (202). Check again shortly.
class SectionGeneratingException implements Exception {
  const SectionGeneratingException({this.retryAfterSeconds = 10});
  final int retryAfterSeconds;
}

abstract interface class OutlineRepository {
  Future<NoteOutline> outline(OutlineKey key);

  /// Saved copy → shared cache → new AI generation (server decides).
  Future<OpenedSection> openSection(OutlineKey key, SectionRef section);

  /// Nested Subject → Topic → [Unit] → Chapter → [Subtopic…] → Section tree
  /// with content readiness and this student's progress.
  Future<SyllabusTree> tree({
    required String examId,
    required String subjectId,
    required String language,
    LearningMode mode = LearningMode.complete,
  });

  /// Progress roll-ups, sections to continue and topics to revise
  /// (from the student's practice results).
  Future<LearningRecommendations> recommendations({
    required String examId,
    required String subjectId,
    required String language,
  });

  Future<NoteOutline> setSectionCompleted(
    OutlineKey key,
    SectionRef section, {
    required bool completed,
  });

  /// Asks the server to build a chapter index for a topic without one. It is
  /// reviewed before students can open it.
  Future<ChapterIndexStatus> requestChapterIndex(String examId, String unitId);
}
