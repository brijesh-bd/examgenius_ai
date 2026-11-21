import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../utils/l10n_ext.dart';

/// Centers content and caps its width on large screens.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Brand mark: graduation cap over an open book with a gold sparkle.
/// [onDark] renders it inside a white rounded tile (app-icon style).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final capColor = isDark && !onDark ? Colors.white : AppColors.navy;
    final mark = CustomPaint(
      size: Size.square(size),
      painter: _LogoPainter(capColor: capColor),
    );
    if (!onDark) return ExcludeSemantics(child: mark);
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(size * 0.14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.1),
            ),
          ],
        ),
        child: mark,
      ),
    );
  }
}

/// Vector brand mark in a 100×100 design space.
class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.capColor});
  final Color capColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Open book: three fanned page layers on each side of the spine.
    const pageColors = AppColors.logoPages;
    for (var i = 0; i < 3; i++) {
      stroke
        ..color = pageColors[i]
        ..strokeWidth = 5.5;
      final dy = i * 7.0;
      canvas.drawPath(
        Path()
          ..moveTo(50, 86 - dy)
          ..quadraticBezierTo(30, 70 - dy, 6, 76 - dy * 1.25),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(50, 86 - dy)
          ..quadraticBezierTo(70, 70 - dy, 94, 76 - dy * 1.25),
        stroke,
      );
    }

    // Orange swoosh across the book.
    stroke
      ..color = AppColors.secondary
      ..strokeWidth = 4.5;
    canvas.drawPath(
      Path()
        ..moveTo(18, 80)
        ..quadraticBezierTo(56, 70, 90, 44),
      stroke,
    );

    // Mortarboard.
    final fill = Paint()..color = capColor;
    canvas.drawPath(
      Path()
        ..moveTo(32, 36)
        ..lineTo(68, 36)
        ..lineTo(68, 50)
        ..quadraticBezierTo(50, 58, 32, 50)
        ..close(),
      fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(50, 12)
        ..lineTo(88, 28)
        ..lineTo(50, 44)
        ..lineTo(12, 28)
        ..close(),
      fill,
    );
    // Tassel.
    stroke
      ..color = AppColors.secondary
      ..strokeWidth = 2;
    canvas.drawPath(
      Path()
        ..moveTo(50, 28)
        ..lineTo(80, 31)
        ..lineTo(80, 46),
      stroke,
    );
    canvas.drawCircle(const Offset(80, 48), 3, Paint()..color = AppColors.secondary);

    // Four-point sparkle.
    const c = Offset(90, 12);
    const r = 8.0, w = 2.2;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx + w * 0.4, c.dy - w * 0.4, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx + w * 0.4, c.dy + w * 0.4, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx - w * 0.4, c.dy + w * 0.4, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx - w * 0.4, c.dy - w * 0.4, c.dx, c.dy - r)
        ..close(),
      Paint()..color = AppColors.gold,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.capColor != capColor;
}

/// Logo + "ExamGenius" + purple "AI" badge, with optional tagline.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.logoSize = 72,
    this.fontSize = 28,
    this.showTagline = true,
    this.taglineSize = 15,
    this.decoratedTagline = false,
  });

  final double logoSize;
  final double fontSize;
  final bool showTagline;
  final double taglineSize;

  /// Adds the orange rules on either side of the tagline.
  final bool decoratedTagline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wordColor = isDark ? Colors.white : AppColors.navy;
    final tagline = Text(
      l10n.appTagline,
      textAlign: TextAlign.center,
      style: AppTextStyles.tagline(
          taglineSize, isDark ? Colors.white70 : AppColors.navy.withValues(alpha: 0.85)),
    );
    Widget rule() => Container(
          width: fontSize * 0.6,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: AppColors.secondary,
        );

    return Semantics(
      label: l10n.appName,
      container: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: logoSize),
            SizedBox(height: logoSize * 0.08),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ExamGenius',
                    style: AppTextStyles.wordmark(fontSize, wordColor)
                        .copyWith(fontWeight: AppFontWeights.extraBold, letterSpacing: -0.5),
                  ),
                  SizedBox(width: fontSize * 0.2),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: fontSize * 0.22, vertical: fontSize * 0.02),
                    decoration: BoxDecoration(
                      gradient: AppColors.aiBadgeGradient,
                      borderRadius: BorderRadius.circular(fontSize * 0.22),
                    ),
                    child: Text(
                      'AI',
                      style: AppTextStyles.wordmark(fontSize * 0.85, Colors.white)
                          .copyWith(fontWeight: AppFontWeights.extraBold, letterSpacing: 0),
                    ),
                  ),
                ],
              ),
            ),
            if (showTagline) ...[
              SizedBox(height: fontSize * 0.3),
              decoratedTagline
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [rule(), Flexible(child: tagline), rule()],
                    )
                  : tagline,
            ],
          ],
        ),
      ),
    );
  }
}

/// Filled button that shows a spinner and blocks taps while [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
            ],
          );
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}

/// Section title with optional trailing action (e.g. "See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Shimmering placeholder block used for loading skeletons.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height = 16, this.width, this.radius = 12});

  final double height;
  final double? width;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Generic empty / error state with icon, message and optional action.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, size: 30, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
