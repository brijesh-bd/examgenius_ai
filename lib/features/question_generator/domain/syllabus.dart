/// Exam syllabus served by the backend (`GET /api/v1/exams/:examId/syllabus`).
/// Topic ids are `<subjectId>.<slug>` so a topic always knows its subject.
class SyllabusTopic {
  const SyllabusTopic({required this.id, required this.name});

  final String id;
  final String name;

  String get subjectId => subjectIdOf(id);

  factory SyllabusTopic.fromJson(Map<String, dynamic> json) =>
      SyllabusTopic(id: json['id'] as String, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class SyllabusSubject {
  const SyllabusSubject({
    required this.id,
    required this.name,
    required this.topics,
  });

  final String id;
  final String name;
  final List<SyllabusTopic> topics;

  factory SyllabusSubject.fromJson(Map<String, dynamic> json) =>
      SyllabusSubject(
        id: json['id'] as String,
        name: json['name'] as String,
        topics: (json['topics'] as List<dynamic>)
            .map((t) => SyllabusTopic.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class Syllabus {
  const Syllabus({required this.examId, required this.subjects});

  final String examId;
  final List<SyllabusSubject> subjects;

  int get topicCount => subjects.fold(0, (n, s) => n + s.topics.length);

  /// Topic name for an id, or `null` if the id is not in this syllabus.
  String? topicName(String topicId) {
    for (final s in subjects) {
      for (final t in s.topics) {
        if (t.id == topicId) return t.name;
      }
    }
    return null;
  }

  factory Syllabus.fromJson(Map<String, dynamic> json) => Syllabus(
    examId: json['examId'] as String,
    subjects: (json['subjects'] as List<dynamic>)
        .map((s) => SyllabusSubject.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

String subjectIdOf(String topicId) {
  final i = topicId.indexOf('.');
  return i < 0 ? topicId : topicId.substring(0, i);
}
