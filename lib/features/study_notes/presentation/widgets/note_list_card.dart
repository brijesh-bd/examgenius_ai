import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../domain/study_note.dart';
import '../screens/create_notes_screen.dart' show noteLevelLabel;

/// One saved note in My Study Notes: topic (title), exam · subject,
/// language, level and creation date. Tapping opens the full note.
class NoteListCard extends StatelessWidget {
  const NoteListCard({
    super.key,
    required this.note,
    required this.color,
    required this.onOpen,
  });

  final StudyNote note;
  final Color color;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(note.createdAt);

    Widget tag(String text, Color c) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: c)),
    );

    return DashboardCard(
      onTap: onOpen,
      radius: AppSpacing.tileRadius,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
            ),
            child: Icon(Icons.auto_stories_rounded, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.topicName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: AppFontSizes.lg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${note.examName} · ${note.subjectName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    tag(
                      note.language == 'hi' ? l10n.hindi : l10n.english,
                      AppColors.primary,
                    ),
                    tag(noteLevelLabel(l10n, note.level), AppColors.accent),
                    Text(
                      l10n.noteCreatedOn(date),
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (note.bookmarked)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xxs),
              child: Icon(
                Icons.bookmark_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
