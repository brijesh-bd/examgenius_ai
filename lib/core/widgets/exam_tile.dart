import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// Responsive grid of equal-height [ExamTile]s: 3 columns on phones, 6 on
/// wide screens. Height grows with the text scale so nothing overflows.
class ExamTileGrid extends StatelessWidget {
  const ExamTileGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) => GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: c.maxWidth >= 600 ? 6 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          // Fixed chrome (icon, arrow, padding) + two lines of scaled text.
          mainAxisExtent: 100 + 72 * textScale,
        ),
        children: children,
      ),
    );
  }
}

/// Tinted card: round icon, title, subtitle, soft bottom waves and an arrow
/// (or a check mark when [selected] is non-null).
class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.selected,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  /// `null` = navigation card (arrow); true/false = selectable card (check).
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isOn = selected ?? false;
    final surface = scheme.surface;
    final bg = Color.lerp(surface, color, isOn ? 0.22 : (isDark ? 0.18 : 0.10))!;
    final bgTop = Color.lerp(surface, color, isDark ? 0.10 : 0.04)!;
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: color.withValues(alpha: isOn ? 1 : 0.45),
                width: isOn ? 2 : 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bg],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _WavePainter(color))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tileTitle.copyWith(
                            fontSize: AppFontSizes.md,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: AppFontSizes.xxs + 0.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isOn ? color : scheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              selected == null
                                  ? Icons.arrow_forward_rounded
                                  : (isOn ? Icons.check_rounded : Icons.add_rounded),
                              size: 15,
                              color: isOn ? Colors.white : color,
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
      ),
    );
  }
}

/// Two soft overlapping waves along the bottom of each tile.
class _WavePainter extends CustomPainter {
  _WavePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Path wave(double a, double b, double c) => Path()
      ..moveTo(0, h * a)
      ..quadraticBezierTo(w * 0.32, h * b, w * 0.62, h * c)
      ..quadraticBezierTo(w * 0.85, h * (c + 0.09), w, h * (a + 0.02))
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave(0.72, 0.62, 0.77), Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawPath(wave(0.84, 0.76, 0.90), Paint()..color = color.withValues(alpha: 0.22));
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.color != color;
}
