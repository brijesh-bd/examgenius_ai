import 'package:flutter/foundation.dart';

/// Exam-specific hierarchical syllabus of one subject (backend
/// `GET /syllabus/:examId/:subjectId/tree`): chapter → topic → subtopic →
/// micro-concept. The same node ids drive Create Practice
/// (`selectedNodeIds`) and AI Study Notes (`nodeId`). Any subject can have
/// one; subjects without a tree keep their flat topic chips.

/// Railway "Mathematics" subject id.
const kMathSubjectId = 'quant';

/// Subject of a hierarchy node id, from its prefix (`rr.analogy` → reasoning).
const kConceptPrefixes = {
  'rm': 'quant',
  'rr': 'reasoning',
  'ga': 'general_awareness',
  'gs': 'general_science',
  // RRB Station Master (CEN 08/2026 sections).
  'smb': 'sm_science_math',
  'sml': 'sm_logical',
  'smr': 'sm_mental',
  // SSC (official SSC notices).
  'sq': 'quant',
  'sr': 'reasoning',
  'en': 'english',
  'ck': 'computer',
  'st': 'statistics',
  'fe': 'finance_economics',
  'jc': 'je_civil',
  'jl': 'je_electrical',
  'jm': 'je_mechanical',
};

String? conceptSubjectOf(String id) {
  final dot = id.indexOf('.');
  return dot < 0 ? null : kConceptPrefixes[id.substring(0, dot)];
}

/// True for ids of a hierarchical syllabus (as opposed to legacy topic ids).
bool isConceptNode(String id) => conceptSubjectOf(id) != null;

/// Verification of a node for the selected exam.
enum NodeStatus {
  official,
  supplementary,
  unverified,
  draft;

  static NodeStatus fromJson(String? v) =>
      values.firstWhere((s) => s.name == v, orElse: () => NodeStatus.draft);
}

enum ConceptNodeType {
  chapter,
  topic,
  subtopic,
  concept;

  static ConceptNodeType fromJson(String? v) => values.firstWhere(
    (t) => t.name == v,
    orElse: () => ConceptNodeType.concept,
  );
}

@immutable
class ConceptNode {
  const ConceptNode({
    required this.id,
    required this.parentId,
    required this.type,
    required this.titleEn,
    required this.titleHi,
    this.patterns = const [],
    this.children = const [],
    this.status = NodeStatus.draft,
  });

  factory ConceptNode.fromJson(Map<String, dynamic> j) => ConceptNode(
    id: j['nodeId'] as String,
    parentId: j['parentId'] as String? ?? '',
    type: ConceptNodeType.fromJson(j['nodeType'] as String?),
    titleEn: j['titleEn'] as String? ?? '',
    titleHi: j['titleHi'] as String? ?? (j['titleEn'] as String? ?? ''),
    patterns: [
      for (final p in j['questionPatterns'] as List<dynamic>? ?? const [])
        p as String,
    ],
    children: [
      for (final c in j['children'] as List<dynamic>? ?? const [])
        ConceptNode.fromJson(c as Map<String, dynamic>),
    ],
    status: NodeStatus.fromJson(j['status'] as String?),
  );

  final String id;
  final String parentId;
  final ConceptNodeType type;
  final String titleEn;
  final String titleHi;
  final List<String> patterns;
  final List<ConceptNode> children;
  final NodeStatus status;

  bool get isLeaf => children.isEmpty;

  /// Hindi title when the app language is Hindi (falls back to English).
  String title(String languageCode) =>
      languageCode == 'hi' && titleHi.isNotEmpty ? titleHi : titleEn;
}

enum SelectionState { none, partial, all }

/// One exam's hierarchy with fast lookups. Immutable.
class ConceptHierarchy {
  ConceptHierarchy({
    required this.examId,
    required this.chapters,
    this.subjectId = kMathSubjectId,
    this.hasOfficial = false,
  }) {
    void index(ConceptNode n, String? parent) {
      _byId[n.id] = n;
      _parent[n.id] = parent;
      for (final c in n.children) {
        index(c, n.id);
      }
    }

    for (final c in chapters) {
      index(c, null);
    }
  }

