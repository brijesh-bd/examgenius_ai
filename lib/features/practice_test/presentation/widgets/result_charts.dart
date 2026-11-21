import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/practice_result.dart';

/// "78%" style percentage.
String percentText(double v) => '${(v * 100).round()}%';

/// Score with up to two decimals, no trailing ".00" (e.g. 7.75, 8).
String scoreText(double v) => v == v.roundToDouble()
    ? v.toStringAsFixed(0)
    : v.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');

/// Equal-size stat tile: icon, big value, label.
class ScoreStatCard extends StatelessWidget {
  const ScoreStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label: $value',
      container: true,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTextStyles.h3.copyWith(color: scheme.onSurface),
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular accuracy chart: track + progress arc with rounded end, the
/// percentage in the middle. Animates in once.
class AccuracyRing extends StatelessWidget {
  const AccuracyRing({
    super.key,
    required this.value,
    this.size = 120,
    this.onDark = false,
  });

  /// 0..1
  final double value;
  final double size;

  /// Render for a gradient/dark background (white text and track).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = percentText(value);
    final fg = onDark ? AppColors.white : scheme.onSurface;
    return Semantics(
      label: l10n.accuracyChartLabel(text),
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _RingPainter(
                value: v,
                track: onDark
                    ? AppColors.white.withValues(alpha: 0.25)
                    : scheme.surfaceContainerHighest,
                color: onDark ? AppColors.white : AppColors.success,
                stroke: size * 0.1,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentText(v),
                      style: AppTextStyles.h2.copyWith(
                        color: fg,
                        fontSize: size * 0.22,
                      ),
                    ),
                    Text(
                      l10n.accuracyLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: onDark
                            ? AppColors.white.withValues(alpha: 0.9)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.track,
    required this.color,
    required this.stroke,
  });

  final double value;
  final Color track;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        p..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Part-to-whole bar: correct / incorrect / unattempted, 2 px gaps between
/// segments, plus a labelled legend with counts (never colour alone).
class AnswerBreakdownBar extends StatelessWidget {
  const AnswerBreakdownBar({super.key, required this.result});

  final PracticeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final parts = [
      (
        l10n.correctAnswers,
        result.correct,
        AppColors.success,
        Icons.check_circle_rounded,
      ),
      (
        l10n.incorrectAnswers,
        result.incorrect,
        AppColors.error,
        Icons.cancel_rounded,
      ),
      (
        l10n.unattempted,
        result.unattempted,
        scheme.outline,
        Icons.remove_circle_outline_rounded,
      ),
    ];
    final visible = parts.where((p) => p.$2 > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: parts.map((p) => '${p.$1} ${p.$2}').join(', '),
          child: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: [
                    for (var i = 0; i < visible.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: visible[i].$2,
                        child: ColoredBox(
                          color: visible[i].$3,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                    if (visible.isEmpty)
                      Expanded(
                        child: ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final p in parts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(p.$4, size: 16, color: p.$3),
                  const SizedBox(width: 6),
                  Text('${p.$1} ', style: AppTextStyles.bodySmall),
                  Text('${p.$2}', style: AppTextStyles.labelBold),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// One horizontal bar per topic (single hue, rounded end), value as text.
class TopicAccuracyList extends StatelessWidget {
  const TopicAccuracyList({super.key, required this.topics});

  final List<TopicStat> topics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final t in topics)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Semantics(
              label:
                  '${t.topicName}: ${percentText(t.accuracy)}, '
                  '${l10n.topicScore(t.correct, t.total)}',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.topicName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          l10n.topicScore(t.correct, t.total),
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text(
                            percentText(t.accuracy),
                            textAlign: TextAlign.end,
                            style: AppTextStyles.labelBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (_, c) => Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: t.accuracy),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => Container(
                              height: 8,
                              width: c.maxWidth * v,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
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
      ],
    );
  }
}
