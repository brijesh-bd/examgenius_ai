import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

/// Seed catalog matching the initial exam list. Shape mirrors the planned
/// `GET /api/v1/exams` response so the real client can reuse `fromJson`.
const kExamCatalogJson = <Map<String, dynamic>>[
  {
    'id': 'railway',
    'name': 'Railway',
    'exams': [
      {'id': 'rrb_ntpc', 'name': 'RRB NTPC', 'categoryId': 'railway'},
      {'id': 'rrb_group_d', 'name': 'RRB Group D', 'categoryId': 'railway'},
      {'id': 'rrb_alp', 'name': 'RRB ALP', 'categoryId': 'railway'},
      {'id': 'rrb_je', 'name': 'RRB JE', 'categoryId': 'railway'},
      {
        'id': 'rrb_tech_gr1_signal',
        'name': 'RRB Technician Grade I Signal',
        'categoryId': 'railway',
      },
      {
        'id': 'rrb_tech_gr3',
        'name': 'RRB Technician Grade III',
        'categoryId': 'railway',
      },
      {
        'id': 'rrb_station_master',
        'name': 'RRB Station Master',
        'categoryId': 'railway',
      },
    ],
  },
  {
    'id': 'ssc',
    'name': 'SSC',
    'exams': [
      {'id': 'ssc_cgl', 'name': 'SSC CGL', 'categoryId': 'ssc'},
      {'id': 'ssc_chsl', 'name': 'SSC CHSL', 'categoryId': 'ssc'},
      {'id': 'ssc_mts', 'name': 'SSC MTS', 'categoryId': 'ssc'},
      {'id': 'ssc_gd', 'name': 'SSC GD', 'categoryId': 'ssc'},
      {'id': 'ssc_cpo', 'name': 'SSC CPO', 'categoryId': 'ssc'},
      {
        'id': 'ssc_je',
        'name': 'SSC JE (Civil, Electrical, Mechanical)',
        'categoryId': 'ssc',
      },
      {
        'id': 'ssc_steno',
        'name': "SSC Stenographer Grade 'C' & 'D'",
        'categoryId': 'ssc',
      },
      {
        'id': 'ssc_sp_matric',
        'name': 'SSC Selection Post (Matriculation)',
        'categoryId': 'ssc',
      },
      {
        'id': 'ssc_sp_hsc',
        'name': 'SSC Selection Post (Higher Secondary)',
        'categoryId': 'ssc',
      },
      {
        'id': 'ssc_sp_grad',
        'name': 'SSC Selection Post (Graduation)',
        'categoryId': 'ssc',
      },
    ],
  },
  {
    'id': 'banking',
    'name': 'Banking',
    'exams': [
      {'id': 'ibps_po', 'name': 'IBPS PO', 'categoryId': 'banking'},
      {'id': 'ibps_clerk', 'name': 'IBPS Clerk', 'categoryId': 'banking'},
      {'id': 'ibps_rrb_po', 'name': 'IBPS RRB PO', 'categoryId': 'banking'},
      {
        'id': 'ibps_rrb_clerk',
        'name': 'IBPS RRB Clerk',
        'categoryId': 'banking',
      },
      {
        'id': 'ibps_so_it',
        'name': 'IBPS SO IT Officer',
        'categoryId': 'banking',
      },
      {
        'id': 'ibps_rrb_so_it',
        'name': 'IBPS RRB Officer Scale-II (IT)',
        'categoryId': 'banking',
      },
      {'id': 'sbi_po', 'name': 'SBI PO', 'categoryId': 'banking'},
      {'id': 'sbi_clerk', 'name': 'SBI Clerk', 'categoryId': 'banking'},
    ],
  },
];

final List<ExamCategory> kExamCatalog = kExamCatalogJson
    .map(ExamCategory.fromJson)
    .toList(growable: false);

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<List<ExamCategory>> fetchExamCatalog() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return kExamCatalog;
  }

  @override
  Future<DashboardSummary> fetchSummary(String studentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();
    return DashboardSummary(
      dailyGoalDone: 32,
      dailyGoalTotal: 50,
      streakDays: 6,
      accuracy: 0.74,
      testsTaken: 18,
      avgScore: 68.5,
      freeAiQuestionsLeft: 20,
      isPremium: false,
      unreadNotifications: 3,
      continueItem: const ContinueItem(
        title: 'Quantitative Aptitude',
        subtitle: 'Time & Work · Intermediate',
        progress: 0.6,
      ),
      recentResults: [
        RecentResult(
          testName: 'Railway NTPC - Mock Test 1',
          score: 32,
          maxScore: 40,
          questionCount: 40,
          accuracy: 0.825,
          takenAt: now.subtract(const Duration(days: 1)),
        ),
        RecentResult(
          testName: 'General Awareness Sectional',
          score: 31.5,
          maxScore: 50,
          questionCount: 50,
          accuracy: 0.66,
          takenAt: now.subtract(const Duration(days: 3)),
        ),
      ],
    );
  }
}
