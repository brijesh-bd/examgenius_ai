import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/note_outline.dart';

/// Content readiness label/icon for a section (shared, not the student's).
({String label, IconData icon, Color color}) contentLook(
  AppLocalizations l10n,
  String? content,
  ColorScheme scheme,
) => switch (content) {
  'ready' => (
    label: l10n.contentReady,
    icon: Icons.check_circle_outline,
    color: AppColors.success,
  ),
  'generating' => (
    label: l10n.contentGenerating,
    icon: Icons.hourglass_top_rounded,
    color: AppColors.secondary,
  ),
  'incomplete' || 'validation_failed' => (
    label: l10n.contentIncomplete,
    icon: Icons.report_problem_outlined,
    color: AppColors.error,
  ),
  'failed' => (
    label: l10n.contentFailed,
    icon: Icons.error_outline_rounded,
    color: AppColors.error,
  ),
  _ => (
    label: l10n.contentNotGenerated,
    icon: Icons.radio_button_unchecked,
    color: scheme.outline,
  ),
};

/// Expandable Chapter → [Subtopic…] → Section rows. Sections show the
/// student's progress (icon) and content readiness (label) separately.
class HierarchyTree extends StatelessWidget {
  const HierarchyTree({
    super.key,
    required this.nodes,
    required this.onOpenSection,
    this.depth = 0,
  });

  final List<SyllabusTreeNode> nodes;
  final void Function(SyllabusTreeNode section) onOpenSection;
  final int depth;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final n in nodes)
        n.type == TreeNodeType.section
            ? _SectionRow(node: n, depth: depth, onOpen: onOpenSection)
            : _GroupTile(node: n, depth: depth, onOpenSection: onOpenSection),
    ],
  );
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.node,
    required this.depth,
    required this.onOpenSection,
  });
  final SyllabusTreeNode node;
  final int depth;
  final void Function(SyllabusTreeNode) onOpenSection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = node.stats;
    final done = s.sections > 0 && s.completed == s.sections;
    return ExpansionTile(
      key: PageStorageKey(node.id),
      tilePadding: EdgeInsetsDirectional.only(start: 12.0 + depth * 16, end: 8),
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: false,
      leading: Icon(
        done
            ? Icons.check_circle_rounded
            : node.type == TreeNodeType.chapter
            ? Icons.menu_book_rounded
            : Icons.subdirectory_arrow_right_rounded,
        color: done ? AppColors.success : theme.colorScheme.primary,
        size: 20,
      ),
      title: Row(
        children: [
          Expanded(child: Text(node.name, style: theme.textTheme.titleSmall)),
          if (node.isDraft) _Pill(l10n.draftLabel, AppColors.warning),
        ],
      ),
      subtitle: Text(
        '${l10n.treeSectionsProgress(s.completed, s.sections)} · ${l10n.treeContentReady(s.ready, s.sections)}',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        HierarchyTree(
          nodes: node.children,
          depth: depth + 1,
          onOpenSection: onOpenSection,
        ),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.node,
    required this.depth,
    required this.onOpen,
  });
  final SyllabusTreeNode node;
  final int depth;
  final void Function(SyllabusTreeNode) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final look = contentLook(l10n, node.content, scheme);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsetsDirectional.only(
        start: 16.0 + depth * 16,
        end: 8,
      ),
      leading: Icon(
        node.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 20,
        color: node.isCompleted ? AppColors.success : scheme.outline,
        semanticLabel: node.isCompleted ? l10n.progressStudied : null,
      ),
      title: Text(node.name),
      subtitle: Row(
        children: [
          Icon(look.icon, size: 14, color: look.color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(look.label, style: TextStyle(color: look.color)),
          ),
          if (node.isCompleted) ...[
            const Text(' · '),
            Text(l10n.progressStudied),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: node.ref == null ? null : () => onOpen(node),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsetsDirectional.only(start: 6),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    ),
  );
}
