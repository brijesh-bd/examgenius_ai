import 'package:flutter/material.dart';

import '../../../../core/network/api_error_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../question_generator/domain/generated_question.dart';
import '../../domain/practice_models.dart';
import '../providers/practice_providers.dart';
import '../widgets/practice_question_card.dart';
import '../widgets/question_palette.dart';
import '../widgets/submit_confirmation_dialog.dart';
import '../widgets/test_header.dart';
import '../widgets/test_timer_chip.dart';

/// Screen 1 — Generated Questions practice test. Opened by the Generate
/// Questions button with a [GenerationRequest]. One question at a time,
/// palette navigation, countdown, Submit enabled only when all are answered.
class PracticeTestScreen extends ConsumerWidget {
  const PracticeTestScreen({super.key, required this.source});

  /// `null` when the route was opened without data (e.g. deep link).
  final SessionSource? source;

  static String _title(SessionSource s) => switch (s) {
    GenerateSource(:final request) => request.examName,
    RetrySource(:final result) => result.examName,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final src = source;
    if (src == null) {
      return Scaffold(
        appBar: AppBar(),
        body: StateMessage(icon: Icons.quiz_outlined, title: l10n.errorGeneric),
      );
    }
    final session = ref.watch(practiceSessionProvider(src));

    return session.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(_title(src))),
        body: const _GeneratingView(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(_title(src))),
        body: StateMessage(
          icon: Icons.wifi_off_rounded,
          title: apiErrorText(l10n, e),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(practiceSessionProvider(src)),
        ),
      ),
      data: (s) => s.questions.isEmpty
          ? Scaffold(
              appBar: AppBar(title: Text(_title(src))),
              body: StateMessage(
                icon: Icons.search_off_rounded,
                title: l10n.noQuestionsForSelection,
              ),
            )
          : _TestView(session: s),
    );
  }
}

/// Shown while the backend (AI) prepares the questions.
class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox.square(
                  dimension: 96,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiGradient,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.generatingQuestions,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestView extends ConsumerStatefulWidget {
  const _TestView({required this.session});
  final PracticeSession session;

  @override
  ConsumerState<_TestView> createState() => _TestViewState();
}

class _TestViewState extends ConsumerState<_TestView> {
  bool _dialogOpen = false;

  PracticeSession get session => widget.session;

  /// Manual submit: confirmation dialog (Screen 2), then send to backend.
  Future<void> _confirmAndSubmit() async {
    if (_dialogOpen) return; // a second tap while the dialog is up does nothing
    final state = ref.read(practiceTestProvider(session));
    if (state.submitting || state.result != null) return;
    _dialogOpen = true;
    final ok = await showSubmitConfirmationDialog(
      context,
      total: state.total,
      answered: state.answeredCount,
      remaining: state.remaining,
    );
    _dialogOpen = false;
    if (ok && mounted) {
      ref.read(practiceTestProvider(session).notifier).submit();
    }
  }

  /// Timer expired: close any open sheet/dialog and submit without asking.
  void _autoSubmit() {
    Navigator.of(context).popUntil((r) => r is! PopupRoute);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.timeUpSubmitting),
        ),
      );
    ref.read(practiceTestProvider(session).notifier).submit(auto: true);
  }

  void _showSubmitError() {
    final l10n = context.l10n;
    final timeUp = ref.read(practiceTestProvider(session)).timeUp;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          persist: false,
          content: Text(l10n.submitFailed),
          action: SnackBarAction(
            label: l10n.retry,
            onPressed: () => ref
                .read(practiceTestProvider(session).notifier)
                .submit(auto: timeUp),
          ),
        ),
      );
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        title: Text(l10n.leaveTestTitle),
        content: Text(l10n.leaveTestBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.continueTest),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.leaveTest),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  void _openPalette(PracticeTestState state) {
    final controller = ref.read(practiceTestProvider(session).notifier);
    showQuestionPaletteSheet(
      context,
      total: state.total,
      statusOf: (i) {
        final st = ref.read(practiceTestProvider(session));
        if (i == st.current) return PaletteStatus.current;
        return st.isAnswered(i)
            ? PaletteStatus.answered
            : PaletteStatus.notAnswered;
      },
      onTap: controller.goTo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceTestProvider(session));
    final controller = ref.read(practiceTestProvider(session).notifier);
    ref.listen(practiceTestProvider(session).select((s) => s.timeUp), (
      _,
      timeUp,
    ) {
      if (timeUp) _autoSubmit();
    });
    ref.listen(practiceTestProvider(session).select((s) => s.result), (
      _,
      result,
    ) {
      if (result != null) {
        context.pushReplacement(AppRoutes.practiceResult, extra: result);
      }
    });
    ref.listen(practiceTestProvider(session).select((s) => s.submitError), (
      _,
      error,
    ) {
      if (error != null) _showSubmitError();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.locked) _confirmLeave();
      },
      child: Stack(
        children: [
          _scaffold(context, state, controller),
          if (state.submitting) const _SubmittingOverlay(),
        ],
      ),
    );
  }

  Widget _scaffold(
    BuildContext context,
    PracticeTestState state,
    PracticeTestController controller,
  ) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          session.examName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (state.remaining != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: Center(child: TestTimerChip(remaining: state.remaining!)),
            ),
          IconButton(
            tooltip: l10n.questionPalette,
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () => _openPalette(state),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                children: [
                  ResponsiveCenter(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (session.isPreview) ...[
                          _InfoBanner(text: l10n.sampleQuestionsNote),
                          const SizedBox(height: 12),
                        ],
                        if (session.questions.length <
                            session.requestedCount) ...[
                          _InfoBanner(
                            text: l10n.fewerQuestionsNote(
                              session.questions.length,
                              session.requestedCount,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TestHeader(state: state),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(
                              position: Tween(
                                begin: const Offset(0.04, 0),
                                end: Offset.zero,
                              ).animate(a),
                              child: child,
                            ),
                          ),
                          child: PracticeQuestionCard(
                            key: ValueKey(state.question.id),
                            question: state.question,
                            number: state.current + 1,
                            selected: state.selected,
                            onSelect: controller.select,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: state.selected == null
                                  ? null
                                  : controller.clear,
                              icon: const Icon(
                                Icons.backspace_outlined,
                                size: 18,
                              ),
                              label: Text(l10n.clearAnswer),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _openPalette(state),
                              icon: const Icon(
                                Icons.grid_view_rounded,
                                size: 18,
                              ),
                              label: Text(l10n.questionPalette),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(
              state: state,
              onPrevious: controller.previous,
              onNext: controller.next,
              onSubmit: _confirmAndSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.state,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final PracticeTestState state;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final left = state.total - state.answeredCount;
    final canSubmit = state.allAnswered && !state.timeUp;

    return Material(
      elevation: 8,
      color: scheme.surface,
      shadowColor: AppColors.cardShadow,
      child: ResponsiveCenter(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isFirst ? null : onPrevious,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: Text(l10n.previousQuestion),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: state.isLast ? null : onNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(l10n.nextQuestion)),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              canSubmit ? l10n.allAnsweredReady : l10n.answerAllToSubmit(left),
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: canSubmit ? AppColors.success : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: canSubmit ? onSubmit : null,
              icon: const Icon(Icons.task_alt_rounded),
              label: Text(l10n.submitTest),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

/// Blocks the screen while answers are sent (prevents duplicate submits).
class _SubmittingOverlay extends StatelessWidget {
  const _SubmittingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(context.l10n.submittingTest, style: AppTextStyles.label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
