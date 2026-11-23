import 'package:flutter/foundation.dart';

import '../../library/domain/library_models.dart';
import 'study_note.dart';

/// My Study Notes in the Library: filters, pages and per-category counts.
/// Filter options reuse [LibraryFacets] (same JSON shape on the backend).

/// Tabs inside one category's notes.
enum NotesView { all, bookmarked, personal }

@immutable
class NotesFilter {
  const NotesFilter({
    this.examId,
    this.subjectId,
    this.topicId,
    this.language,
    this.level,
    this.from,
    this.to,
    this.query = '',
    this.sort = LibrarySort.latest,
    this.view = NotesView.all,
  });

  final NotesView view;

  final String? examId;
  final String? subjectId;
  final String? topicId;
  final String? language;
  final NoteLevel? level;
  final DateTime? from;
  final DateTime? to;
  final String query;
  final LibrarySort sort;

  bool get isActive =>
      examId != null ||
      subjectId != null ||
      topicId != null ||
      language != null ||
      level != null ||
      from != null ||
      to != null ||
      query.trim().isNotEmpty;

  /// Nullable fields take a `ValueGetter` so they can be cleared (`() => null`).
  NotesFilter copyWith({
    ValueGetter<String?>? examId,
    ValueGetter<String?>? subjectId,
    ValueGetter<String?>? topicId,
    ValueGetter<String?>? language,
    ValueGetter<NoteLevel?>? level,
    ValueGetter<DateTime?>? from,
    ValueGetter<DateTime?>? to,
    String? query,
    LibrarySort? sort,
    NotesView? view,
  }) => NotesFilter(
    examId: examId == null ? this.examId : examId(),
    subjectId: subjectId == null ? this.subjectId : subjectId(),
    topicId: topicId == null ? this.topicId : topicId(),
    language: language == null ? this.language : language(),
    level: level == null ? this.level : level(),
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    query: query ?? this.query,
    sort: sort ?? this.sort,
    view: view ?? this.view,
  );

  Map<String, String> toQuery() => {
    'examId': ?examId,
    'subjectId': ?subjectId,
    'topicId': ?topicId,
    'language': ?language,
    if (level != null) 'level': level!.wire,
    if (from != null) 'from': from!.toUtc().toIso8601String(),
    if (to != null) 'to': to!.toUtc().toIso8601String(),
    if (query.trim().isNotEmpty) 'q': query.trim(),
    'sort': sort.name,
    if (view == NotesView.bookmarked) 'bookmarked': 'true',
    if (view == NotesView.personal) 'hasPersonalNote': 'true',
  };

  /// Same rules as the backend; used by the mock repository.
  bool matches(StudyNote n) {
    final q = query.trim().toLowerCase();
    return (view != NotesView.bookmarked || n.bookmarked) &&
        (view != NotesView.personal || n.personalNote.trim().isNotEmpty) &&
        (examId == null || n.examId == examId) &&
        (subjectId == null || n.subjectId == subjectId) &&
        (topicId == null || n.topicId == topicId) &&
        (language == null || n.language == language) &&
        (level == null || n.level == level) &&
        (from == null || !n.createdAt.isBefore(from!)) &&
        (to == null || !n.createdAt.isAfter(to!)) &&
        (q.isEmpty ||
            [
              n.topicName,
              n.subjectName,
              n.examName,
              n.personalNote,
            ].any((s) => s.toLowerCase().contains(q)));
  }
}

class NotesPage {
  const NotesPage({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  final List<StudyNote> items;
  final int total;
  final int page;
  final bool hasMore;

  factory NotesPage.fromJson(Map<String, dynamic> j) => NotesPage(
    items: [
      for (final n in j['items'] as List<dynamic>)
        StudyNote.fromJson(n as Map<String, dynamic>),
    ],
    total: (j['total'] as num).toInt(),
    page: (j['page'] as num).toInt(),
    hasMore: j['hasMore'] == true,
  );
}

class NotesSummary {
  const NotesSummary({this.total = 0, this.byCategory = const {}});

  final int total;
  final Map<String, int> byCategory;

  int countFor(String category) => byCategory[category] ?? 0;

  factory NotesSummary.fromJson(Map<String, dynamic> j) => NotesSummary(
    total: (j['total'] as num? ?? 0).toInt(),
    byCategory: {
      for (final c
          in (j['categories'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>())
        c['category'] as String: (c['notes'] as num).toInt(),
    },
  );
}
