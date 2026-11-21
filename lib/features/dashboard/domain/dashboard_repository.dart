import 'dashboard_models.dart';

abstract interface class DashboardRepository {
  Future<List<ExamCategory>> fetchExamCatalog();
  Future<DashboardSummary> fetchSummary(String studentId);
}
