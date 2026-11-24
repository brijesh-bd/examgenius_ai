import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../subscription/domain/subscription_models.dart';
import '../../domain/generated_question.dart';

/// Small FREE / PREMIUM pill for the app bar.
class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: isPro ? AppColors.aiGradient : null,
        color: isPro
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPro) ...[
            const Icon(
              Icons.workspace_premium_rounded,
              size: 14,
              color: AppColors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            isPro ? l10n.planBadgePro : l10n.planBadgeFree,
            style: AppTextStyles.tiny.copyWith(
              fontWeight: AppFontWeights.bold,
              color: isPro ? AppColors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// "1 of 2 practice sets left today · AI sets left today: 1".
class UsageStrip extends StatelessWidget {
  const UsageStrip({super.key, required this.status});
  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final sets = status.setsLeftToday != null
        ? l10n.usageSetsLeft(status.setsLeftToday!, status.limits.setsPerDay!)
        : status.questionsLeftToday != null
        ? l10n.usageQuestionsLeft(status.questionsLeftToday!)
        : null;
    final ai = !status.limits.aiIncluded
        ? null
        : status.aiSetsLeftToday == null
        ? l10n.aiCreditsIncluded
        : l10n.aiCreditsLeft(status.aiSetsLeftToday!);
    final style = AppTextStyles.caption.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 4,
      children: [
        if (sets != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(sets, style: style),
            ],
          ),
        if (ai != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              const SizedBox(width: 4),
              Text(ai, style: style),
            ],
          ),
      ],
    );
  }
}

/// Section heading.
class SetupLabel extends StatelessWidget {
  const SetupLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text, style: AppTextStyles.labelBold),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Compact quick-start tile (one of three in a row).
class QuickStartTile extends StatelessWidget {
  const QuickStartTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(14);
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color.withValues(alpha: 0.25)),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTextStyles.labelBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tiny.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two side-by-side choice cards (practice type, question source).
class ChoiceCards<T> extends StatelessWidget {
  const ChoiceCards({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<
    ({T value, IconData icon, String title, String hint, Widget? badge})
  >
  options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, o) in options.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Semantics(
                selected: o.value == value,
                button: true,
                child: Material(
                  color: o.value == value
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : scheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: o.value == value
                          ? AppColors.primary
                          : scheme.outlineVariant,
                      width: o.value == value ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChanged(o.value),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            o.icon,
                            size: 20,
                            color: o.value == value
                                ? AppColors.primary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        o.title,
                                        style: AppTextStyles.labelBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (o.badge != null) ...[
                                      const SizedBox(width: 4),
                                      o.badge!,
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  o.hint,
                                  style: AppTextStyles.tiny.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Count presets 5/10/20/30/40 (above the plan maximum: locked), plus a
/// "Custom" chip when the plan allows any count up to its maximum.
class CountPresets extends StatelessWidget {
  const CountPresets({
    super.key,
    required this.value,
    required this.max,
    required this.customAllowed,
    required this.onChanged,
    required this.onLocked,
  });

  final int value;
  final int max;
  final bool customAllowed;
  final ValueChanged<int> onChanged;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCustom = !kQuestionCountOptions.contains(value);
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final n in kQuestionCountOptions)
          if (n > max)
            ActionChip(
              avatar: const Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppColors.accent,
              ),
              label: Text('$n'),
              tooltip: l10n.proLocked,
              onPressed: onLocked,
            )
          else
            ChoiceChip(
              label: Text('$n'),
              selected: value == n,
              onSelected: (_) => onChanged(n),
            ),
        if (customAllowed)
          ChoiceChip(
            avatar: isCustom ? null : const Icon(Icons.tune_rounded, size: 16),
            label: Text(
              isCustom ? '${l10n.customCount}: $value' : l10n.customCount,
            ),
            selected: isCustom,
            onSelected: (_) async {
              final n = await showCustomCountDialog(
                context,
                initial: value,
                max: max,
              );
              if (n != null) onChanged(n);
            },
          ),
      ],
    );
  }
}

Future<int?> showCustomCountDialog(
  BuildContext context, {
  required int initial,
  required int max,
}) {
  final l10n = context.l10n;
  final ctl = TextEditingController(text: '$initial');
  return showDialog<int>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (dialog, setState) {
        final n = int.tryParse(ctl.text);
        final valid = n != null && n >= 1 && n <= max;
        return AlertDialog(
          title: Text(l10n.customCountTitle),
          content: TextField(
            controller: ctl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(helperText: l10n.customCountHint(max)),
            onChanged: (_) => setState(() {}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: valid ? () => Navigator.pop(dialog, n) : null,
              child: Text(l10n.apply),
            ),
          ],
        );
      },
    ),
  );
}

/// Fixed bottom bar: validation hint (when something is missing) + button
/// labelled with the count and source.
class GenerateBar extends StatelessWidget {
  const GenerateBar({
    super.key,
    required this.label,
    required this.hint,
    required this.busy,
    required this.onPressed,
  });

  final String label;

  /// Shown above the button when the form is incomplete (null = ready).
  final String? hint;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surface,
      shadowColor: AppColors.cardShadow,
      child: SafeArea(
        top: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hint != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hint!,
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              PrimaryButton(
                label: label,
                icon: busy ? null : Icons.play_arrow_rounded,
                loading: busy,
                onPressed: hint == null && !busy ? onPressed : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
