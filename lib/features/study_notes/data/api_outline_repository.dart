import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../domain/note_outline.dart';
import '../domain/study_note.dart';

/// Curated outlines and section-by-section notes from the backend. Gemini,
/// quality checks, the shared cache and MongoDB saving all run on the server.
class ApiOutlineRepository implements OutlineRepository {
  ApiOutlineRepository(this._api);

  final ApiClient _api;
  static final _rng = Random.secure();

  /// One key per section until it succeeds, so retrying after a timeout
  /// returns the copy already saved instead of a duplicate.
  final Map<String, String> _pendingKeys = {};

  static String _seg(String s) => Uri.encodeComponent(s);

  @override
  Future<NoteOutline> outline(OutlineKey k) async => NoteOutline.fromJson(
    await _api.get(
      Uri(
        path: '/notes/outlines/${_seg(k.examId)}/${_seg(k.unitId)}',
        queryParameters: {'language': k.language, 'mode': k.mode.wire},
      ).toString(),
    ),
  );

  @override
  Future<ChapterIndexStatus> requestChapterIndex(
    String examId,
    String unitId,
  ) async {
    final r = await _api.post(
      '/notes/outlines/${_seg(examId)}/${_seg(unitId)}/index',
      const <String, Object>{},
    );
    return r['status'] == 'approved'
        ? ChapterIndexStatus.approved
        : ChapterIndexStatus.pendingReview;
  }

  Map<String, Object> _body(OutlineKey k, SectionRef s) => {
    'examId': k.examId,
    'unitId': k.unitId,
    'chapterId': s.chapterId,
    'sectionId': s.sectionId,
    'language': k.language,
    'mode': k.mode.wire,
  };

  @override
  Future<OpenedSection> openSection(OutlineKey k, SectionRef s) async {
    final id =
        '${k.examId}|${k.unitId}|${s.chapterId}|${s.sectionId}|'
        '${k.language}|${k.mode.wire}';
    final key = _pendingKeys[id] ??=
        's-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
        '${_rng.nextInt(1 << 32).toRadixString(36)}';
    final body = await _api.post('/notes/sections/generate', {
      ..._body(k, s),
      'requestKey': key,
    }, kGenerateTimeout);
    // 202: another server is preparing this section right now.
    if (body['status'] == 'generating' && body['id'] == null) {
      throw SectionGeneratingException(
        retryAfterSeconds: (body['retryAfterSeconds'] as num? ?? 10).toInt(),
      );
    }
    _pendingKeys.remove(id);
    return (
      note: StudyNote.fromJson(body),
      source: body['source'] as String? ?? 'saved',
      isSample: false,
      contentStatus: body['contentStatus'] as String?,
      review: body['review'] as String?,
      verification: body['verification'] as String?,
      coverageBasis: body['coverageBasis'] as String?,
    );
  }

  @override
  Future<LearningRecommendations> recommendations({
    required String examId,
    required String subjectId,
    required String language,
  }) async => LearningRecommendations.fromJson(
    await _api.get(
      Uri(
        path: '/learning/recommendations/${_seg(examId)}',
        queryParameters: {'subjectId': subjectId, 'language': language},
      ).toString(),
    ),
  );

  @override
  Future<SyllabusTree> tree({
    required String examId,
    required String subjectId,
    required String language,
    LearningMode mode = LearningMode.complete,
  }) async => SyllabusTree.fromJson(
    await _api.get(
      Uri(
        path: '/syllabus/tree/${_seg(examId)}',
        queryParameters: {
          'subjectId': subjectId,
          'language': language,
          'mode': mode.wire,
        },
      ).toString(),
    ),
  );

  @override
  Future<NoteOutline> setSectionCompleted(
    OutlineKey k,
    SectionRef s, {
    required bool completed,
  }) async => NoteOutline.fromJson(
    await _api.put('/notes/sections/progress', {
      ..._body(k, s),
      'completed': completed,
    }),
  );
}
