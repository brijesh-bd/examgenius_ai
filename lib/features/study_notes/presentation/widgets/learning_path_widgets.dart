import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/learning_path.dart';
import '../../domain/study_note.dart';
import '../providers/study_notes_providers.dart';

/// Opens Create Notes for a topic/unit with language and level carried over.
/// `push`, so Android back returns to where the student was.
void openCreateNotes(
  BuildContext context, {
  required String examId,
  required String topicId,
  NotesPrefill? prefill,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  context.push(AppRoutes.notesCreateFor(examId, topicId), extra: prefill);
}

/// A path item: its latest saved note when there is one, otherwise Create Notes.
void openLearningItem(
  BuildContext context, {
  required String examId,
  required LearningItem item,
  NotesPrefill? prefill,
}) {
  if (item.latestNoteId case final id?) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.push(AppRoutes.noteViewFor(id));
  } else {
    openCreateNotes(
      context,
      examId: examId,
      topicId: item.id,
      prefill: prefill,
    );
  }
}

/// ✓ completed · ● current · ○ upcoming.
class LearningStatusIcon extends StatelessWidget {
  const LearningStatusIcon(this.status, {super.key, this.order});
  final LearningStatus status;
  final int? order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      LearningStatus.completed => (AppColors.success, l10n.statusCompleted),
      LearningStatus.current => (scheme.primary, l10n.statusCurrent),
      LearningStatus.upcoming => (scheme.outline, l10n.statusUpcoming),
    };
    return Semantics(
      label: label,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status == LearningStatus.upcoming
              ? null
              : color.withValues(
                  alpha: status == LearningStatus.completed ? 1 : 0.15,
                ),
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: status == LearningStatus.completed
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : ExcludeSemantics(
                child: Text(
                  '${order ?? ''}',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color),
                ),
              ),
      ),
    );
  }
}

/// "3 of 12 topics completed" with a progress bar.
class LearningProgressBar extends StatelessWidget {
  const LearningProgressBar({super.key, required this.path});
  final LearningPath path;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          path.completed == path.total && path.total > 0
              ? l10n.allTopicsCompleted
              : l10n.learningPathProgress(path.completed, path.total),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: path.progress,
            minHeight: 8,
            color: AppColors.success,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

/// On the notes page: position in the path, progress, Mark as completed,
/// Continue to Next Topic and a link to the whole path.
class NotePathPanel extends ConsumerStatefulWidget {
  const NotePathPanel({super.key, required this.note});
  final StudyNote note;

  @override
  ConsumerState<NotePathPanel> createState() => _NotePathPanelState();
}

class _NotePathPanelState extends ConsumerState<NotePathPanel> {
  bool _saving = false;

  StudyNote get _note => widget.note;
  PathKey get _key => (examId: _note.examId, subjectId: _note.subjectId);

  Future<void> _toggle(LearningItem item) async {
    final l10n = context.l10n;
    final done = item.status != LearningStatus.completed;
    setState(() => _saving = true);
    try {
      await setLearningItemCompleted(
        ref,
        examId: _note.examId,
        itemId: item.id,
        completed: done,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              done ? l10n.markedCompleted : l10n.markedNotCompleted,
            ),
          ),
        );
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(apiErrorText(l10n, e)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final path = ref.watch(learningPathProvider(_key)).value;
    // Hidden until loaded, or for a note whose topic is not on a path.
    if (path == null || path.total == 0) return const SizedBox.shrink();
    final item = path.item(_note.topicId);
    final next = path.nextAfter(_note.topicId);
    final prefill = (language: _note.language, level: _note.level);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.route_rounded, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    item == null
                        ? path.subjectName
                        : '${l10n.learningTopicPosition(item.order, path.total)} · ${path.subjectName}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    AppRoutes.notesPathFor(_note.examId, _note.subjectId),
                  ),
                  child: Text(l10n.openLearningPath),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LearningProgressBar(path: path),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (item != null)
                  FilterChip(
                    selected: item.status == LearningStatus.completed,
                    avatar: _saving
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    label: Text(
                      item.status == LearningStatus.completed
                          ? l10n.statusCompleted
                          : l10n.markCompleted,
                    ),
                    onSelected: _saving ? null : (_) => _toggle(item),
                  ),
                if (next != null)
                  FilledButton.icon(
                    onPressed: () => openLearningItem(
                      context,
                      examId: _note.examId,
                      item: next,
                      prefill: prefill,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(l10n.continueNextTopic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "What to Study Next": full-width tappable rows for syllabus topics.
/// Older notes (names only) are shown as plain text.
class NextTopicsList extends StatelessWidget {
  const NextTopicsList({super.key, required this.note, required this.topics});
  final StudyNote note;
  final List<NoteNextTopic> topics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final linked = topics.any((t) => t.id != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (linked)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              l10n.nextTopicHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final t in topics)
          if (t.id case final id?)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                minTileHeight: AppSpacing.minTouch + 8,
                leading: const Icon(
                  Icons.east_rounded,
                  color: AppColors.primary,
                ),
                title: Text(t.name, style: theme.textTheme.titleSmall),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => openCreateNotes(
                  context,
                  examId: note.examId,
                  topicId: id,
                  prefill: (language: note.language, level: note.level),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.east_rounded, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(t.name, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
