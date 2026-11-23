import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/study_note.dart';

/// Building blocks for the Generated Notes screen. Pure display widgets.

TextStyle? _mono(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium
        ?.copyWith(fontFamily: 'monospace', height: 1.5);

/// Readable paragraph text (slightly larger line height for study).
class NoteText extends StatelessWidget {
  const NoteText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => SelectableText(
    text,
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
  );
}

class NoteSubheading extends StatelessWidget {
  const NoteSubheading(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Bulleted list; [icon] replaces the dot (e.g. a warning sign for mistakes).
class NoteBullets extends StatelessWidget {
  const NoteBullets(this.items, {super.key, this.icon, this.color});
  final List<String> items;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(
                    icon ?? Icons.circle,
                    size: icon == null ? 8 : 18,
                    color: c,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tinted rounded box used for formulas, answers and highlights.
class NoteBox extends StatelessWidget {
  const NoteBox({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}

class NoteConceptTile extends StatelessWidget {
  const NoteConceptTile(this.concept, {super.key});
  final NoteConcept concept;

  @override
  Widget build(BuildContext context) => NoteBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoteSubheading(concept.term),
        Text(concept.definition, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class NoteFormulaCard extends StatelessWidget {
  const NoteFormulaCard(this.formula, {super.key});
  final NoteFormula formula;

  @override
  Widget build(BuildContext context) => NoteBox(
    color: AppColors.accent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (formula.name.isNotEmpty) NoteSubheading(formula.name),
        SelectableText(formula.expression, style: _mono(context)),
        if (formula.meaning.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(formula.meaning, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    ),
  );
}

/// Worked example: problem, numbered steps, final answer.
class NoteExampleCard extends StatelessWidget {
  const NoteExampleCard(this.example, {super.key});
  final NoteExample example;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (example.title.isNotEmpty) NoteSubheading(example.title),
            if (example.problem.isNotEmpty) NoteText(example.problem),
            for (final (i, step) in example.steps.indexed)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelSmall,
                        semanticsLabel: l10n.noteStep(i + 1),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(step, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            if (example.answer.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              NoteBox(
                color: AppColors.success,
                child: Text(
                  l10n.noteAnswer(example.answer),
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Comparison / data table; scrolls sideways on narrow screens.
class NoteTableView extends StatelessWidget {
  const NoteTableView(this.table, {super.key});
  final NoteTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outlineVariant;
    Widget cell(String t, {bool head = false}) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Text(
        t,
        style: head ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (table.title.isNotEmpty) NoteSubheading(table.title),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                border: TableBorder.all(
                  color: border,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    children: [
                      for (final h in table.headers) cell(h, head: true),
                    ],
                  ),
                  for (final row in table.rows)
                    TableRow(children: [for (final c in row) cell(c)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical flowchart: rounded boxes joined by arrows.
class NoteFlowchartView extends StatelessWidget {
  const NoteFlowchartView(this.chart, {super.key});
  final NoteFlowchart chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          if (chart.title.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: NoteSubheading(chart.title),
            ),
          for (final (i, step) in chart.steps.indexed) ...[
            if (i > 0) Icon(Icons.arrow_downward_rounded, color: c),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: c.withValues(alpha: i == 0 ? 0.16 : 0.07),
                borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                border: Border.all(color: c.withValues(alpha: 0.35)),
              ),
              child: Text(
                step,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple line graph drawn from the AI's numeric points (no extra package).
class NoteGraphView extends StatelessWidget {
  const NoteGraphView(this.graph, {super.key});
  final NoteGraph graph;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (graph.title.isNotEmpty) NoteSubheading(graph.title),
          Semantics(
            label:
                '${graph.title}. ${graph.points.map((p) => '${_fmt(p.x)}: ${_fmt(p.y)}').join(', ')}',
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _GraphPainter(
                  graph.points,
                  line: theme.colorScheme.primary,
                  axis: theme.colorScheme.outline,
                  labelStyle: small,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  graph.yLabel.isEmpty ? '' : '↑ ${graph.yLabel}',
                  style: small,
                ),
              ),
              Text(
                graph.xLabel.isEmpty ? '' : '${graph.xLabel} →',
                style: small,
              ),
            ],
          ),
          if (graph.caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(graph.caption, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

class _GraphPainter extends CustomPainter {
  _GraphPainter(
    this.points, {
    required this.line,
    required this.axis,
    this.labelStyle,
  });

  final List<NotePoint> points;
  final Color line;
  final Color axis;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const left = 40.0, bottom = 22.0, top = 8.0, right = 8.0;
    final xs = points.map((p) => p.x), ys = points.map((p) => p.y);
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    var minY = ys.reduce(math.min), maxY = ys.reduce(math.max);
    if (minY > 0 && minY < maxY * 0.5) minY = 0;
    if (maxY == minY) maxY = minY + 1;
    final w = size.width - left - right, h = size.height - top - bottom;
    Offset at(NotePoint p) => Offset(
      left + (maxX == minX ? 0 : (p.x - minX) / (maxX - minX)) * w,
      top + h - (p.y - minY) / (maxY - minY) * h,
    );

    final axisPaint = Paint()
      ..color = axis
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, top), Offset(left, top + h), axisPaint);
    canvas.drawLine(
      Offset(left, top + h),
      Offset(left + w, top + h),
      axisPaint,
    );

    void label(String t, Offset o, {bool alignRight = false}) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: labelStyle?.copyWith(color: axis),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: left - 4);
      tp.paint(canvas, alignRight ? o - Offset(tp.width, tp.height / 2) : o);
    }

    label(_fmt(maxY), Offset(left - 4, top), alignRight: true);
    label(_fmt(minY), Offset(left - 4, top + h), alignRight: true);
    label(_fmt(minX), Offset(left, top + h + 4));
    final tpMax = TextPainter(
      text: TextSpan(
        text: _fmt(maxX),
        style: labelStyle?.copyWith(color: axis),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpMax.paint(canvas, Offset(left + w - tpMax.width, top + h + 4));

    final path = Path()..moveTo(at(points.first).dx, at(points.first).dy);
    for (final p in points.skip(1)) {
      path.lineTo(at(p).dx, at(p).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
    final dot = Paint()..color = line;
    for (final p in points) {
      canvas.drawCircle(at(p), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.points != points || old.line != line;
}

class NoteCodeBlock extends StatelessWidget {
  const NoteCodeBlock(this.code, {super.key});
  final NoteCode code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (code.caption.isNotEmpty) NoteSubheading(code.caption),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(code.code, style: _mono(context)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Practice MCQ: the answer stays hidden until the student asks for it.
class NoteMcqCard extends StatefulWidget {
  const NoteMcqCard(this.mcq, {super.key, required this.number});
  final NoteMcq mcq;
  final int number;

  @override
  State<NoteMcqCard> createState() => _NoteMcqCardState();
}

class _NoteMcqCardState extends State<NoteMcqCard> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final q = widget.mcq;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.number}. ${q.question}',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final (i, o) in q.options.indexed)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _shown && i == q.correctIndex
                      ? AppColors.success.withValues(alpha: 0.12)
                      : null,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  border: Border.all(
                    color: _shown && i == q.correctIndex
                        ? AppColors.success
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  '${String.fromCharCode(65 + i)}. $o',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            if (_shown && q.explanation.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              NoteBox(color: AppColors.success, child: Text(q.explanation)),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _shown = !_shown),
                icon: Icon(
                  _shown
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                label: Text(_shown ? l10n.noteHideAnswer : l10n.noteShowAnswer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
