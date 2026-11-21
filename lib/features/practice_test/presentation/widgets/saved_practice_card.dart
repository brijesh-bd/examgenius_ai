import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../question_generator/presentation/widgets/generator_options.dart';
import '../../domain/saved_practice.dart';
import 'result_charts.dart';

/// One saved practice set: exam, subject, topics, difficulty, question count,
/// score, accuracy, date — plus Review / Practice Again / Retry Wrong / Delete.
class SavedPracticeCard extends StatelessWidget {
  const SavedPracticeCard({
    super.key,
    required this.saved,
    required this.onReview,
    required this.onPracticeAgain,
    required this.onRetryWrong,
    required this.onDelete,
  });

  final SavedPractice saved;
  final VoidCallback onReview;
  final VoidCallback onPracticeAgain;

  /// `null` when the attempt had no wrong answers.
  final VoidCallback? onRetryWrong;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final r = saved.result;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale).add_jm().format(r.completedAt);
    const maxTopics = 3;
    final extra = r.topics.length - maxTopics;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          // Accent strip + header.
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppColors.aiGradient,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.examName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: AppFontSizes.lg,
                        ),
                      ),
                      Text(
                        r.subjects.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AccuracyRing(value: r.accuracy, size: 56),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in r.topics.take(maxTopics)) _Chip(label: t),
                    if (extra > 0) _Chip(label: '+$extra'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Fact(
                      icon: Icons.signal_cellular_alt_rounded,
                      value: r.difficulty.label(l10n),
                      color: r.difficulty.color,
                    ),
                    _Fact(
                      icon: Icons.list_alt_rounded,
                      value: l10n.questionsShort(r.total),
                      color: AppColors.primary,
                    ),
                    _Fact(
                      icon: Icons.emoji_events_rounded,
                      value: '${scoreText(r.score)}/${scoreText(r.maxScore)}',
                      color: AppColors.secondary,
                      semantic: l10n.scoreLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        date,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    _Action(
                      icon: Icons.fact_check_outlined,
                      label: l10n.reviewPractice,
                      color: AppColors.primary,
                      onTap: onReview,
                    ),
                    _Action(
                      icon: Icons.restart_alt_rounded,
                      label: l10n.practiceAgain,
                      color: AppColors.accent,
                      onTap: onPracticeAgain,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _Action(
                      icon: Icons.replay_rounded,
                      label: l10n.retryWrongShort,
                      color: AppColors.secondary,
                      onTap: onRetryWrong,
                    ),
                    _Action(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.deletePractice,
                      color: AppColors.error,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: AppFontWeights.semiBold,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.value,
    required this.color,
    this.semantic,
  });

  final IconData icon;
  final String value;
  final Color color;
  final String? semantic;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: semantic == null ? value : '$semantic $value',
        child: ExcludeSemantics(
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    fontSize: AppFontSizes.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: color,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
