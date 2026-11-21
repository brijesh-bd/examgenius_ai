import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';

/// mm:ss (or h:mm:ss) for a countdown.
String formatCountdown(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = d.inHours,
      m = d.inMinutes.remainder(60),
      s = d.inSeconds.remainder(60);
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Countdown pill for the app bar; turns red in the final minute.
class TestTimerChip extends StatelessWidget {
  const TestTimerChip({super.key, required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final low = remaining <= const Duration(minutes: 1);
    final color = low ? AppColors.error : AppColors.primary;
    final text = formatCountdown(remaining);
    return Semantics(
      label: context.l10n.timeLeftLabel(text),
      liveRegion: low,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: AppTextStyles.labelBold.copyWith(
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
