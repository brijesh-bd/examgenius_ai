import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/providers/auth_providers.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/exam_selection_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/question_generator/domain/generated_question.dart';
import '../../features/practice_test/domain/practice_models.dart';
import '../../features/practice_test/domain/practice_result.dart';
import '../../features/practice_test/presentation/screens/answer_review_screen.dart';
import '../../features/practice_test/presentation/screens/practice_result_screen.dart';
import '../../features/practice_test/presentation/screens/practice_test_screen.dart';
import '../../features/library/presentation/screens/category_library_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/question_generator/presentation/screens/preparation_screen.dart';
import '../../features/shell/coming_soon_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/shell/profile_screen.dart';
import '../../features/subscription/presentation/screens/plans_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/study_notes/domain/study_note.dart';
import '../../features/study_notes/presentation/providers/study_notes_providers.dart';
import '../../features/study_notes/presentation/screens/category_notes_screen.dart';
import '../../features/study_notes/presentation/screens/create_notes_screen.dart';
import '../../features/study_notes/presentation/screens/learning_path_screen.dart';
import '../../features/study_notes/presentation/screens/note_view_screen.dart';
import '../../features/study_notes/presentation/screens/notes_category_screen.dart';
import '../../features/study_notes/presentation/screens/notes_topic_screen.dart';
import '../../features/study_notes/presentation/screens/revision_screens.dart';
import '../../features/study_notes/presentation/screens/outline_screen.dart';
import '../../features/study_notes/presentation/screens/section_reader_screen.dart';
import '../../features/study_notes/domain/note_outline.dart';
import 'app_routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever login state changes, without rebuilding GoRouter.
  final authChanges = ValueNotifier<bool>(ref.read(sessionProvider) != null);
  ref.listen(sessionProvider, (_, user) => authChanges.value = user != null);
  ref.onDispose(authChanges.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splash) return null; // splash decides itself
      final loggedIn = authChanges.value;
      final isPublic = AppRoutes.publicRoutes.contains(loc);
      if (!loggedIn && !isPublic) return AppRoutes.login;
      if (loggedIn && isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, s) => _fade(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, s) => _fade(s, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.comingSoon,
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            ComingSoonScreen(title: s.uri.queryParameters['title']),
      ),
      GoRoute(
        path: AppRoutes.exams,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => ExamSelectionScreen(
          categoryId: s.pathParameters['categoryId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.syllabus,
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            PreparationScreen(examId: s.pathParameters['examId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.prepare,
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            PreparationScreen(categoryId: s.pathParameters['categoryId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.generatedQuestions,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => PracticeTestScreen(
          source: s.extra is GenerationRequest
              ? GenerateSource(s.extra as GenerationRequest)
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.practiceRetry,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => PracticeTestScreen(
          source: s.extra is RetrySource ? s.extra as RetrySource : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.libraryPractice,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => PracticeTestScreen(
          source: s.extra is LibrarySetSource
              ? s.extra as LibrarySetSource
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.practiceResult,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => PracticeResultScreen(
          result: s.extra is PracticeResult ? s.extra as PracticeResult : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.plans,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.practiceReview,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => AnswerReviewScreen(
          result: s.extra is PracticeResult ? s.extra as PracticeResult : null,
        ),
      ),
      // AI Study Notes: Category → Exam → Topic → Create → View.
      GoRoute(
        path: AppRoutes.notes,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotesCategoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.notesExams,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => ExamSelectionScreen(
          categoryId: s.pathParameters['categoryId'] ?? '',
          forNotes: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.notesTopics,
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            NotesTopicScreen(examId: s.pathParameters['examId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.notesCreate,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => CreateNotesScreen(
          examId: s.pathParameters['examId'] ?? '',
          topicId: s.pathParameters['topicId'] ?? '',
          prefill: s.extra is NotesPrefill ? s.extra as NotesPrefill : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.noteView,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => NoteViewScreen(
          noteId: s.pathParameters['noteId'] ?? '',
          initial: s.extra is StudyNote ? s.extra as StudyNote : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.notesOutline,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => OutlineScreen(
          examId: s.pathParameters['examId'] ?? '',
          unitId: s.pathParameters['unitId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.notesSection,
        parentNavigatorKey: _rootKey,
        builder: (_, s) {
          final q = s.uri.queryParameters;
          return SectionReaderScreen(
            outlineKey: (
              examId: s.pathParameters['examId'] ?? '',
              unitId: s.pathParameters['unitId'] ?? '',
              language: q['language'] == 'hi' ? 'hi' : 'en',
              mode: LearningMode.values.firstWhere(
                (m) => m.wire == q['mode'],
                orElse: () => LearningMode.complete,
              ),
            ),
            section: (
              chapterId: s.pathParameters['chapterId'] ?? '',
              sectionId: s.pathParameters['sectionId'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notesPath,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => LearningPathScreen(
          examId: s.pathParameters['examId'] ?? '',
          subjectId: s.pathParameters['subjectId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.noteRevision,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => QuickRevisionScreen(
          noteId: s.pathParameters['noteId'] ?? '',
          initial: s.extra is StudyNote ? s.extra as StudyNote : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.noteFlashcards,
        parentNavigatorKey: _rootKey,
        builder: (_, s) => FlashcardsScreen(
          noteId: s.pathParameters['noteId'] ?? '',
          initial: s.extra is StudyNote ? s.extra as StudyNote : null,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          _branch(AppRoutes.home, const DashboardScreen()),
          _branch(
            AppRoutes.practice,
            const PlaceholderTab(tab: ShellTab.practice),
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.savedPractice,
                builder: (_, _) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.libraryNotes,
                    builder: (_, s) => CategoryNotesScreen(
                      category: s.pathParameters['category'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.libraryCategory,
                    builder: (_, s) => CategoryLibraryScreen(
                      category: s.pathParameters['category'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(
            AppRoutes.analytics,
            const PlaceholderTab(tab: ShellTab.analytics),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Helper so screens open placeholder modules consistently.
extension ComingSoonNav on BuildContext {
  void openComingSoon(String title) => push(
    Uri(
      path: AppRoutes.comingSoon,
      queryParameters: {'title': title},
    ).toString(),
  );
}
