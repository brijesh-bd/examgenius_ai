import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/practice_models.dart';
import 'option_tile.dart';

/// One question with its four lettered options. Shows only what the student
/// chose — never right/wrong (that comes after submission).
class PracticeQuestionCard extends StatelessWidget {
  const PracticeQuestionCard({
    super.key,
    required this.question,
    required this.number,
    required this.selected,
    required this.onSelect,
  });

  final PracticeQuestion question;
  final int number;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.questionNumber(number),
                  style: AppTextStyles.labelBold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question.topicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question.text,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: AppFontSizes.lg + 1,
              fontWeight: AppFontWeights.semiBold,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.selectOptionHint,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < question.options.length; i++) ...[
            OptionTile(
              letter: letters[i % letters.length],
              text: question.options[i],
              selected: selected == i,
              onTap: () => onSelect(i),
            ),
            if (i < question.options.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
