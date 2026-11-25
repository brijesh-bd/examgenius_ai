import '../../../core/network/api_client.dart';
import '../domain/concept_hierarchy.dart';

/// Hierarchical syllabus of one exam's subject; `null` when that subject has
/// no tree for the exam (it keeps flat topic chips).
abstract interface class ConceptHierarchyRepository {
  Future<ConceptHierarchy?> fetchTree(String examId, String subjectId);
}

/// `GET /api/v1/syllabus/:examId/:subjectId/tree` (404 = no tree).
class ApiConceptHierarchyRepository implements ConceptHierarchyRepository {
  ApiConceptHierarchyRepository(this._api);

  final ApiClient _api;

  @override
  Future<ConceptHierarchy?> fetchTree(String examId, String subjectId) async {
    try {
      return ConceptHierarchy.fromJson(
        await _api.get(
          '/syllabus/${Uri.encodeComponent(examId)}/'
          '${Uri.encodeComponent(subjectId)}/tree',
        ),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}

/// Offline / test data: a small slice of the real hierarchy (same ids).
class MockConceptHierarchyRepository implements ConceptHierarchyRepository {
  MockConceptHierarchyRepository({this.fail = false});

  bool fail;

  static const railwayExams = {
    'rrb_ntpc',
    'rrb_group_d',
    'rrb_alp',
    'rrb_je',
    'rrb_tech_gr1_signal',
    'rrb_tech_gr3',
  };

  @override
  Future<ConceptHierarchy?> fetchTree(String examId, String subjectId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (fail) throw const ApiException('offline');
    if (examId == 'ssc_cgl' && subjectId == 'reasoning') return _sscReasoning();
    if (!railwayExams.contains(examId)) return null;
    if (subjectId == 'reasoning') return _reasoning(examId);
    if (subjectId != kMathSubjectId) return null;
    ConceptNode n(
      String id,
      String type,
      String en,
      String hi, [
      List<ConceptNode> children = const [],
    ]) => ConceptNode(
      id: id,
      parentId: id.substring(0, id.lastIndexOf('.')),
      type: ConceptNodeType.fromJson(type),
      titleEn: en,
      titleHi: hi,
      patterns: children.isEmpty ? const ['Find the missing digit'] : const [],
      children: children,
    );
    const rules = 'rm.number_system.divisibility.rules';
    return ConceptHierarchy(
      examId: examId,
      chapters: [
        n('rm.number_system', 'chapter', 'Number System', 'संख्या पद्धति', [
          n(
            'rm.number_system.divisibility',
            'topic',
            'Divisibility',
            'विभाज्यता',
            [
              n(rules, 'subtopic', 'Divisibility Rules', 'विभाज्यता के नियम', [
                n(
                  '$rules.by_2',
                  'concept',
                  'Divisibility by 2',
                  '2 से विभाज्यता',
                ),
                n(
                  '$rules.by_3',
                  'concept',
                  'Divisibility by 3',
                  '3 से विभाज्यता',
                ),
                n(
                  '$rules.by_11',
                  'concept',
                  'Divisibility by 11',
                  '11 से विभाज्यता',
                ),
              ]),
            ],
          ),
          n(
            'rm.number_system.unit_digit',
            'topic',
            'Unit Digit and Cyclicity',
            'इकाई अंक और चक्रीयता',
            [
              n(
                'rm.number_system.unit_digit.unit_digit',
                'subtopic',
                'Unit Digit',
                'इकाई अंक',
                [
                  n(
                    'rm.number_system.unit_digit.unit_digit.cyclicity',
                    'concept',
                    'Cyclicity of Digits',
                    'अंकों की चक्रीयता',
                  ),
                ],
              ),
            ],
          ),
        ]),
        n('rm.percentage', 'chapter', 'Percentage', 'प्रतिशत', [
          n(
            'rm.percentage.change',
            'topic',
            'Percentage Change',
            'प्रतिशत परिवर्तन',
            [
              n(
                'rm.percentage.change.increase_decrease',
                'subtopic',
                'Increase and Decrease',
                'वृद्धि और कमी',
                [
                  n(
                    'rm.percentage.change.increase_decrease.successive_change',
                    'concept',
                    'Successive Percentage Change',
                    'क्रमागत प्रतिशत परिवर्तन',
                  ),
                ],
              ),
            ],
          ),
        ]),
        n('rm.time_work', 'chapter', 'Time and Work', 'समय और कार्य', [
          n(
            'rm.time_work.combined',
            'topic',
            'Combined Work',
            'संयुक्त कार्य',
            [
              n(
                'rm.time_work.combined.together',
                'subtopic',
                'Working Together',
                'साथ मिलकर कार्य',
                [
                  n(
                    'rm.time_work.combined.together.working_together',
                    'concept',
                    'Working Together',
                    'साथ मिलकर कार्य',
                  ),
                ],
              ),
            ],
          ),
        ]),
        if (examId != 'rrb_ntpc')
          n(
            'rm.calendar_clock',
            'chapter',
            'Calendar and Clock',
            'कैलेंडर और घड़ी',
            [
              n('rm.calendar_clock.clock', 'topic', 'Clock', 'घड़ी', [
                n(
                  'rm.calendar_clock.clock.clock',
                  'subtopic',
                  'Hands of a Clock',
                  'घड़ी की सुइयाँ',
                  [
                    n(
                      'rm.calendar_clock.clock.clock.angle_between_hands',
                      'concept',
                      'Angle Between the Hands',
                      'सुइयों के बीच का कोण',
                    ),
                  ],
                ),
              ]),
            ],
          ),
      ],
    );
  }

  /// Reasoning slice: NTPC also has Maps & Graphs; others do not.
  ConceptHierarchy _reasoning(String examId) {
    ConceptNode n(
      String id,
      String type,
      String en,
      String hi, [
      List<ConceptNode> children = const [],
    ]) => ConceptNode(
      id: id,
      parentId: id.substring(0, id.lastIndexOf('.')),
      type: ConceptNodeType.fromJson(type),
      titleEn: en,
      titleHi: hi,
      status: type == 'chapter' ? NodeStatus.unverified : NodeStatus.draft,
      children: children,
    );
    return ConceptHierarchy(
      examId: examId,
      subjectId: 'reasoning',
      chapters: [
        n('rr.analogy', 'chapter', 'Analogy', 'सादृश्यता', [
          n(
            'rr.analogy.number',
            'topic',
            'Number Analogy',
            'संख्या सादृश्यता',
            [
              n('rr.analogy.number.powers', 'subtopic', 'Powers', 'घात', [
                n(
                  'rr.analogy.number.powers.square',
                  'concept',
                  'Square-based',
                  'वर्ग आधारित',
                ),
                n(
                  'rr.analogy.number.powers.cube',
                  'concept',
                  'Cube-based',
                  'घन आधारित',
                ),
              ]),
            ],
          ),
        ]),
        n('rr.number_series', 'chapter', 'Number Series', 'संख्या श्रृंखला', [
          n(
            'rr.number_series.task',
            'topic',
            'Question Type',
            'प्रश्न प्रकार',
            [
              n(
                'rr.number_series.task.missing_term',
                'concept',
                'Missing Term',
                'लुप्त पद',
              ),
              n(
                'rr.number_series.task.wrong_term',
                'concept',
                'Wrong Term',
                'गलत पद',
              ),
            ],
          ),
        ]),
        if (examId == 'rrb_ntpc')
          n(
            'rr.maps_graphs',
            'chapter',
            'Maps and Graph Interpretation',
            'मानचित्र और आलेख निर्वचन',
            [
              n(
                'rr.maps_graphs.maps',
                'topic',
                'Maps (described in text)',
                'मानचित्र (पाठ में वर्णित)',
              ),
            ],
          ),
      ],
    );
  }

  /// SSC CGL reasoning slice (official SSC wording; figure items are hidden).
  ConceptHierarchy _sscReasoning() {
    ConceptNode n(
      String id,
      String type,
      String en,
      String hi, [
      List<ConceptNode> children = const [],
    ]) => ConceptNode(
      id: id,
      parentId: id.contains('.') ? id.substring(0, id.lastIndexOf('.')) : 'sr',
      type: ConceptNodeType.fromJson(type),
      titleEn: en,
      titleHi: hi,
      status: type == 'chapter'
          ? NodeStatus.official
          : NodeStatus.supplementary,
      children: children,
    );
    return ConceptHierarchy(
      examId: 'ssc_cgl',
      subjectId: 'reasoning',
      hasOfficial: true,
      chapters: [
        n(
          'sr.semantic_analogy',
          'chapter',
          'Semantic Analogy',
          'शाब्दिक सादृश्यता',
        ),
        n('sr.number_series', 'chapter', 'Number Series', 'संख्या श्रृंखला', [
          n(
            'sr.number_series.question_type',
            'topic',
            'Question Type',
            'प्रश्न प्रकार',
            [
              n(
                'sr.number_series.question_type.missing_term',
                'concept',
                'Missing Term',
                'लुप्त पद',
              ),
            ],
          ),
        ]),
        n('sr.address_matching', 'chapter', 'Address Matching', 'पता मिलान'),
      ],
    );
  }
}
