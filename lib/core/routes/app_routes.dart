abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const tests = '/tests';
  static const practice = '/practice';
  static const analytics = '/analytics';
  static const profile = '/profile';

  /// Placeholder for modules scheduled in later phases.
  static const comingSoon = '/coming-soon';

  /// Exam selection for one category, e.g. `/exams/railway`.
  static const exams = '/exams/:categoryId';
  static String examsFor(String categoryId) => '/exams/$categoryId';

  /// Syllabus + generator setup for one exam, e.g. `/syllabus/rrb_ntpc`.
  static const syllabus = '/syllabus/:examId';
  static String syllabusFor(String examId) => '/syllabus/$examId';

  /// Topics of one subject as selectable cards, e.g. `/syllabus/rrb_ntpc/maths`.
  static const subjectTopics = '/syllabus/:examId/:subjectId';
  static String subjectTopicsFor(String examId, String subjectId) =>
      '/syllabus/$examId/$subjectId';

  /// Generated questions; the GenerationRequest is passed as `extra`.
  static const generatedQuestions = '/generate/questions';

  /// Scorecard after submission; the PracticeResult is passed as `extra`.
  static const practiceResult = '/practice/result';

  /// Detailed answer review; the PracticeResult is passed as `extra`.
  static const practiceReview = '/practice/review';

  /// Re-attempt selected questions; a RetrySource is passed as `extra`.
  static const practiceRetry = '/practice/retry';

  static const publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
  };
}
