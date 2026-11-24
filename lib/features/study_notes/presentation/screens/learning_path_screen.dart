import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';

import 'package:go_router/go_router.dart';

import '../../../../localization/settings_providers.dart';
import '../../domain/learning_path.dart';
import '../../domain/note_outline.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/hierarchy_tree.dart';
import '../widgets/learning_path_widgets.dart';
import 'outline_screen.dart';

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
    // Nested chapters/sections under each item (optional: the list works without it).
    final treeKey = (
      examId: examId,
      subjectId: subjectId,
      language: ref.watch(localeProvider).languageCode == 'hi' ? 'hi' : 'en',
      mode: LearningMode.complete,
    );
    final tree = ref.watch(syllabusTreeProvider(treeKey)).value;
    final recsKey = (
      examId: examId,
      subjectId: subjectId,
      language: treeKey.language,
    );
    final recs = ref.watch(learningRecommendationsProvider(recsKey)).value;
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
                  onRefresh: () {
                    ref.invalidate(syllabusTreeProvider(treeKey));
                    ref.invalidate(learningRecommendationsProvider(recsKey));
                    return ref.refresh(learningPathProvider(key).future);
                  },
                  child: _PathList(
                    path: p,
                    tree: tree,
                    treeKey: treeKey,
                    recs: recs,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PathList extends ConsumerWidget {
  const _PathList({
    required this.path,
    required this.tree,
    required this.treeKey,
    this.recs,
  });
  final LearningRecommendations? recs;
  final LearningPath path;
  final SyllabusTree? tree;
  final TreeKey treeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> openSection(TreeSectionRef r) async {
      await context.push(
        notesSectionRoute(
          (
            examId: path.examId,
            unitId: r.unitId,
            language: treeKey.language,
            mode: treeKey.mode,
          ),
          r.chapterId,
          r.sectionId,
        ),
      );
      ref.invalidate(syllabusTreeProvider(treeKey));
      ref.invalidate(learningRecommendationsProvider);
    }

    final next = tree?.next;
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
                      // Next recommended SECTION (from the nested tree).
                      if (next?.ref case final r?) ...[
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton.icon(
                          onPressed: () => openSection(r),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            '${l10n.treeNextRecommended}: ${next!.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (current != null) ...[
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
              // Sections opened but not finished.
              if (recs?.continueSections case final cont?
                  when cont.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _RecCard(
                  title: l10n.recContinue,
                  icon: Icons.play_circle_outline_rounded,
                  children: [
                    for (final c in cont)
                      ListTile(
                        dense: true,
                        title: Text(c.name),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => openSection(c.ref),
                      ),
                  ],
                ),
              ],
              // Weak topics from the student's real practice results.
              if (recs?.revise case final revise? when revise.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _RecCard(
                  title: l10n.recRevise,
                  icon: Icons.replay_rounded,
                  children: [
                    for (final r in revise)
                      ListTile(
                        dense: true,
                        title: Text(r.name),
                        subtitle: Text(
                          '${l10n.recAccuracy((r.accuracy * 100).round(), r.attempted)} · '
                          '${r.studied ? l10n.recReviseNotes : l10n.recStudyFirst}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          final item = path.items
                              .where((i) => i.topicId == r.topicId)
                              .firstOrNull;
                          if (item != null) {
                            openLearningItem(
                              context,
                              examId: path.examId,
                              item: item,
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
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
                _PathTile(
                  examId: path.examId,
                  item: item,
                  node: tree?.subject.find(item.id),
                  onOpenSection: openSection,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.examId,
    required this.item,
    this.node,
    required this.onOpenSection,
  });
  final String examId;
  final LearningItem item;

  /// This item in the syllabus tree (chapters/sections when it has an outline).
  final SyllabusTreeNode? node;
  final void Function(TreeSectionRef) onOpenSection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isCurrent = item.status == LearningStatus.current;
    final n = node;
    if (n != null && n.hasSections) {
      return Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          side: isCurrent
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: ExpansionTile(
          key: PageStorageKey('path-${item.id}'),
          leading: LearningStatusIcon(item.status, order: item.order),
          title: Text(item.name, style: theme.textTheme.titleSmall),
          subtitle: Text(
            '${l10n.treeSectionsProgress(n.stats.completed, n.stats.sections)} · '
            '${l10n.treeContentReady(n.stats.ready, n.stats.sections)}',
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
          children: [
            HierarchyTree(
              nodes: n.children,
              onOpenSection: (s) => onOpenSection(s.ref!),
            ),
            TextButton.icon(
              onPressed: () =>
                  openLearningItem(context, examId: examId, item: item),
              icon: const Icon(Icons.list_alt_rounded),
              label: Text(l10n.outlineContinue),
            ),
          ],
        ),
      );
    }
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

class _RecCard extends StatelessWidget {
  const _RecCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.titleSmall),
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
