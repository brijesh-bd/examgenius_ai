import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/learning_path.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/learning_path_widgets.dart';

/// Ordered learning path of one subject: every topic (broad topics split into
/// units) with completed / current / upcoming status and saved notes.
/// Any item can be opened, not only the current one.
class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({
    super.key,
    required this.examId,
    required this.subjectId,
  });

  final String examId;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final key = (examId: examId, subjectId: subjectId);
    final path = ref.watch(learningPathProvider(key));
    return Scaffold(
      appBar: AppBar(title: Text(path.value?.subjectName ?? l10n.learningPath)),
      body: SafeArea(
        top: false,
        child: path.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                const Skeleton(height: 80),
                for (var i = 0; i < 5; i++) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const Skeleton(height: 64),
                ],
              ],
            ),
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(learningPathProvider(key)),
          ),
          data: (p) => p.items.isEmpty
              ? StateMessage(icon: Icons.route_outlined, title: l10n.comingSoon)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(learningPathProvider(key).future),
                  child: _PathList(path: p),
                ),
        ),
      ),
    );
  }
}

class _PathList extends StatelessWidget {
  const _PathList({required this.path});
  final LearningPath path;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final current = path.currentId == null ? null : path.item(path.currentId!);
    return ListView(
      children: [
        ResponsiveCenter(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(path.examName, style: theme.textTheme.bodySmall),
                      Text(path.subjectName, style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      LearningProgressBar(path: path),
                      if (current != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: () => openLearningItem(
                            context,
                            examId: path.examId,
                            item: current,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            '${l10n.statusCurrent}: ${current.fullName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final (i, item) in path.items.indexed) ...[
                // Group header when a broad topic's units start.
                if (item.isUnit &&
                    (i == 0 || path.items[i - 1].topicId != item.topicId))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxs,
                      AppSpacing.sm,
                      0,
                      AppSpacing.xxs,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        item.topicName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                _PathTile(examId: path.examId, item: item),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({required this.examId, required this.item});
  final String examId;
  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isCurrent = item.status == LearningStatus.current;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        side: isCurrent
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        minTileHeight: AppSpacing.minTouch + 8,
        leading: LearningStatusIcon(item.status, order: item.order),
        title: Text(
          item.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: item.status == LearningStatus.upcoming
                ? theme.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: Text(
          [
            switch (item.status) {
              LearningStatus.completed => l10n.statusCompleted,
              LearningStatus.current => l10n.statusCurrent,
              LearningStatus.upcoming => l10n.statusUpcoming,
            },
            if (item.hasNotes) l10n.notesReady,
          ].join(' · '),
        ),
        trailing: Icon(
          item.hasNotes ? Icons.menu_book_rounded : Icons.auto_awesome_rounded,
          color: item.hasNotes ? AppColors.success : theme.colorScheme.primary,
        ),
        onTap: () => openLearningItem(context, examId: examId, item: item),
      ),
    );
  }
}
