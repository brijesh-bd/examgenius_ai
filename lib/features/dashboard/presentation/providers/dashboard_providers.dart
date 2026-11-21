import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/mock_dashboard_repository.dart';
import '../../domain/dashboard_models.dart';
import '../../domain/dashboard_repository.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => MockDashboardRepository());

final examCatalogProvider = FutureProvider<List<ExamCategory>>(
  (ref) => ref.watch(dashboardRepositoryProvider).fetchExamCatalog(),
);

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  final user = ref.watch(sessionProvider);
  return ref.watch(dashboardRepositoryProvider).fetchSummary(user?.id ?? '');
});

/// Display name of the student's target exam, resolved from the catalog.
final targetExamNameProvider = Provider.autoDispose<String?>((ref) {
  final examId = ref.watch(sessionProvider.select((u) => u?.targetExamId));
  final catalog = ref.watch(examCatalogProvider).value;
  if (examId == null || catalog == null) return null;
  for (final c in catalog) {
    for (final e in c.exams) {
      if (e.id == examId) return e.name;
    }
  }
  return null;
});

/// Catalog lookup by exam id (null while loading or if unknown).
final examByIdProvider = Provider.autoDispose.family<Exam?, String>((ref, examId) {
  final catalog = ref.watch(examCatalogProvider).value;
  if (catalog == null) return null;
  for (final c in catalog) {
    for (final e in c.exams) {
      if (e.id == examId) return e;
    }
  }
  return null;
});
