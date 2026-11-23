/// Syllabus learning path of one subject (`GET /learning-path/:examId/:subjectId`).
/// Items are the subject's topics in syllabus order; broad topics are split
/// into curated units. Progress is the signed-in student's own.
library;

enum LearningStatus {
  completed,
  current,
  upcoming;

  static LearningStatus fromWire(String? v) =>
      values.firstWhere((s) => s.name == v, orElse: () => upcoming);
}

class LearningItem {
  const LearningItem({
    required this.id,
    required this.name,
    required this.topicId,
    required this.topicName,
    required this.order,
    required this.status,
    this.unitName,
    this.completedAt,
    this.latestNoteId,
    this.notesCount = 0,
  });

  /// Topic id, or `<topicId>.<unit>` for a unit of a broad topic.
  final String id;
  final String name;
  final String topicId;
  final String topicName;

  /// Set when this item is a unit of a broad topic.
  final String? unitName;
  final int order;
  final LearningStatus status;
  final DateTime? completedAt;

  /// Most recent saved note for this item, if any.
  final String? latestNoteId;
  final int notesCount;

  bool get isUnit => unitName != null;
  bool get hasNotes => latestNoteId != null;

  /// "Data Structures: Stacks & Queues" for units, the topic name otherwise.
  String get fullName => isUnit ? '$topicName: $unitName' : name;

  factory LearningItem.fromJson(Map<String, dynamic> j) => LearningItem(
    id: j['id'] as String,
    name: j['name'] as String,
    topicId: j['topicId'] as String,
    topicName: j['topicName'] as String,
    unitName: j['unitName'] as String?,
    order: (j['order'] as num).toInt(),
    status: LearningStatus.fromWire(j['status'] as String?),
    completedAt: DateTime.tryParse(j['completedAt'] as String? ?? ''),
    latestNoteId: j['latestNoteId'] as String?,
    notesCount: (j['notesCount'] as num? ?? 0).toInt(),
  );
}

class LearningPath {
  const LearningPath({
    required this.examId,
    required this.examName,
    required this.category,
    required this.subjectId,
    required this.subjectName,
    required this.items,
    this.currentId,
  });

  final String examId;
  final String examName;
  final String category;
  final String subjectId;
  final String subjectName;
  final List<LearningItem> items;

  /// First item not completed yet; null when everything is done.
  final String? currentId;

  int get total => items.length;
  int get completed =>
      items.where((i) => i.status == LearningStatus.completed).length;
  double get progress => total == 0 ? 0 : completed / total;

  LearningItem? item(String id) => items.where((i) => i.id == id).firstOrNull;

  /// The item that follows [id] in syllabus order. For a whole broad topic
  /// (whose units are on the path), the item after its last unit.
  LearningItem? nextAfter(String id) {
    var at = items.indexWhere((i) => i.id == id);
    if (at < 0) at = items.lastIndexWhere((i) => i.topicId == id);
    if (at < 0 || at + 1 >= items.length) return null;
    return items[at + 1];
  }

  factory LearningPath.fromJson(Map<String, dynamic> j) => LearningPath(
    examId: j['examId'] as String,
    examName: j['examName'] as String? ?? '',
    category: j['category'] as String? ?? '',
    subjectId: j['subjectId'] as String,
    subjectName: j['subjectName'] as String? ?? '',
    currentId: j['currentId'] as String?,
    items: [
      for (final i in j['items'] as List<dynamic>)
        LearningItem.fromJson(i as Map<String, dynamic>),
    ],
  );
}
