abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  /// Free vs Pro plans and the free trial.
  static const plans = '/plans';

  static const home = '/home';
  static const practice = '/practice';
  static const analytics = '/analytics';
  static const profile = '/profile';

  /// Placeholder for modules scheduled in later phases.
  static const comingSoon = '/coming-soon';

  /// Exam selection for one category, e.g. `/exams/railway`.
  static const exams = '/exams/:categoryId';
  static String examsFor(String categoryId) => '/exams/$categoryId';

  /// Create Practice for one exam (subjects, topics, level, count), e.g. `/syllabus/rrb_ntpc`.
  static const syllabus = '/syllabus/:examId';
  static String syllabusFor(String examId) => '/syllabus/$examId';

  /// Generated questions; the GenerationRequest is passed as `extra`.
  static const generatedQuestions = '/generate/questions';

  /// Scorecard after submission; the PracticeResult is passed as `extra`.
  static const practiceResult = '/practice/result';

  /// Detailed answer review; the PracticeResult is passed as `extra`.
  static const practiceReview = '/practice/review';

  /// Re-attempt selected questions; a RetrySource is passed as `extra`.
  static const practiceRetry = '/practice/retry';

  /// My Saved Practice — third bottom tab (replaced the old Tests tab).
  static const savedPractice = '/saved';

  static const publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
  };
}
