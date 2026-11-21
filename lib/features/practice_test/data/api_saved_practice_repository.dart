import '../../../core/network/api_client.dart';
import '../domain/practice_result.dart';
import '../domain/saved_practice.dart';

/// `GET|POST|DELETE /api/v1/practice/saved`. Keeps a small in-memory index of
/// saved result ids so [isSaved] can answer synchronously.
class ApiSavedPracticeRepository implements SavedPracticeRepository {
  ApiSavedPracticeRepository(this._api);

  final ApiClient _api;
  final Map<String, String> _savedIdByResult = {}; // resultId → saved id

  @override
  bool isSaved(String resultId) => _savedIdByResult.containsKey(resultId);

  @override
  Future<SavedPractice> save(PracticeResult result) async {
    final saved = SavedPractice.fromJson(
      await _api.post('/practice/saved', {'resultId': result.resultId}),
    );
    _savedIdByResult[result.resultId] = saved.id;
    return saved;
  }

  @override
  Future<List<SavedPractice>> list() async {
    final body = await _api.get('/practice/saved');
    final items = (body['items'] as List<dynamic>)
        .map((e) => SavedPractice.fromJson(e as Map<String, dynamic>))
        .toList();
    _savedIdByResult
      ..clear()
      ..addEntries(items.map((s) => MapEntry(s.result.resultId, s.id)));
    return items;
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/practice/saved/${Uri.encodeComponent(id)}');
    _savedIdByResult.removeWhere((_, savedId) => savedId == id);
  }
}
