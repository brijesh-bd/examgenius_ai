/// AI Study Notes — matches the backend contract (`/api/v1/notes…`).
library;

import '../../library/domain/library_models.dart' show LibraryFacets;
import 'learning_path.dart';
import 'notes_library.dart';

/// How deep the explanation goes. Wire values: basic / exam / advanced.
enum NoteLevel {
  basic('basic'),
  examStandard('exam'),
  advanced('advanced');

  const NoteLevel(this.wire);
  final String wire;

  static NoteLevel fromWire(String? v) =>
      values.firstWhere((l) => l.wire == v, orElse: () => examStandard);
}

/// Sections the student can switch on or off before generating.
enum NoteSection {
  explanation('explanation', true),
  definitions('definitions', true),
  examples('examples', true),
  stepByStep('stepByStep', true),
  diagrams('diagrams', true),
  graphs('graphs', false),
  formulas('formulas', true),
  tips('tips', true),
  mistakes('mistakes', true),
  keyPoints('keyPoints', true),
  revision('revision', true),
  mcqs('mcqs', true);

  const NoteSection(this.wire, this.onByDefault);
  final String wire;
  final bool onByDefault;

  static Set<NoteSection> get defaults =>
      values.where((s) => s.onByDefault).toSet();
}

/// What the student asked for on the Create Notes screen.
class NotesRequest {
  const NotesRequest({
    required this.examId,
    required this.topicId,
    required this.language,
    required this.level,
    required this.sections,
  });

  final String examId;
  final String topicId;
  final String language;
  final NoteLevel level;
  final Set<NoteSection> sections;

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'topicId': topicId,
    'language': language,
    'level': level.wire,
    'sections': [
      for (final s in NoteSection.values)
        if (sections.contains(s)) s.wire,
    ],
  };
}

// ── Content (contentVersion 1) ──────────────────────────────────────────────

