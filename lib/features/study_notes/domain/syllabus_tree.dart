/// One node of the syllabus tree (`GET /syllabus/tree/:examId`):
/// exam → subject → topic → [unit] → chapter → [subtopic…] → section.
///
/// [content] (shared readiness) and [progress] (this student) are separate:
/// generating content never marks a student as having studied it.
enum TreeNodeType {
  exam,
  subject,
  topic,
  unit,
  chapter,
  subtopic,
  section;

  static TreeNodeType fromWire(String? v) =>
      values.firstWhere((t) => t.name == v, orElse: () => topic);
}

/// Where to open a section (existing section API).
typedef TreeSectionRef = ({String unitId, String chapterId, String sectionId});

class TreeStats {
  const TreeStats({this.sections = 0, this.ready = 0, this.completed = 0});
  final int sections;
  final int ready;
  final int completed;

  factory TreeStats.fromJson(Object? j) {
    final m = j is Map<String, dynamic> ? j : const <String, dynamic>{};
    return TreeStats(
      sections: (m['sections'] as num? ?? 0).toInt(),
      ready: (m['ready'] as num? ?? 0).toInt(),
      completed: (m['completed'] as num? ?? 0).toInt(),
    );
  }
}

class SyllabusTreeNode {
  const SyllabusTreeNode({
    required this.id,
    required this.type,
    required this.name,
    this.status = 'approved',
    this.children = const [],
    this.stats = const TreeStats(),
    this.content,
    this.progress,
    this.ref,
    this.weight,
    this.objectives = const [],
  });

  final String id;
  final TreeNodeType type;
  final String name;

  /// approved / draft (drafts only appear in admin preview).
  final String status;
  final List<SyllabusTreeNode> children;
  final TreeStats stats;

  /// Section only: ready / not_generated / generating / incomplete / …
  final String? content;

  /// completed / not_started (sections, and topics/units without outlines).
  final String? progress;
  final TreeSectionRef? ref;
  final String? weight;

  /// Learning objectives from an approved coverage manifest (sections).
  final List<String> objectives;

  bool get isDraft => status == 'draft';
  bool get isCompleted => progress == 'completed';
  bool get hasSections => stats.sections > 0;

  /// The node with [id] in this subtree, or null.
  SyllabusTreeNode? find(String id) {
    if (this.id == id) return this;
    for (final c in children) {
      final hit = c.find(id);
      if (hit != null) return hit;
    }
    return null;
  }

  factory SyllabusTreeNode.fromJson(Map<String, dynamic> j) {
    final ref = j['ref'];
    final manifest = j['manifest'];
    return SyllabusTreeNode(
      id: j['id'] as String,
      type: TreeNodeType.fromWire(j['type'] as String?),
      name: j['name'] as String? ?? '',
      status: j['status'] as String? ?? 'approved',
      stats: TreeStats.fromJson(j['stats']),
      content: j['content'] as String?,
      progress: j['progress'] as String?,
      weight: j['weight'] as String?,
      ref: ref is Map<String, dynamic>
          ? (
              unitId: ref['unitId'] as String,
              chapterId: ref['chapterId'] as String,
              sectionId: ref['sectionId'] as String,
            )
          : null,
      objectives: manifest is Map<String, dynamic>
          ? (manifest['objectives'] as List<dynamic>? ?? const [])
                .cast<String>()
          : const [],
      children: [
        for (final c in j['children'] as List<dynamic>? ?? const [])
          SyllabusTreeNode.fromJson(c as Map<String, dynamic>),
      ],
    );
  }
}

/// The tree response: the subject subtree plus the next recommended step.
class SyllabusTree {
  const SyllabusTree({required this.subject, this.next});

  final SyllabusTreeNode subject;

  /// Next recommended section (or topic/unit without an outline).
  final ({String id, String name, TreeSectionRef? ref})? next;

  factory SyllabusTree.fromJson(Map<String, dynamic> j) {
    final exam = SyllabusTreeNode.fromJson(j);
    final n = j['next'];
    return SyllabusTree(
      subject: exam.children.isNotEmpty
          ? exam.children.first
          : SyllabusTreeNode(
              id: exam.id,
              type: TreeNodeType.subject,
              name: exam.name,
            ),
      next: n is Map<String, dynamic>
          ? (
              id: n['id'] as String,
              name: n['name'] as String? ?? '',
              ref: n['unitId'] is String
                  ? (
                      unitId: n['unitId'] as String,
                      chapterId: n['chapterId'] as String,
                      sectionId: n['sectionId'] as String,
                    )
                  : null,
            )
          : null,
    );
  }
}

/// A topic to revise, from the student's practice results.
class ReviseTopic {
  const ReviseTopic({
    required this.topicId,
    required this.name,
    required this.accuracy,
    required this.attempted,
    required this.studied,
  });

  final String topicId;
  final String name;

  /// 0..1 in practice.
  final double accuracy;
  final int attempted;

  /// True when the notes were studied but practice is still weak.
  final bool studied;

  factory ReviseTopic.fromJson(Map<String, dynamic> j) => ReviseTopic(
    topicId: j['topicId'] as String,
    name: j['name'] as String? ?? '',
    accuracy: (j['accuracy'] as num? ?? 0).toDouble(),
    attempted: (j['attempted'] as num? ?? 0).toInt(),
    studied: j['action'] == 'revise_notes',
  );
}

/// `GET /learning/recommendations/:examId` — progress + what to do next.
class LearningRecommendations {
  const LearningRecommendations({
    this.items = 0,
    this.itemsCompleted = 0,
    this.continueSections = const [],
    this.revise = const [],
  });

  /// Path items (topics / units) of the subject and how many are completed.
  final int items;
  final int itemsCompleted;

  /// Sections opened but not finished.
  final List<({String name, TreeSectionRef ref})> continueSections;
  final List<ReviseTopic> revise;

  factory LearningRecommendations.fromJson(Map<String, dynamic> j) {
    final subjects = j['subjects'] as List<dynamic>? ?? const [];
    final s = subjects.isEmpty
        ? const <String, dynamic>{}
        : subjects.first as Map<String, dynamic>;
    return LearningRecommendations(
      items: (s['items'] as num? ?? 0).toInt(),
      itemsCompleted: (s['itemsCompleted'] as num? ?? 0).toInt(),
      continueSections: [
        for (final c in j['continue'] as List<dynamic>? ?? const [])
          if (c is Map<String, dynamic> && c['unitId'] is String)
            (
              name: c['name'] as String? ?? '',
              ref: (
                unitId: c['unitId'] as String,
                chapterId: c['chapterId'] as String,
                sectionId: c['sectionId'] as String,
              ),
            ),
      ],
      revise: [
        for (final r in j['revise'] as List<dynamic>? ?? const [])
          ReviseTopic.fromJson(r as Map<String, dynamic>),
      ],
    );
  }
}
