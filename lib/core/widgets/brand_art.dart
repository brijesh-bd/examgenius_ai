import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

// Brand artwork shared by splash and auth screens, drawn in code (no image
// assets). All colours come from AppColors.

/// Full-screen corner waves (top-left + bottom). [soft] draws only the pale
/// lavender layers used behind forms.
class BrandCornerWaves extends StatelessWidget {
  const BrandCornerWaves({super.key, this.soft = false});
  final bool soft;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CornerWavesPainter(soft: soft),
    size: Size.infinite,
  );
}

/// Blue mortarboard over a gold open book.
class CapBookLogo extends StatelessWidget {
  const CapBookLogo({super.key, this.width = 150});
  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * 0.8),
      painter: const _CapBookLogoPainter(),
    ),
  );
}

/// Books, plant, laptop with AI chip and checklist on a soft cloud.
class StudyIllustration extends StatelessWidget {
  const StudyIllustration({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 340 / 200,
      child: CustomPaint(painter: _StudyIllustrationPainter()),
    ),
  );
}

/// "ExamGenius" in brand blue + "AI" in purple.
class BrandWordmarkText extends StatelessWidget {
  const BrandWordmarkText({
    super.key,
    required this.size,
    required this.aiLabel,
    this.semanticLabel,
  });
  final double size;
  final String aiLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: semanticLabel,
    child: ExcludeSemantics(
      excluding: semanticLabel != null,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ExamGenius ',
                style: AppTextStyles.wordmark(size, AppColors.brandBlue),
              ),
              TextSpan(
                text: aiLabel,
                style: AppTextStyles.wordmark(size, AppColors.accent),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Blue→purple waves in the top-left and bottom-right corners, each with a
/// thin white accent line.
class _CornerWavesPainter extends CustomPainter {
  const _CornerWavesPainter({this.soft = false});
  final bool soft;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final strong = this.soft
        ? (Paint()
            ..color = AppColors.splashWaveSoft.colors.last.withValues(
              alpha: 0.35,
            ))
        : (Paint()
            ..shader = AppColors.splashWave.createShader(Offset.zero & s));
    final soft = this.soft
        ? (Paint()
            ..color = AppColors.splashWaveSoft.colors.first.withValues(
              alpha: 0.22,
            ))
        : (Paint()
            ..shader = AppColors.splashWaveSoft.createShader(Offset.zero & s));
    final line = Paint()
      ..color = AppColors.white.withValues(alpha: this.soft ? 0 : 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Top-left: soft back layer, strong front layer, white line.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.55, 0)
        ..cubicTo(w * 0.35, h * 0.07, w * 0.12, h * 0.05, 0, h * 0.25)
        ..close(),
      soft,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.40, 0)
        ..cubicTo(w * 0.22, h * 0.05, w * 0.06, h * 0.04, 0, h * 0.13)
        ..close(),
      strong,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.13)
        ..cubicTo(w * 0.10, h * 0.06, w * 0.30, h * 0.06, w * 0.45, h * 0.03),
      line,
    );

    // Bottom: wide wave rising to the right.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.93)
        ..cubicTo(w * 0.30, h * 0.90, w * 0.55, h * 0.99, w * 0.75, h * 0.90)
        ..cubicTo(w * 0.88, h * 0.84, w * 0.95, h * 0.80, w, h * 0.78)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      soft,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.95)
        ..cubicTo(w * 0.30, h * 0.92, w * 0.55, h * 1.0, w * 0.78, h * 0.93)
        ..cubicTo(w * 0.90, h * 0.89, w * 0.96, h * 0.86, w, h * 0.85)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      strong,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, h * 0.965)
        ..cubicTo(w * 0.55, h * 0.975, w * 0.75, h * 0.93, w, h * 0.86),
      line,
    );
  }

  @override
  bool shouldRepaint(_CornerWavesPainter old) => old.soft != soft;
}

/// Blue mortarboard over a gold open book (150×120 design space).
class _CapBookLogoPainter extends CustomPainter {
  const _CapBookLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 150, size.height / 120);
    final blue = Paint()..color = AppColors.brandBlue;
    final blueLight = Paint()..color = AppColors.primary;
    final gold = Paint()..color = AppColors.gold;

    // Book: gold pages, blue base strokes.
    canvas.drawPath(
      Path()
        ..moveTo(75, 112)
        ..quadraticBezierTo(50, 88, 12, 94)
        ..lineTo(26, 74)
        ..quadraticBezierTo(55, 72, 75, 92)
        ..quadraticBezierTo(95, 72, 124, 74)
        ..lineTo(138, 94)
        ..quadraticBezierTo(100, 88, 75, 112)
        ..close(),
      gold,
    );
    final base = Paint()
      ..color = AppColors.brandBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(6, 102)
        ..quadraticBezierTo(50, 94, 75, 116)
        ..quadraticBezierTo(100, 94, 144, 102),
      base,
    );

    // Cap body.
    canvas.drawPath(
      Path()
        ..moveTo(46, 38)
        ..lineTo(104, 38)
        ..lineTo(104, 62)
        ..quadraticBezierTo(75, 76, 46, 62)
        ..close(),
      blue,
    );
    // Board (top face lighter).
    canvas.drawPath(
      Path()
        ..moveTo(75, 4)
        ..lineTo(132, 26)
        ..lineTo(75, 48)
        ..lineTo(18, 26)
        ..close(),
      blueLight,
    );
    // Tassel.
    final cord = Paint()
      ..color = AppColors.brandBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(const Offset(120, 30), const Offset(120, 58), cord);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 62), width: 9, height: 12),
      blue,
    );
  }

  @override
  bool shouldRepaint(_CapBookLogoPainter old) => false;
}