List<T> _list<T>(Object? v, T Function(Map<String, dynamic>) f) =>
    (v as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(f)
        .toList();

List<String> _strings(Object? v) =>
    (v as List<dynamic>? ?? const []).map((e) => '$e').toList();

String _s(Object? v) => v is String ? v : '';

class NoteParagraph {
  const NoteParagraph(this.heading, this.body);
  final String heading;
  final String body;
}

class NoteConcept {
  const NoteConcept(this.term, this.definition);
  final String term;
  final String definition;
}

class NoteExample {
  const NoteExample({
    required this.title,
    required this.problem,
    required this.steps,
    required this.answer,
  });
  final String title;
  final String problem;
  final List<String> steps;
  final String answer;
}

class NoteFlowchart {
  const NoteFlowchart(this.title, this.steps);
  final String title;
  final List<String> steps;
}

class NotePoint {
  const NotePoint(this.x, this.y);
  final double x;
  final double y;
}

class NoteGraph {
  const NoteGraph({
    required this.title,
    required this.xLabel,
    required this.yLabel,
    required this.points,
    required this.caption,
  });
  final String title;
  final String xLabel;
  final String yLabel;
  final List<NotePoint> points;
  final String caption;
}

class NoteFormula {
  const NoteFormula(this.name, this.expression, this.meaning);
  final String name;
  final String expression;
  final String meaning;
}

class NoteTable {
  const NoteTable(this.title, this.headers, this.rows);
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
}

class NoteCode {
  const NoteCode(this.language, this.code, this.caption);
  final String language;
  final String code;
  final String caption;
}

/// A practice MCQ inside study notes. The answer is part of the notes, but
/// the screen keeps it hidden until the student taps "Show answer".
class NoteMcq {
  const NoteMcq({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// A "What to Study Next" entry. [id] is a real syllabus topic/unit id
/// (set by the server); older notes have a name only and are not tappable.
class NoteNextTopic {
  const NoteNextTopic(this.name, {this.id});
  final String? id;
  final String name;

  static NoteNextTopic? fromJson(Object? v) => switch (v) {
    String s when s.trim().isNotEmpty => NoteNextTopic(s),
    {'name': final String name} when name.trim().isNotEmpty => NoteNextTopic(
      name,
      id: (v as Map)['id'] as String?,
    ),
    _ => null,
  };
}

/// Dated event (history / GK timelines).
class NoteTimelineEvent {
  const NoteTimelineEvent(this.period, this.event);
  final String period;
  final String event;
}

/// SQL query with sample input and its exact expected output.
class NoteSql {
  const NoteSql({
    required this.query,
    this.input = '',
    this.headers = const [],
    this.rows = const [],
    this.explanation = '',
  });
  final String query;
  final String input;
  final List<String> headers;
  final List<List<String>> rows;
  final String explanation;
}

class NoteDerivation {
  const NoteDerivation(this.formula, this.steps);
  final String formula;
  final List<String> steps;
}

/// Practice exercise (English and similar) with its answer.
class NotePractice {
  const NotePractice(this.question, this.answer);
  final String question;
  final String answer;
}

class NoteContent {
  const NoteContent({
    required this.overview,
    this.explanation = const [],
    this.concepts = const [],
    this.examples = const [],
    this.flowcharts = const [],
    this.graphs = const [],
    this.formulas = const [],
    this.tables = const [],
    this.codeExamples = const [],
    this.tips = const [],
    this.mistakes = const [],
    this.keyPoints = const [],
    this.quickRevision = const [],
    this.mcqs = const [],
    this.nextTopics = const [],
    this.objectives = const [],
    this.timeline = const [],
    this.keyFacts = const [],
    this.relatedConcepts = const [],
    this.furtherLearning = const [],
    this.sqlExamples = const [],
    this.derivations = const [],
    this.practice = const [],
  });

  final String overview;

  // Section notes (schema v2); empty for older notes.
  final List<String> objectives;
  final List<NoteTimelineEvent> timeline;
  final List<String> keyFacts;
  final List<String> relatedConcepts;
  final List<String> furtherLearning;
  final List<NoteSql> sqlExamples;
  final List<NoteDerivation> derivations;
  final List<NotePractice> practice;
  final List<NoteParagraph> explanation;
  final List<NoteConcept> concepts;
  final List<NoteExample> examples;
  final List<NoteFlowchart> flowcharts;
  final List<NoteGraph> graphs;
  final List<NoteFormula> formulas;
  final List<NoteTable> tables;
  final List<NoteCode> codeExamples;
  final List<String> tips;
  final List<String> mistakes;
  final List<String> keyPoints;
  final List<String> quickRevision;
  final List<NoteMcq> mcqs;
  final List<NoteNextTopic> nextTopics;

  factory NoteContent.fromJson(Map<String, dynamic> j) => NoteContent(
    overview: _s(j['overview']),
    explanation: _list(
      j['explanation'],
      (m) => NoteParagraph(_s(m['heading']), _s(m['body'])),
    ),
    concepts: _list(
      j['concepts'],
      (m) => NoteConcept(_s(m['term']), _s(m['definition'])),
    ),
    examples: _list(
      j['examples'],
      (m) => NoteExample(
        title: _s(m['title']),
        problem: _s(m['problem']),
        steps: _strings(m['steps']),
        answer: _s(m['answer']),
      ),
    ),
    flowcharts: _list(
      j['flowcharts'],
      (m) => NoteFlowchart(_s(m['title']), _strings(m['steps'])),
    ),
    graphs: _list(
      j['graphs'],
      (m) => NoteGraph(
        title: _s(m['title']),
        xLabel: _s(m['xLabel']),
        yLabel: _s(m['yLabel']),
        points: _list(
          m['points'],
          (p) => NotePoint(
            (p['x'] as num? ?? 0).toDouble(),
            (p['y'] as num? ?? 0).toDouble(),
          ),
        ),
        caption: _s(m['caption']),
      ),
    ),
    formulas: _list(
      j['formulas'],
      (m) => NoteFormula(_s(m['name']), _s(m['expression']), _s(m['meaning'])),
    ),
    tables: _list(
      j['tables'],
      (m) => NoteTable(
        _s(m['title']),
        _strings(m['headers']),
        (m['rows'] as List<dynamic>? ?? const []).map(_strings).toList(),
      ),
    ),
    codeExamples: _list(
      j['codeExamples'],
      (m) => NoteCode(_s(m['language']), _s(m['code']), _s(m['caption'])),
    ),
    tips: _strings(j['tips']),
    mistakes: _strings(j['mistakes']),
    keyPoints: _strings(j['keyPoints']),
    quickRevision: _strings(j['quickRevision']),
    mcqs: _list(
      j['mcqs'],
      (m) => NoteMcq(
        question: _s(m['question']),
        options: _strings(m['options']),
        correctIndex: (m['correctIndex'] as num? ?? 0).toInt(),
        explanation: _s(m['explanation']),
      ),
    ),
    nextTopics: [
      for (final v in j['nextTopics'] as List<dynamic>? ?? const [])
        ?NoteNextTopic.fromJson(v),
    ],
    objectives: _strings(j['objectives']),
    timeline: _list(
      j['timeline'],
      (m) => NoteTimelineEvent(_s(m['period']), _s(m['event'])),
    ),
    keyFacts: _strings(j['keyFacts']),
    relatedConcepts: _strings(j['relatedConcepts']),
    furtherLearning: _strings(j['furtherLearning']),
    sqlExamples: _list(j['sqlExamples'], (m) {
      final out = m['output'] is Map<String, dynamic>
          ? m['output'] as Map<String, dynamic>
          : const <String, dynamic>{};
      return NoteSql(
        query: _s(m['query']),
        input: _s(m['input']),
        headers: _strings(out['headers']),
        rows: (out['rows'] as List<dynamic>? ?? const [])
            .map(_strings)
            .toList(),
        explanation: _s(m['explanation']),
      );
    }),
    derivations: _list(
      j['derivations'],
      (m) => NoteDerivation(_s(m['formula']), _strings(m['steps'])),
    ),
    practice: _list(
      j['practice'],
      (m) => NotePractice(_s(m['question']), _s(m['answer'])),
    ),
  );
}

/// A saved note. [content] is null in list results (the list omits it).
class StudyNote {
  const StudyNote({
    required this.id,
    required this.category,
    required this.examId,
    required this.examName,
    required this.subjectId,
    required this.subjectName,
    required this.topicId,
    required this.topicName,
    required this.language,
    required this.level,
    required this.createdAt,
    this.content,
    this.model,
    this.contentVersion = 1,
    this.bookmarked = false,
    this.personalNote = '',
    this.parentTopicId,
    this.parentTopicName,
    this.unitName,
  });

  /// Set when the note is for one unit of a broad topic.
  final String? parentTopicId;
  final String? parentTopicName;
  final String? unitName;

  final String id;
  final String category;
  final String examId;
  final String examName;
  final String subjectId;
  final String subjectName;
  final String topicId;
  final String topicName;
  final String language;
  final NoteLevel level;
  final DateTime createdAt;
  final NoteContent? content;
  final String? model;
  final int contentVersion;
  final bool bookmarked;
  final String personalNote;

  /// Only the student's own fields change after creation.
  StudyNote copyWith({bool? bookmarked, String? personalNote}) => StudyNote(
    id: id,
    category: category,
    examId: examId,
    examName: examName,
    subjectId: subjectId,
    subjectName: subjectName,
    topicId: topicId,
    topicName: topicName,
    language: language,
    level: level,
    createdAt: createdAt,
    content: content,
    model: model,
    contentVersion: contentVersion,
    bookmarked: bookmarked ?? this.bookmarked,
    personalNote: personalNote ?? this.personalNote,
    parentTopicId: parentTopicId,
    parentTopicName: parentTopicName,
    unitName: unitName,
  );

  factory StudyNote.fromJson(Map<String, dynamic> j) => StudyNote(
    id: j['id'] as String,
    category: j['category'] as String,
    examId: j['examId'] as String,
    examName: _s(j['examName']),
    subjectId: _s(j['subjectId']),
    subjectName: _s(j['subjectName']),
    topicId: j['topicId'] as String,
    topicName: _s(j['topicName']),
    language: _s(j['language']),
    level: NoteLevel.fromWire(j['explanationLevel'] as String?),
    createdAt:
        DateTime.tryParse(_s(j['createdAt']))?.toLocal() ?? DateTime.now(),
    content: j['content'] is Map<String, dynamic>
        ? NoteContent.fromJson(j['content'] as Map<String, dynamic>)
        : null,
    model: j['generationModel'] as String?,
    contentVersion: (j['contentVersion'] as num? ?? 1).toInt(),
    bookmarked: j['bookmarked'] == true,
    personalNote: _s(j['personalNote']),
    parentTopicId: j['parentTopicId'] as String?,
    parentTopicName: j['parentTopicName'] as String?,
    unitName: j['unitName'] as String?,
  );
}

abstract interface class StudyNotesRepository {
  /// Generates and saves a note. Completes only after the server stored it.
  Future<StudyNote> generate(NotesRequest request);

  Future<StudyNote> fetch(String id);

  /// One page of a category's notes (list items carry no content).
  Future<NotesPage> list(String category, NotesFilter filter, {int page = 1});

  /// Exams / subjects / topics present in a category's notes.
  Future<LibraryFacets> facets(String category);

  /// Note counts per category.
  Future<NotesSummary> summary();

  /// Changes bookmark / personal note; returns the note as the server saved it.
  Future<StudyNote> update(String id, {bool? bookmarked, String? personalNote});

  /// Completes only after the server deleted the note.
  Future<void> delete(String id);

  /// Ordered topics/units of one subject with this student's progress.
  Future<LearningPath> learningPath(String examId, String subjectId);

  /// Marks a path item completed or not; returns the updated path.
  Future<LearningPath> setCompleted(
    String examId,
    String itemId, {
    required bool completed,
  });
}
