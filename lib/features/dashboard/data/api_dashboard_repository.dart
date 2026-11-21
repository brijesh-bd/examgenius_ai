import '../../../core/network/api_client.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

/// `GET /api/v1/exams` and `GET /api/v1/dashboard/summary`.
class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ExamCategory>> fetchExamCatalog() async {
    final body = await _api.get('/exams');
    return (body['categories'] as List<dynamic>)
        .map((c) => ExamCategory.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DashboardSummary> fetchSummary(String studentId) async {
    final b = await _api.get('/dashboard/summary');
    double d(String k) => (b[k] as num?)?.toDouble() ?? 0;
    return DashboardSummary(
      // Daily goal / streak / premium are not tracked by the backend yet.
      dailyGoalDone: 0,
      dailyGoalTotal: 0,
      streakDays: 0,
      accuracy: d('accuracy'),
      testsTaken: (b['testsTaken'] as num?)?.toInt() ?? 0,
      avgScore: d('avgScore'),
      freeAiQuestionsLeft: 0,
      isPremium: false,
      unreadNotifications: (b['unreadNotifications'] as num?)?.toInt() ?? 0,
      recentResults: [
        for (final r in (b['recentResults'] as List<dynamic>? ?? const []))
          RecentResult(
            testName: (r as Map<String, dynamic>)['testName'] as String,
            score: (r['score'] as num).toDouble(),
            maxScore: (r['maxScore'] as num).toDouble(),
            accuracy: (r['accuracy'] as num).toDouble(),
            takenAt: DateTime.parse(r['takenAt'] as String),
            questionCount: (r['questionCount'] as num?)?.toInt() ?? 0,
          ),
      ],
    );
  }
}
