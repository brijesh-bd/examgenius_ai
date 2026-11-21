import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import 'test_timer_chip.dart';

/// Screen 2 — "Are you sure you want to submit your test?" with the test
/// summary. Resolves to `true` only when the student taps Submit Test.
Future<bool> showSubmitConfirmationDialog(
  BuildContext context, {
  required int total,
  required int answered,
  Duration? remaining,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => SubmitConfirmationDialog(
      total: total,
      answered: answered,
      remaining: remaining,
    ),
  );
  return ok ?? false;
}

class SubmitConfirmationDialog extends StatelessWidget {
  const SubmitConfirmationDialog({
    super.key,
    required this.total,
    required this.answered,
    this.remaining,
  });

  final int total;
  final int answered;
  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final unanswered = total - answered;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.aiGradient,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  l10n.submitConfirmTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.submitConfirmBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Stat(
                      icon: Icons.list_alt_rounded,
                      label: l10n.totalQuestions,
                      value: '$total',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _Stat(
                      icon: Icons.check_circle_rounded,
                      label: l10n.answeredQuestions,
                      value: '$answered',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _Stat(
                      icon: Icons.help_outline_rounded,
                      label: l10n.unansweredQuestions,
                      value: '$unanswered',
                      color: unanswered > 0 ? AppColors.error : scheme.outline,
                    ),
                  ],
                ),
              ),
              if (remaining != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.timeRemaining,
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        formatCountdown(remaining!),
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.accent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                unanswered > 0
                    ? l10n.submitWarningUnanswered
                    : l10n.submitNoChanges,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: unanswered > 0
                      ? AppColors.error
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(
                        l10n.submitTest,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