/// Books + plant, laptop with an AI chip, and a checklist clipboard on a
/// soft cloud (340×200 design space).
class _StudyIllustrationPainter extends CustomPainter {
  const _StudyIllustrationPainter();

  RRect _rr(double l, double t, double w, double h, double r) =>
      RRect.fromLTRBR(l, t, l + w, t + h, Radius.circular(r));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 340, size.height / 200);
    Paint fill(Color c) => Paint()..color = c;

    // Cloud backdrop.
    final cloud = fill(AppColors.splashCloud);
    canvas.drawPath(
      Path()
        ..moveTo(10, 178)
        ..cubicTo(-6, 120, 40, 70, 100, 86)
        ..cubicTo(130, 20, 250, 10, 290, 70)
        ..cubicTo(340, 80, 350, 150, 326, 178)
        ..close(),
      cloud,
    );
    // Ground shadow.
    canvas.drawOval(
      Rect.fromLTWH(30, 172, 280, 14),
      fill(AppColors.laptopFrame.withValues(alpha: 0.08)),
    );

    // Books (orange bottom, blue top) with page edges.
    void book(double top, Color cover) {
      canvas.drawRRect(_rr(26, top, 108, 30, 7), fill(cover));
      canvas.drawRRect(_rr(54, top + 5, 82, 20, 3), fill(AppColors.pageWhite));
      final rule = Paint()
        ..color = AppColors.clipLine
        ..strokeWidth = 1.2;
      for (var i = 1; i < 4; i++) {
        canvas.drawLine(
          Offset(58, top + 5 + i * 5),
          Offset(134, top + 5 + i * 5),
          rule,
        );
      }
    }

    book(142, AppColors.bookOrange);
    book(110, AppColors.primary);

    // Plant leaves behind the laptop.
    void leaf(Offset base, Offset tip, double bulge, Color c) {
      final mid = Offset.lerp(base, tip, 0.5)!;
      final n =
          Offset(-(tip.dy - base.dy), tip.dx - base.dx) /
          (tip - base).distance *
          bulge;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(mid.dx + n.dx, mid.dy + n.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(mid.dx - n.dx, mid.dy - n.dy, base.dx, base.dy)
          ..close(),
        fill(c),
      );
    }

    final stem = Paint()
      ..color = AppColors.leafDark
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(108, 112)
        ..quadraticBezierTo(104, 70, 92, 30),
      stem,
    );
    leaf(const Offset(100, 70), const Offset(52, 52), 14, AppColors.leafGreen);
    leaf(const Offset(96, 48), const Offset(88, 4), 12, AppColors.leafGreen);
    leaf(const Offset(104, 82), const Offset(150, 46), 14, AppColors.leafDark);
    leaf(const Offset(106, 100), const Offset(74, 92), 8, AppColors.leafDark);

    // Laptop.
    canvas.drawRRect(_rr(116, 176, 160, 8, 4), fill(AppColors.laptopBase));
    canvas.save();
    canvas.translate(196, 120);
    canvas.skew(-0.08, 0);
    canvas.drawRRect(_rr(-74, -58, 148, 114, 10), fill(AppColors.laptopFrame));
    final screen = Rect.fromLTWH(-66, -50, 132, 98);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(6)),
      Paint()..shader = AppColors.screenGradient.createShader(screen),
    );
    // AI chip with circuit legs.
    final chipStroke = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(_rr(-24, -20, 48, 40, 7), chipStroke);
    for (var i = -1; i <= 1; i++) {
      final x = i * 12.0;
      canvas.drawLine(Offset(x, -20), Offset(x, -32), chipStroke);
      canvas.drawCircle(Offset(x, -34), 2.2, fill(AppColors.white));
      canvas.drawLine(Offset(x, 20), Offset(x, 32), chipStroke);
      canvas.drawCircle(Offset(x, 34), 2.2, fill(AppColors.white));
      final y = i * 10.0;
      canvas.drawLine(Offset(-24, y), Offset(-38, y), chipStroke);
      canvas.drawLine(Offset(24, y), Offset(38, y), chipStroke);
    }
    final tp = TextPainter(
      text: TextSpan(
        text: 'AI',
        style: AppTextStyles.wordmark(24, AppColors.white).copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: AppFontWeights.extraBold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();

    // Clipboard.
    canvas.save();
    canvas.translate(282, 116);
    canvas.rotate(0.12);
    canvas.drawRRect(_rr(-38, -62, 76, 128, 8), fill(AppColors.brandBlue));
    canvas.drawRRect(_rr(-32, -54, 64, 114, 5), fill(AppColors.white));
    canvas.drawRRect(_rr(-14, -70, 28, 14, 5), fill(AppColors.brandBlue));
    canvas.drawCircle(const Offset(0, -70), 5, fill(AppColors.brandBlue));
    final tick = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final y = -32.0 + i * 30;
      canvas.drawRRect(_rr(-24, y - 8, 16, 16, 4), fill(AppColors.leafGreen));
      canvas.drawPath(
        Path()
          ..moveTo(-20, y)
          ..lineTo(-17, y + 3)
          ..lineTo(-12, y - 3),
        tick,
      );
      canvas.drawRRect(_rr(-2, y - 6, 26, 4, 2), fill(AppColors.clipLine));
      canvas.drawRRect(_rr(-2, y + 2, 18, 4, 2), fill(AppColors.clipLine));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StudyIllustrationPainter old) => false;
}
