import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../question_generator/domain/generated_question.dart';
import '../../../question_generator/presentation/providers/question_generator_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../localization/settings_providers.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../data/api_practice_repository.dart';
import '../../data/mock_practice_repository.dart';
import '../../domain/practice_models.dart';
import '../../domain/practice_result.dart';

/// Real backend by default; in-app mock under `flutter test` or USE_MOCK_BACKEND.
final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) {
    return MockPracticeRepository(
      ref.watch(questionGeneratorRepositoryProvider),
      ref.watch(syllabusRepositoryProvider),
    );
  }
  return ApiPracticeRepository(
    ref.watch(apiClientProvider),
    language: () => ref.read(localeProvider).languageCode,
  );
});

/// Opens a session for a [SessionSource]: fresh generation, a retry, or
/// Practice Again on a Library set.
final practiceSessionProvider = FutureProvider.autoDispose
    .family<PracticeSession, SessionSource>((ref, source) {
      final repo = ref.watch(practiceRepositoryProvider);
      return switch (source) {
        GenerateSource(:final request) => _generate(ref, repo, request),
        LibrarySetSource(:final setId) =>
          ref.watch(libraryRepositoryProvider).startSet(setId),
        RetrySource(:final result, :final questionIds) => repo.retrySession(
          result,
          questionIds,
        ),
      };
    });

Future<PracticeSession> _generate(
  Ref ref,
  PracticeRepository repo,
  GenerationRequest request,
) async {
  final session = await repo.startSession(request);
  // The backend saved the new set to the Library: refresh it.
  if (ref.mounted) ref.read(libraryRevisionProvider.notifier).bump();
  return session;
}

/// Everything the test screen shows, derived from user actions + the clock.
@immutable
class PracticeTestState {
  const PracticeTestState({
    required this.session,
    this.current = 0,
    this.answers = const {},
    this.remaining,
    this.timeUp = false,
    this.submitting = false,
    this.result,
    this.submitError,
  });

  final PracticeSession session;

  /// Index of the question on screen.
  final int current;

  /// questionId → selected option index.
  final Map<String, int> answers;

  /// Time left, or `null` for an untimed test.
  final Duration? remaining;

  /// Set once the countdown hits zero; the screen then auto-submits.
  final bool timeUp;

  /// A submission is in flight.
  final bool submitting;

  /// Scorecard from the backend once submitted.
  final PracticeResult? result;

  /// Last submission failure (shown with a retry).
  final Object? submitError;

  /// No more answer changes once time is up or the test is being submitted.
  bool get locked => timeUp || submitting || result != null;

  int get total => session.questions.length;
  int get answeredCount => answers.length;
  bool get allAnswered => total > 0 && answeredCount == total;
  PracticeQuestion get question => session.questions[current];
  int? get selected => answers[question.id];
  bool isAnswered(int index) =>
      answers.containsKey(session.questions[index].id);
  bool get isFirst => current == 0;
  bool get isLast => current == total - 1;

  PracticeTestState copyWith({
    int? current,
    Map<String, int>? answers,
    Duration? remaining,
    bool? timeUp,
    bool? submitting,
    PracticeResult? result,
    Object? submitError,
    bool clearError = false,
  }) => PracticeTestState(
    session: session,
    current: current ?? this.current,
    answers: answers ?? this.answers,
    remaining: remaining ?? this.remaining,
    timeUp: timeUp ?? this.timeUp,
    submitting: submitting ?? this.submitting,
    result: result ?? this.result,
    submitError: clearError ? null : (submitError ?? this.submitError),
  );
}

/// Answer selection, navigation and countdown for one test session.
class PracticeTestController extends Notifier<PracticeTestState> {
  PracticeTestController(this.session);

  final PracticeSession session;
  Timer? _ticker;
  final _stopwatch = Stopwatch()..start();

  @override
  PracticeTestState build() {
    ref.onDispose(() => _ticker?.cancel());
    final limit = session.timeLimit;
    if (limit != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
    return PracticeTestState(session: session, remaining: limit);
  }

  void _tick() {
    final left = state.remaining;
    if (left == null || state.timeUp) return;
    final next = left - const Duration(seconds: 1);
    if (next <= Duration.zero) {
      _ticker?.cancel();
      state = state.copyWith(remaining: Duration.zero, timeUp: true);
    } else {
      state = state.copyWith(remaining: next);
    }
  }

  /// Picks (or changes) the answer for the current question.
  void select(int optionIndex) {
    if (state.locked) return;
    state = state.copyWith(
      answers: {...state.answers, state.question.id: optionIndex},
    );
  }

  /// Removes the answer for the current question.
  void clear() {
    if (state.locked || state.selected == null) return;
    state = state.copyWith(
      answers: {...state.answers}..remove(state.question.id),
    );
  }

  void goTo(int index) {
    if (index < 0 || index >= state.total) return;
    state = state.copyWith(current: index);
  }

  void next() => goTo(state.current + 1);
  void previous() => goTo(state.current - 1);

  /// Stops the clock (called when the test is submitted).
  /// Sends answers to the backend for scoring. Ignored while a submission is
  /// in flight or after it succeeded, so double taps can never submit twice.
  Future<void> submit({bool auto = false}) async {
    if (state.submitting || state.result != null) return;
    _ticker?.cancel();
    _stopwatch.stop();
    state = state.copyWith(submitting: true, clearError: true);
    final limit = session.timeLimit;
    final taken = limit != null && state.remaining != null
        ? limit - state.remaining!
        : _stopwatch.elapsed;
    try {
      final result = await ref
          .read(practiceRepositoryProvider)
          .submit(
            PracticeSubmission(
              sessionId: session.sessionId,
              answers: state.answers,
              timeTaken: taken,
              autoSubmitted: auto,
            ),
          );
      if (!ref.mounted) return;
      state = state.copyWith(submitting: false, result: result);
      // New attempt → the Library's scores and attempt counts changed.
      if (session.setId != null) {
        ref.read(libraryRevisionProvider.notifier).bump();
      }
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(submitting: false, submitError: e);
      // Resume the clock so the student can retry (unless time is already up).
      if (!state.timeUp && session.timeLimit != null) {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
      _stopwatch.start();
    }
  }
}

final practiceTestProvider = NotifierProvider.autoDispose
    .family<PracticeTestController, PracticeTestState, PracticeSession>(
      PracticeTestController.new,
    );
