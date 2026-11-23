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

  /// My Learning Library — third bottom tab (Saved).
  static const savedPractice = '/saved';

  /// One category's library inside the Saved tab, e.g. `/saved/c/banking`.
  static const libraryCategory = 'c/:category';
  static String libraryCategoryFor(String category) => '/saved/c/$category';

  /// One category's study notes inside the Saved tab, e.g. `/saved/notes/ssc`.
  static const libraryNotes = 'notes/:category';
  static String libraryNotesFor(String category) => '/saved/notes/$category';

  /// Practice Again on a Library set; a LibrarySetSource is passed as `extra`.
  static const libraryPractice = '/practice/set';

  // ── AI Study Notes ──
  /// Category picker (Home → AI Study Notes).
  static const notes = '/notes';

  /// Exams of one category in notes mode, e.g. `/notes/exams/ssc`.
  static const notesExams = '/notes/exams/:categoryId';
  static String notesExamsFor(String categoryId) => '/notes/exams/$categoryId';

  /// Subject → topic picker for one exam.
  static const notesTopics = '/notes/topics/:examId';
  static String notesTopicsFor(String examId) => '/notes/topics/$examId';

  /// Create Notes configuration for one topic.
  static const notesCreate = '/notes/create/:examId/:topicId';
  static String notesCreateFor(String examId, String topicId) =>
      '/notes/create/$examId/${Uri.encodeComponent(topicId)}';

  /// A saved note; the StudyNote may be passed as `extra` to skip a fetch.
  static const noteView = '/notes/view/:noteId';
  static String noteViewFor(String noteId) =>
      '/notes/view/${Uri.encodeComponent(noteId)}';

  /// Syllabus learning path of one subject, e.g. `/notes/path/ibps_so_it/professional_it`.
  static const notesPath = '/notes/path/:examId/:subjectId';
  static String notesPathFor(String examId, String subjectId) =>
      '/notes/path/$examId/$subjectId';

  /// Quick revision / flashcards of a saved note (StudyNote as `extra`).
  static const noteRevision = '/notes/revision/:noteId';
  static String noteRevisionFor(String noteId) =>
      '/notes/revision/${Uri.encodeComponent(noteId)}';
  static const noteFlashcards = '/notes/flashcards/:noteId';
  static String noteFlashcardsFor(String noteId) =>
      '/notes/flashcards/${Uri.encodeComponent(noteId)}';

  static const publicRoutes = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
  };
}
