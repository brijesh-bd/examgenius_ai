import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../question_generator/presentation/widgets/generator_options.dart';
import '../providers/practice_providers.dart';

/// Brand-gradient summary card: subject, topics, difficulty, question
/// position and answered progress.
class TestHeader extends StatelessWidget {
  const TestHeader({super.key, required this.state});

  final PracticeTestState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state.session;
    const maxTopics = 2;
    final extraTopics = s.topics.length - maxTopics;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: AppColors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.subjects.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.white,
                    fontSize: AppFontSizes.lg,
                  ),
                ),
              ),
              _Pill(
                label: s.difficulty.label(l10n),
                color: s.difficulty.color,
                filled: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in s.topics.take(maxTopics)) _Pill(label: t),
              if (extraTopics > 0) _Pill(label: '+$extraTopics'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.questionOfTotal(state.current + 1, state.total),
                  style: AppTextStyles.label.copyWith(color: AppColors.white),
                ),
              ),
              Text(
                l10n.answeredOfTotal(state.answeredCount, state.total),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                end: state.total == 0 ? 0 : state.answeredCount / state.total,
              ),
              duration: const Duration(milliseconds: 300),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                color: AppColors.white,
                backgroundColor: AppColors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.color, this.filled = false});

  final String label;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.tiny.copyWith(
          fontSize: AppFontSizes.xs,
          fontWeight: AppFontWeights.semiBold,
          color: filled ? (color ?? AppColors.primary) : AppColors.white,
        ),
      ),
    );
  }
}
