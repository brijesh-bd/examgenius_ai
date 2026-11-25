import '../../../core/network/api_client.dart';
import '../domain/generated_question.dart';
import '../domain/question_generator_repository.dart';

/// `GET /questions/bank/availability`, `GET /practice/last-config`.
class ApiPracticeSetupRepository implements PracticeSetupRepository {
  ApiPracticeSetupRepository(this._api);

  final ApiClient _api;

  @override
  Future<int> bankAvailability({
    required String examId,
    required PracticeMode mode,
    required List<String> topicIds,
    List<String> nodeIds = const [],
    required Difficulty difficulty,
    required String language,
  }) async {
    final body = await _api.get(
      Uri(
        path: '/questions/bank/availability',
        queryParameters: {
          'examId': examId,
          'mode': mode.name,
          if (topicIds.isNotEmpty) 'topicIds': topicIds.join(','),
          if (nodeIds.isNotEmpty) 'nodeIds': nodeIds.join(','),
          'difficulty': difficulty.name,
          'language': language,
        },
      ).toString(),
    );
    return (body['available'] as num? ?? 0).toInt();
  }

  @override
  Future<LastPracticeConfig?> lastConfig(String examId) async {
    final body = await _api.get(
      Uri(
        path: '/practice/last-config',
        queryParameters: {'examId': examId},
      ).toString(),
    );
    final c = body['config'];
    return c is Map<String, dynamic> ? LastPracticeConfig.fromJson(c) : null;
  }
}

/// In-app stand-in (tests / USE_MOCK_BACKEND).
class MockPracticeSetupRepository implements PracticeSetupRepository {
  MockPracticeSetupRepository({this.available = 100});

  /// Stored questions reported for any selection (tests set it low).
  int available;
  final Map<String, LastPracticeConfig> saved = {};

  @override
  Future<int> bankAvailability({
    required String examId,
    required PracticeMode mode,
    required List<String> topicIds,
    List<String> nodeIds = const [],
    required Difficulty difficulty,
    required String language,
  }) async => available;

  @override
  Future<LastPracticeConfig?> lastConfig(String examId) async => saved[examId];
}
