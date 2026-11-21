/// Exam catalog entities. Served by the backend so new exams can be added
/// without an app update; the app only knows category *ids* for styling.
class Exam {
  const Exam({required this.id, required this.name, required this.categoryId});

  final String id;
  final String name;
  final String categoryId;

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
    id: json['id'] as String,
    name: json['name'] as String,
    categoryId: json['categoryId'] as String,
  );
}

class ExamCategory {
  const ExamCategory({
    required this.id,
    required this.name,
    required this.exams,
  });

  /// e.g. `railway`, `ssc`, `banking`. Unknown ids get a neutral style.
  final String id;
  final String name;
  final List<Exam> exams;

  factory ExamCategory.fromJson(Map<String, dynamic> json) => ExamCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    exams: (json['exams'] as List<dynamic>)
        .map((e) => Exam.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class RecentResult {
  const RecentResult({
    required this.testName,
    required this.score,
    required this.maxScore,
    required this.accuracy,
    required this.takenAt,
    this.questionCount = 0,
  });

  final String testName;
  final double score;
  final double maxScore;
  final double accuracy; // 0..1
  final DateTime takenAt;
  final int questionCount;
}

class ContinueItem {
  const ContinueItem({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double progress; // 0..1
}

class DashboardSummary {
  const DashboardSummary({
    required this.dailyGoalDone,
    required this.dailyGoalTotal,
    required this.streakDays,
    required this.accuracy,
    required this.testsTaken,
    required this.avgScore,
    required this.freeAiQuestionsLeft,
    required this.isPremium,
    required this.unreadNotifications,
    required this.recentResults,
    this.continueItem,
  });

  final int dailyGoalDone;
  final int dailyGoalTotal;
  final int streakDays;
  final double accuracy; // 0..1
  final int testsTaken;
  final double avgScore; // percent
  final int freeAiQuestionsLeft;
  final bool isPremium;
  final int unreadNotifications;
  final List<RecentResult> recentResults;
  final ContinueItem? continueItem;

  double get dailyGoalProgress =>
      dailyGoalTotal == 0 ? 0 : (dailyGoalDone / dailyGoalTotal).clamp(0, 1);
}
