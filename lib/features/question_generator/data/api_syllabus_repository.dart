import '../../../core/network/api_client.dart';
import '../domain/question_generator_repository.dart';
import '../domain/syllabus.dart';

/// `GET /api/v1/exams/:examId/syllabus`.
class ApiSyllabusRepository implements SyllabusRepository {
  ApiSyllabusRepository(this._api);

  final ApiClient _api;

  @override
  Future<Syllabus> fetchSyllabus(String examId) async => Syllabus.fromJson(
    await _api.get('/exams/${Uri.encodeComponent(examId)}/syllabus'),
  );
}
