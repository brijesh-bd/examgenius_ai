import 'dart:math';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../question_generator/domain/generated_question.dart';
import '../domain/practice_models.dart';
import '../domain/practice_result.dart';

/// Backend practice flow. The server generates with Gemini, keeps the answer
/// key, scores submissions and stores everything in MongoDB.
class ApiPracticeRepository implements PracticeRepository {
  ApiPracticeRepository(this._api, {required this.language});

  final ApiClient _api;

  /// Current app language ('en' / 'hi') — questions are written in it.
  final String Function() language;

  /// One idempotency key per request object: retrying the same request (after
  /// a timeout or network drop) reuses it, so the backend returns the set it
  /// already saved instead of generating and saving a duplicate.
  static final _requestKeys = Expando<String>('requestKey');
  static final _rng = Random.secure();

  static String _newKey() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
      '${List.generate(4, (_) => _rng.nextInt(1 << 32).toRadixString(36)).join()}';

  @override
  Future<PracticeSession> startSession(GenerationRequest request) async {
    final key = _requestKeys[request] ??= _newKey();
    final body = await _api.post('/questions/generate', {
      ...request.toJson(),
      'requestKey': key,
      'language': language(),
    }, kGenerateTimeout);
    return PracticeSession.fromJson(body);
  }

  @override
  Future<PracticeResult> submit(PracticeSubmission submission) async {
    final body = await _api.post(
      '/practice/${Uri.encodeComponent(submission.sessionId)}/submit',
      submission.toJson(),
    );
    return PracticeResult.fromJson(body);
  }

  @override
  Future<PracticeSession> retrySession(
    PracticeResult result,
    List<String> questionIds,
  ) async {
    final body = await _api.post('/practice/retry', {
      'resultId': result.resultId,
      'questionIds': questionIds,
    });
    return PracticeSession.fromJson(body);
  }

  @override
  Future<List<TopicStat>> topicStats() async {
    final body = await _api.get('/practice/topic-stats');
    return (body['topics'] as List<dynamic>)
        .map((t) => TopicStat.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
