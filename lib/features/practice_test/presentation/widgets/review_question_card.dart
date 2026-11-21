import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/practice_result.dart';
import 'practice_question_card.dart';

/// One reviewed question: number + status, question text, the four options
/// coloured (correct = green, the student's wrong pick = red), answer summary
/// and the explanation panel.
class ReviewQuestionCard extends StatelessWidget {
  const ReviewQuestionCard({
    super.key,
    required this.number,
    required this.review,
  });

  final int number;
  final QuestionReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final r = review;
    const letters = PracticeQuestionCard.letters;
    String opt(int i) => '${letters[i]}. ${r.options[i]}';

    final (statusLabel, statusColor, statusIcon) = switch (r.status) {
      ReviewStatus.correct => (
        l10n.statusCorrect,
        AppColors.success,
        Icons.check_circle_rounded,
      ),
      ReviewStatus.incorrect => (
        l10n.statusIncorrect,
        AppColors.error,
        Icons.cancel_rounded,
      ),
      ReviewStatus.unattempted => (
        l10n.statusUnattempted,
        scheme.outline,
        Icons.remove_circle_outline_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
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
                  r.topicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              _StatusPill(
                label: statusLabel,
                color: statusColor,
                icon: statusIcon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.question,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: AppFontWeights.semiBold,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            ReviewOptionTile(
              letter: letters[i],
              text: r.options[i],
              state: i == r.correctIndex
                  ? ReviewOptionState.correct
                  : (i == r.selectedIndex
                        ? ReviewOptionState.wrong
                        : ReviewOptionState.neutral),
              isStudentChoice: i == r.selectedIndex,
            ),
            if (i < r.options.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          _AnswerSummary(
            yours: r.attempted ? opt(r.selectedIndex!) : l10n.notAnswered,
            yoursColor: switch (r.status) {
              ReviewStatus.correct => AppColors.success,
              ReviewStatus.incorrect => AppColors.error,
              ReviewStatus.unattempted => scheme.outline,
            },
            correct: opt(r.correctIndex),
          ),
          const SizedBox(height: 12),
          ExplanationPanel(
            review: r,
            note: switch (r.status) {
              ReviewStatus.correct => null,
              ReviewStatus.incorrect => l10n.wrongChoiceNote(
                letters[r.selectedIndex!],
                letters[r.correctIndex],
              ),
              ReviewStatus.unattempted => l10n.unattemptedNote(
                letters[r.correctIndex],
              ),
            },
          ),
        ],
      ),
    );
  }
}

enum ReviewOptionState { correct, wrong, neutral }

/// Option row in review mode. Never interactive.
class ReviewOptionTile extends StatelessWidget {
  const ReviewOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.isStudentChoice,
  });

  final String letter;
  final String text;
  final ReviewOptionState state;
  final bool isStudentChoice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (state) {
      ReviewOptionState.correct => AppColors.success,
      ReviewOptionState.wrong => AppColors.error,
      ReviewOptionState.neutral => scheme.outlineVariant,
    };
    final highlighted = state != ReviewOptionState.neutral;
    final label = switch (state) {
      ReviewOptionState.correct => l10n.optionCorrectLabel(letter, text),
      ReviewOptionState.wrong => l10n.optionWrongLabel(letter, text),
      ReviewOptionState.neutral => l10n.optionLabel(letter, text),
    };

    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted ? color.withValues(alpha: 0.08) : scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: highlighted ? 1.8 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlighted ? color : scheme.surfaceContainerHighest,
                ),
                child: Text(
                  letter,
                  style: AppTextStyles.labelBold.copyWith(
                    color: highlighted
                        ? AppColors.white
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: scheme.onSurface,
                    fontWeight: highlighted
                        ? AppFontWeights.semiBold
                        : AppFontWeights.regular,
                  ),
                ),
              ),
              if (state == ReviewOptionState.correct)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              if (state == ReviewOptionState.wrong)
                const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              if (isStudentChoice) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your answer / Correct answer" summary row.
class _AnswerSummary extends StatelessWidget {
  const _AnswerSummary({
    required this.yours,
    required this.yoursColor,
    required this.correct,
  });

  final String yours;
  final Color yoursColor;
  final String correct;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget cell(String label, String value, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(l10n.yourAnswer, yours, yoursColor),
          const SizedBox(width: 8),
          cell(l10n.correctAnswerLabel, correct, AppColors.success),
        ],
      ),
    );
  }
}

/// Explanation, maths formula + steps, short concept and learning tip.
/// Sections without backend data are hidden.
class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({super.key, required this.review, this.note});

  final QuestionReview review;

  /// Why-wrong / skipped note shown above the explanation.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final r = review;
    final correct = r.status == ReviewStatus.correct;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading(
            icon: correct ? Icons.verified_rounded : Icons.help_center_outlined,
            text: correct
                ? l10n.whyCorrect
                : (r.attempted ? l10n.whyWrong : l10n.explanationTitle),
            color: correct ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(height: 6),
          if (note != null) ...[
            Text(
              note!,
              style: AppTextStyles.bodySmall.copyWith(
                color: r.attempted ? AppColors.error : scheme.onSurfaceVariant,
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (r.wrongReason != null && r.status == ReviewStatus.incorrect) ...[
            Text(r.wrongReason!, style: AppTextStyles.body),
            const SizedBox(height: 8),
          ],
          if (r.formula != null) ...[
            _Heading(
              icon: Icons.functions_rounded,
              text: l10n.formulaTitle,
              color: AppColors.accent,
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                r.formula!,
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (r.steps.isNotEmpty) ...[
            _Heading(
              icon: Icons.format_list_numbered_rounded,
              text: l10n.stepByStep,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            for (final (i, step) in r.steps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Semantics(
                        label: l10n.stepLabel(i + 1),
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.white,
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: AppTextStyles.body.copyWith(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            Text(
              r.explanation,
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          if (r.concept != null) ...[
            const SizedBox(height: 10),
            _InfoBlock(
              icon: Icons.school_outlined,
              title: l10n.conceptTitle,
              text: r.concept!,
              color: AppColors.primary,
            ),
          ],
          if (r.tip != null) ...[
            const SizedBox(height: 10),
            _InfoBlock(
              icon: Icons.lightbulb_outline_rounded,
              title: l10n.tipTitle,
              text: r.tip!,
              color: AppColors.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.labelBold.copyWith(color: color),
        ),
      ),
    ],
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelBold),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: AppTextStyles.bodySmall.copyWith(height: 1.45),
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
  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: AppFontWeights.bold,
            ),
          ),
        ],
      ),
    );
  }
}
