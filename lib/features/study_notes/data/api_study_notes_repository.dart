import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../library/domain/library_models.dart' show LibraryFacets;
import '../domain/learning_path.dart';
import '../domain/notes_library.dart';
import '../domain/study_note.dart';

/// Backend notes: Gemini generation, validation and MongoDB saving all happen
/// on the server; the AI key never reaches the app.
class ApiStudyNotesRepository implements StudyNotesRepository {
  ApiStudyNotesRepository(this._api);

  final ApiClient _api;

  /// One idempotency key per request object, so retrying after a timeout
  /// returns the note already saved instead of creating a duplicate.
  static final _requestKeys = Expando<String>('notesRequestKey');
  static final _rng = Random.secure();

  static String _newKey() =>
      'n-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
      '${List.generate(4, (_) => _rng.nextInt(1 << 32).toRadixString(36)).join()}';

  @override
  Future<StudyNote> generate(NotesRequest request) async {
    final key = _requestKeys[request] ??= _newKey();
    final body = await _api.post('/notes/generate', {
      ...request.toJson(),
      'requestKey': key,
    }, kGenerateTimeout);
    return StudyNote.fromJson(body);
  }

  static String _path(String p, Map<String, String> q) =>
      Uri(path: p, queryParameters: q).toString();

  @override
  Future<NotesPage> list(
    String category,
    NotesFilter filter, {
    int page = 1,
  }) async => NotesPage.fromJson(
    await _api.get(
      _path('/notes', {
        'category': category,
        ...filter.toQuery(),
        'page': '$page',
      }),
    ),
  );

  @override
  Future<LibraryFacets> facets(String category) async => LibraryFacets.fromJson(
    await _api.get(_path('/notes/facets', {'category': category})),
  );

  @override
  Future<NotesSummary> summary() async =>
      NotesSummary.fromJson(await _api.get('/notes/summary'));

  @override
  Future<StudyNote> update(
    String id, {
    bool? bookmarked,
    String? personalNote,
  }) async => StudyNote.fromJson(
    await _api.patch('/notes/${Uri.encodeComponent(id)}', {
      'bookmarked': ?bookmarked,
      'personalNote': ?personalNote,
    }),
  );

  @override
  Future<LearningPath> learningPath(String examId, String subjectId) async =>
      LearningPath.fromJson(
        await _api.get(
          '/learning-path/${Uri.encodeComponent(examId)}/'
          '${Uri.encodeComponent(subjectId)}',
        ),
      );

  @override
  Future<LearningPath> setCompleted(
    String examId,
    String itemId, {
    required bool completed,
  }) async => LearningPath.fromJson(
    await _api.put(
      '/learning-path/${Uri.encodeComponent(examId)}/items/'
      '${Uri.encodeComponent(itemId)}',
      {'completed': completed},
    ),
  );

  @override
  Future<void> delete(String id) =>
      _api.delete('/notes/${Uri.encodeComponent(id)}');

  @override
  Future<StudyNote> fetch(String id) async =>
      StudyNote.fromJson(await _api.get('/notes/${Uri.encodeComponent(id)}'));
}
