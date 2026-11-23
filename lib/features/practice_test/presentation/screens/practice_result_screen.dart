import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../question_generator/domain/generated_question.dart';
import '../../domain/practice_result.dart';
import '../widgets/result_charts.dart';
import '../widgets/test_timer_chip.dart';

/// Screen 3 — Final Result & Scorecard. Displays the backend's scored result.
class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({super.key, required this.result});

  final PracticeResult? result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = result;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: StateMessage(icon: Icons.quiz_outlined, title: l10n.errorGeneric),
      );
    }
    // System back returns to the previous screen (the test itself was
    // replaced by this one); only with nothing to go back to → dashboard.
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ResultHeader(result: r)),
            SliverToBoxAdapter(
              child: ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScoreGrid(result: r),
                    const SizedBox(height: 16),
                    _Section(
                      icon: Icons.donut_large_rounded,
                      title: l10n.answerBreakdown,
                      child: AnswerBreakdownBar(result: r),
                    ),
                    const SizedBox(height: 16),
                    _TimeRow(result: r),
                    const SizedBox(height: 16),
                    _PerformanceSection(result: r),
                    const SizedBox(height: 20),
                    _Actions(result: r),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient header: title, exam, subjects, date, final score + accuracy ring.
class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result});
  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = result;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale).add_jm().format(r.completedAt);
    final white90 = AppColors.white.withValues(alpha: 0.9);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    r.isGoodResult
                        ? Icons.emoji_events_rounded
                        : Icons.task_alt_rounded,
                    color: AppColors.gold,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        r.isGoodResult
                            ? l10n.congratulations
                            : l10n.testCompleted,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${r.examName} · ${r.subjects.join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(color: AppColors.white),
              ),
              Text(
                l10n.completedOn(date),
                style: AppTextStyles.bodySmall.copyWith(color: white90),
              ),
              if (r.autoSubmitted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_off_outlined,
                        color: AppColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.autoSubmittedNote,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.finalScore,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: white90,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: scoreText(r.score),
                                  style: AppTextStyles.h1.copyWith(
                                    color: AppColors.white,
                                    fontSize: AppFontSizes.hero,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${scoreText(r.maxScore)}',
                                  style: AppTextStyles.h3.copyWith(
                                    color: white90,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          l10n.markingScheme,
                          style: AppTextStyles.caption.copyWith(color: white90),
                        ),
                      ],
                    ),
                  ),
                  AccuracyRing(value: r.accuracy, size: 108, onDark: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six equal score cards (3 per row on phones, 6 on wide screens).
class _ScoreGrid extends StatelessWidget {
  const _ScoreGrid({required this.result});
  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = result;
    final cards = [
      ScoreStatCard(
        icon: Icons.list_alt_rounded,
        value: '${r.total}',
        label: l10n.totalQuestions,
        color: AppColors.primary,
      ),
      ScoreStatCard(
        icon: Icons.check_circle_rounded,
        value: '${r.correct}',
        label: l10n.correctAnswers,
        color: AppColors.success,
      ),
      ScoreStatCard(
        icon: Icons.cancel_rounded,
        value: '${r.incorrect}',
        label: l10n.incorrectAnswers,
        color: AppColors.error,
      ),
      ScoreStatCard(
        icon: Icons.remove_circle_outline_rounded,
        value: '${r.unattempted}',
        label: l10n.unattempted,
        color: AppColors.textMuted,
      ),
      ScoreStatCard(
        icon: Icons.emoji_events_rounded,
        value: scoreText(r.score),
        label: l10n.finalScore,
        color: AppColors.secondary,
      ),
      ScoreStatCard(
        icon: Icons.track_changes_rounded,
        value: percentText(r.accuracy),
        label: l10n.accuracyLabel,
        color: AppColors.accent,
      ),
    ];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (_, c) => GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: c.maxWidth >= 600 ? 6 : 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // Icon + padding are fixed; value and a 2-line label scale with text.
          mainAxisExtent: 66 + 66 * textScale,
        ),
        children: cards,
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.result});
  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tile(IconData icon, String label, String value, Color color) =>
        Expanded(
          child: _Section(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: AppTextStyles.h3),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tile(
            Icons.timer_outlined,
            l10n.timeTaken,
            formatCountdown(result.timeTaken),
            AppColors.primary,
          ),
          const SizedBox(width: 12),
          tile(
            Icons.speed_rounded,
            l10n.avgPerQuestion,
            formatCountdown(result.averagePerQuestion),
            AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.result});
  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = result;
    final weak = r.weakTopics;
    final recommendations = <String>[
      for (final t in weak)
        l10n.recommendRevise(t.topicName, t.correct, t.total),
      if (weak.isEmpty && r.isGoodResult && r.difficulty != Difficulty.hard)
        l10n.recommendNextLevel,
      if (weak.isEmpty && !(r.isGoodResult && r.difficulty != Difficulty.hard))
        l10n.recommendKeepGoing,
    ];

    return _Section(
      icon: Icons.insights_rounded,
      title: l10n.performanceAnalysis,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopicChips(
            title: l10n.strongTopics,
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
            topics: r.strongTopics.map((t) => t.topicName).toList(),
          ),
          const SizedBox(height: 12),
          _TopicChips(
            title: l10n.weakTopics,
            icon: Icons.trending_down_rounded,
            color: AppColors.error,
            topics: weak.map((t) => t.topicName).toList(),
          ),
          const Divider(height: 28),
          Text(l10n.topicWiseAccuracy, style: AppTextStyles.labelBold),
          const SizedBox(height: 12),
          TopicAccuracyList(topics: r.topicsByAccuracy),
          const Divider(height: 20),
          Text(l10n.recommendedPractice, style: AppTextStyles.labelBold),
          const SizedBox(height: 10),
          for (final text in recommendations)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopicChips extends StatelessWidget {
  const _TopicChips({
    required this.title,
    required this.icon,
    required this.color,
    required this.topics,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 6),
        if (topics.isEmpty)
          Text(l10n.noneYet, style: AppTextStyles.caption)
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in topics)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    t,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: AppFontWeights.semiBold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// The result actions: review, open Library (auto-saved), dashboard.
class _Actions extends StatelessWidget {
  const _Actions({required this.result});
  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ButtonStyle tall(Color c) => FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      backgroundColor: c,
      foregroundColor: AppColors.white,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: tall(AppColors.primary),
          onPressed: () =>
              context.push(AppRoutes.practiceReview, extra: result),
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(l10n.reviewAnswers),
        ),
        const SizedBox(height: 10),
        // Every generated set is saved to the Library automatically.
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () => context.go(AppRoutes.savedPractice),
          icon: const Icon(Icons.cloud_done_rounded, color: AppColors.success),
          label: Text(l10n.openLibrary),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.savedToLibrary,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.home_rounded),
          label: Text(l10n.backToDashboard),
        ),
      ],
    );
  }
}

/// White rounded card with optional icon + title.
class _Section extends StatelessWidget {
  const _Section({required this.child, this.title, this.icon});

  final Widget child;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title!,
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: AppFontSizes.lg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
