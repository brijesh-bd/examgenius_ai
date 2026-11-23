import '../../../core/network/api_client.dart';
import '../../practice_test/domain/practice_models.dart';
import '../../practice_test/domain/practice_result.dart';
import '../domain/library_models.dart';

/// `/api/v1/library/*` — every call is authenticated and scoped to the
/// signed-in student on the server.
class ApiLibraryRepository implements LibraryRepository {
  ApiLibraryRepository(this._api);

  final ApiClient _api;

  static String _path(String path, Map<String, String> query) =>
      Uri(path: path, queryParameters: query).toString();

  @override
  Future<LibrarySummary> summary() async =>
      LibrarySummary.fromJson(await _api.get('/library/summary'));

  @override
  Future<LibraryPage> listSets(
    String category,
    LibraryFilter filter, {
    int page = 1,
  }) async => LibraryPage.fromJson(
    await _api.get(
      _path('/library/sets', {
        'category': category,
        ...filter.toQuery(),
        'page': '$page',
      }),
    ),
  );

  @override
  Future<LibraryFacets> facets(String category) async => LibraryFacets.fromJson(
    await _api.get(_path('/library/facets', {'category': category})),
  );

  @override
  Future<void> deleteSet(String setId) =>
      _api.delete('/library/sets/${Uri.encodeComponent(setId)}');

  @override
  Future<PracticeSession> startSet(String setId) async =>
      PracticeSession.fromJson(
        await _api.post('/library/sets/${Uri.encodeComponent(setId)}/start'),
      );

  @override
  Future<List<SetAttempt>> attempts(String setId) async {
    final body = await _api.get(
      '/library/sets/${Uri.encodeComponent(setId)}/attempts',
    );
    return [
      for (final a in body['items'] as List<dynamic>)
        SetAttempt.fromJson(a as Map<String, dynamic>),
    ];
  }

  @override
  Future<PracticeResult> fetchResult(String resultId) async =>
      PracticeResult.fromJson(
        await _api.get('/practice/results/${Uri.encodeComponent(resultId)}'),
      );
}
