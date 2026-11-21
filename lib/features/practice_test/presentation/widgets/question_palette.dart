import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Status of one palette cell.
enum PaletteStatus { current, answered, notAnswered }

/// Numbered grid of all questions: green = answered, grey = not answered,
/// blue = current. Tap a number to jump to it.
class QuestionPalette extends StatelessWidget {
  const QuestionPalette({
    super.key,
    required this.total,
    required this.statusOf,
    required this.onTap,
  });

  final int total;
  final PaletteStatus Function(int index) statusOf;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const PaletteLegend(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < total; i++)
              _Cell(number: i + 1, status: statusOf(i), onTap: () => onTap(i)),
          ],
        ),
      ],
    );
  }
}

/// Colour key for the palette.
class PaletteLegend extends StatelessWidget {
  const PaletteLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget item(PaletteStatus s, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: paletteColor(context, s),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(PaletteStatus.answered, l10n.paletteAnswered),
        item(PaletteStatus.notAnswered, l10n.paletteNotAnswered),
        item(PaletteStatus.current, l10n.paletteCurrent),
      ],
    );
  }
}

Color paletteColor(BuildContext context, PaletteStatus s) => switch (s) {
  PaletteStatus.current => AppColors.primary,
  PaletteStatus.answered => AppColors.success,
  PaletteStatus.notAnswered => Theme.of(
    context,
  ).colorScheme.surfaceContainerHighest,
};

class _Cell extends StatelessWidget {
  const _Cell({
    required this.number,
    required this.status,
    required this.onTap,
  });

  final int number;
  final PaletteStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = paletteColor(context, status);
    final onColor = status == PaletteStatus.notAnswered
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.white;
    final label = switch (status) {
      PaletteStatus.current => l10n.paletteCurrent,
      PaletteStatus.answered => l10n.paletteAnswered,
      PaletteStatus.notAnswered => l10n.paletteNotAnswered,
    };
    return Semantics(
      button: true,
      label: '${l10n.questionNumber(number)}, $label',
      child: ExcludeSemantics(
        child: Material(
          color: color,
          shape: CircleBorder(
            side: status == PaletteStatus.current
                ? BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 4,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: Text(
                  '$number',
                  style: AppTextStyles.labelBold.copyWith(color: onColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the palette in a bottom sheet; returns after the student picks a
/// question or dismisses the sheet.
Future<void> showQuestionPaletteSheet(
  BuildContext context, {
  required int total,
  required PaletteStatus Function(int index) statusOf,
  required ValueChanged<int> onTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.questionPalette, style: AppTextStyles.h3),
              const SizedBox(height: 14),
              QuestionPalette(
                total: total,
                statusOf: statusOf,
                onTap: (i) {
                  Navigator.of(sheetContext).pop();
                  onTap(i);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
