import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Lettered answer option. Selected = brand-blue border, tint and filled
/// letter badge. Tapping another option changes the answer.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const accent = AppColors.primary;
    final radius = BorderRadius.circular(14);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: context.l10n.optionLabel(letter, text),
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.08)
                    : scheme.surface,
                borderRadius: radius,
                border: Border.all(
                  color: selected ? accent : scheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? accent : accent.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      letter,
                      style: AppTextStyles.labelBold.copyWith(
                        color: selected ? AppColors.white : accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: scheme.onSurface,
                        fontWeight: selected
                            ? AppFontWeights.semiBold
                            : AppFontWeights.regular,
                      ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: accent,
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
