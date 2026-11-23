import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../practice_test/presentation/widgets/result_charts.dart';
import '../../../question_generator/presentation/widgets/generator_options.dart';
import '../../domain/library_models.dart';

/// One saved practice set: exam, subjects, topics, questions, difficulty,
/// language, date, latest score / attempt status — plus Review, Practice
/// Again, History and Delete.
class LibrarySetCard extends StatelessWidget {
  const LibrarySetCard({
    super.key,
    required this.set,
    required this.onReview,
    required this.onPracticeAgain,
    required this.onHistory,
    required this.onDelete,
  });

  final LibrarySet set;
  final VoidCallback onReview;
  final VoidCallback onPracticeAgain;
  final VoidCallback onHistory;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final s = set;
    final st = s.stats;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale).add_jm().format(s.createdAt);
    const maxTopics = 3;
    final extra = s.topics.length - maxTopics;

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
                        s.examName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: AppFontSizes.lg,
                        ),
                      ),
                      Text(
                        s.subjects.map((x) => x.name).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (st.attempted && st.latestAccuracy != null)
                  AccuracyRing(value: st.latestAccuracy!, size: 52)
                else
                  _StatusPill(label: l10n.notAttempted),
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
                    for (final t in s.topics.take(maxTopics))
                      _Chip(label: t.name),
                    if (extra > 0) _Chip(label: '+$extra'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Fact(
                      icon: Icons.signal_cellular_alt_rounded,
                      value: s.difficulty.label(l10n),
                      color: s.difficulty.color,
                    ),
                    _Fact(
                      icon: Icons.list_alt_rounded,
                      value: l10n.questionsShort(s.questionCount),
                      color: AppColors.primary,
                    ),
                    _Fact(
                      icon: Icons.translate_rounded,
                      value: s.language == 'hi' ? l10n.hindi : l10n.english,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                    if (st.attempted)
                      Text(
                        '${l10n.latestScore}: '
                        '${scoreText(st.latestScore ?? 0)}/'
                        '${scoreText(st.latestMaxScore ?? 0)}'
                        ' · ${l10n.attemptsCount(st.attempts)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: AppFontWeights.semiBold,
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
                      icon: Icons.history_rounded,
                      label: l10n.viewHistory,
                      color: AppColors.secondary,
                      onTap: onHistory,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: AppFontWeights.semiBold,
        ),
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
  const _Fact({required this.icon, required this.value, required this.color});

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: value,
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
