import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/generated_question.dart';
import '../../domain/syllabus.dart';

extension DifficultyL10n on Difficulty {
  String label(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasy,
    Difficulty.medium => l10n.difficultyMedium,
    Difficulty.hard => l10n.difficultyHard,
  };

  Color get color => switch (this) {
    Difficulty.easy => AppColors.success,
    Difficulty.medium => AppColors.secondary,
    Difficulty.hard => AppColors.error,
  };
}

/// Card icon + colour for a syllabus subject. Icon is picked from the subject
/// name (backend data), colour cycles through [AppColors.subjectPalette].
({IconData icon, Color color}) subjectStyle(
  SyllabusSubject subject,
  int index,
) {
  final n = subject.name.toLowerCase();
  final icon = n.contains('math') || n.contains('quant') || n.contains('arith')
      ? Icons.calculate_rounded
      : n.contains('reason') || n.contains('intelligence')
      ? Icons.psychology_rounded
      : n.contains('english') || n.contains('language') || n.contains('hindi')
      ? Icons.translate_rounded
      : n.contains('science')
      ? Icons.science_rounded
      : n.contains('computer')
      ? Icons.computer_rounded
      : n.contains('awareness') ||
            n.contains('general') ||
            n.contains('current')
      ? Icons.public_rounded
      : Icons.menu_book_rounded;
  return (
    icon: icon,
    color: AppColors.subjectPalette[index % AppColors.subjectPalette.length],
  );
}

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Difficulty? value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<Difficulty>(
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      selected: {?value},
      onSelectionChanged: (s) {
        if (s.isNotEmpty) onChanged(s.first);
      },
      segments: [
        for (final d in Difficulty.values)
          ButtonSegment(
            value: d,
            label: Text(
              d.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class QuestionCountSelector extends StatelessWidget {
  const QuestionCountSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final n in kQuestionCountOptions)
          ChoiceChip(
            label: Text('$n'),
            selected: value == n,
            onSelected: (_) => onChanged(n),
          ),
      ],
    );
  }
}