  factory ConceptHierarchy.fromJson(Map<String, dynamic> j) => ConceptHierarchy(
    examId: j['examId'] as String,
    subjectId: j['subjectId'] as String? ?? kMathSubjectId,
    hasOfficial: j['hasOfficial'] as bool? ?? false,
    chapters: [
      for (final n in j['nodes'] as List<dynamic>? ?? const [])
        ConceptNode.fromJson(n as Map<String, dynamic>),
    ],
  );

  final String examId;
  final String subjectId;

  /// False while no node is confirmed by an official notification.
  final bool hasOfficial;
  final List<ConceptNode> chapters;
  final _byId = <String, ConceptNode>{};
  final _parent = <String, String?>{};

  ConceptNode? node(String id) => _byId[id];
  bool contains(String id) => _byId.containsKey(id);

  /// Ancestors from the chapter down to [id] (inclusive).
  List<ConceptNode> pathOf(String id) {
    final out = <ConceptNode>[];
    for (String? cur = id; cur != null; cur = _parent[cur]) {
      final n = _byId[cur];
      if (n == null) break;
      out.insert(0, n);
    }
    return out;
  }

  /// Concept (leaf) ids under [id], in display order.
  List<String> leavesOf(String id) {
    final n = _byId[id];
    if (n == null) return const [];
    if (n.isLeaf) return [n.id];
    return [for (final c in n.children) ...leavesOf(c.id)];
  }

  int get conceptCount => [for (final c in chapters) ...leavesOf(c.id)].length;

  // ── Selection ─────────────────────────────────────────────────────────────
  // A selection is stored NORMALISED: only the highest fully-selected nodes
  // (a fully selected parent replaces its descendants), so it never contains
  // duplicate or overlapping ids.

  /// Concepts covered by a selection (no duplicates).
  Set<String> conceptsOf(Set<String> selection) => {
    for (final id in selection) ...leavesOf(id),
  };

  SelectionState stateOf(String id, Set<String> selection) {
    if (pathOf(id).any((n) => selection.contains(n.id))) {
      return SelectionState.all;
    }
    final leaves = leavesOf(id);
    final covered = conceptsOf(selection);
    final hit = leaves.where(covered.contains).length;
    if (hit == 0) return SelectionState.none;
    return hit == leaves.length ? SelectionState.all : SelectionState.partial;
  }

  /// Selects or clears [id] (and everything under it).
  Set<String> toggle(String id, Set<String> selection) {
    if (!contains(id)) return normalise(selection);
    final concepts = conceptsOf(selection);
    final mine = leavesOf(id);
    if (stateOf(id, selection) == SelectionState.all) {
      concepts.removeAll(mine);
    } else {
      concepts.addAll(mine);
    }
    return fromConcepts(concepts);
  }

  /// Drops unknown ids and collapses to the normalised form.
  Set<String> normalise(Set<String> selection) =>
      fromConcepts(conceptsOf({...selection.where(contains)}));

  /// Smallest set of nodes that covers exactly [concepts].
  Set<String> fromConcepts(Set<String> concepts) {
    final out = <String>{};
    void walk(ConceptNode n) {
      final leaves = leavesOf(n.id);
      if (leaves.every(concepts.contains)) {
        out.add(n.id);
      } else if (leaves.any(concepts.contains)) {
        for (final c in n.children) {
          walk(c);
        }
      }
    }

    for (final c in chapters) {
      walk(c);
    }
    return out;
  }

  /// Selected ids in syllabus order (stable request bodies).
  List<String> ordered(Set<String> selection) {
    final out = <String>[];
    void walk(ConceptNode n) {
      if (selection.contains(n.id)) {
        out.add(n.id);
        return;
      }
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final c in chapters) {
      walk(c);
    }
    return out;
  }

  // ── Search ────────────────────────────────────────────────────────────────

  /// Ids to show for [query] (English or Hindi, case-insensitive): matching
  /// nodes, their ancestors (for context) and their descendants. Null when
  /// the query is empty (= show everything).
  Set<String>? visibleFor(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;
    final out = <String>{};
    void addAll(ConceptNode n) {
      out.add(n.id);
      for (final c in n.children) {
        addAll(c);
      }
    }

    for (final n in _byId.values) {
      if (n.titleEn.toLowerCase().contains(q) || n.titleHi.contains(q)) {
        out.addAll(pathOf(n.id).map((p) => p.id));
        addAll(n);
      }
    }
    return out;
  }
}
