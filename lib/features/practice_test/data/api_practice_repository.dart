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

  @override
  Future<PracticeSession> startSession(GenerationRequest request) async {
    final body = await _api.post('/questions/generate', {
      ...request.toJson(),
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
}
