import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/concept_hierarchy.dart';

/// Searchable, expandable Railway Mathematics hierarchy.
///
/// Multi-select (Create Practice): [selection] + [onToggle]; a checkbox per
/// node shows all / partial / none, selecting a parent covers its children.
/// Single-pick (AI Study Notes): [onPick] instead — tapping a node opens it.
class ConceptTree extends StatefulWidget {
  const ConceptTree({
    super.key,
    required this.tree,
    required this.languageCode,
    this.selection = const {},
    this.onToggle,
    this.onPick,
    this.picked,
    this.enabled = true,
  }) : assert(onToggle != null || onPick != null);

  final ConceptHierarchy tree;
  final String languageCode;
  final Set<String> selection;
  final ValueChanged<String>? onToggle;
  final ValueChanged<String>? onPick;

  /// Single-pick: the selected node, highlighted with a check mark.
  final String? picked;
  final bool enabled;

  @override
  State<ConceptTree> createState() => _ConceptTreeState();
}

class _ConceptTreeState extends State<ConceptTree> {
  final _expanded = <String>{};
  final _search = TextEditingController();
  String _query = '';

  @override
  void didUpdateWidget(ConceptTree old) {
    super.didUpdateWidget(old);
    // Another exam's tree: forget expansion and search.
    if (old.tree.examId != widget.tree.examId) {
      _expanded.clear();
      _search.clear();
      _query = '';
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final visible = widget.tree.visibleFor(_query);
    final rows = <Widget>[];

    void add(ConceptNode n, int depth) {
      if (visible != null && !visible.contains(n.id)) return;
      // While searching, matches are shown expanded.
      final open = visible != null || _expanded.contains(n.id);
      rows.add(_row(context, n, depth, open));
      if (open) {
        for (final c in n.children) {
          add(c, depth + 1);
        }
      }
    }

    for (final c in widget.tree.chapters) {
      add(c, 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('conceptSearch'),
          controller: _search,
          enabled: widget.enabled,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: l10n.conceptSearchHint,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                    }),
                  ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              l10n.conceptNoMatch,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...rows,
      ],
    );
  }

  Widget _row(BuildContext context, ConceptNode n, int depth, bool open) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final multi = widget.onToggle != null;
    final state = widget.tree.stateOf(n.id, widget.selection);
    final title = n.title(widget.languageCode);
    final concepts = n.isLeaf ? 0 : widget.tree.leavesOf(n.id).length;
    final isPicked = !multi && n.id == widget.picked;
    final style = switch (n.type) {
      ConceptNodeType.chapter => AppTextStyles.label,
      _ => AppTextStyles.body,
    };

    void toggleOpen() => setState(() {
      if (!_expanded.remove(n.id)) _expanded.add(n.id);
    });

    return Semantics(
      key: ValueKey('node_${n.id}'),
      container: true,
      label: title,
      selected: isPicked,
      child: Material(
        color: isPicked ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        child: InkWell(
          onTap: !widget.enabled
              ? null
              : multi
              ? () => widget.onToggle!(n.id)
              : () => widget.onPick!(n.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: depth * 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: n.isLeaf
                        ? null
                        : IconButton(
                            key: ValueKey('expand_${n.id}'),
                            tooltip: open ? l10n.collapse : l10n.expand,
                            icon: Icon(
                              open
                                  ? Icons.expand_more_rounded
                                  : Icons.chevron_right_rounded,
                            ),
                            onPressed: _query.isEmpty ? toggleOpen : null,
                          ),
                  ),
                  if (multi)
                    Checkbox(
                      key: ValueKey('check_${n.id}'),
                      tristate: true,
                      value: switch (state) {
                        SelectionState.all => true,
                        SelectionState.partial => null,
                        SelectionState.none => false,
                      },
                      onChanged: widget.enabled
                          ? (_) => widget.onToggle!(n.id)
                          : null,
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: isPicked
                          ? style.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            )
                          : style,
                    ),
                  ),
                  if (concepts > 0)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        '$concepts',
                        style: AppTextStyles.tiny.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (!multi)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: isPicked
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: scheme.primary,
                            )
                          : const Icon(Icons.chevron_right_rounded),
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

/// Compact summary of a selection: "Analogy (all) · Number Series (2) …".
class SelectionSummary extends StatelessWidget {
  const SelectionSummary({
    super.key,
    required this.tree,
    required this.selection,
    required this.languageCode,
  });

  final ConceptHierarchy tree;
  final Set<String> selection;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final concepts = tree.conceptsOf(selection);
    final parts = <String>[];
    for (final c in tree.chapters) {
      final mine = tree.leavesOf(c.id).where(concepts.contains).length;
      if (mine == 0) continue;
      final all = mine == tree.leavesOf(c.id).length;
      parts.add('${c.title(languageCode)} (${all ? l10n.summaryAll : mine})');
    }
    const shown = 3;
    final text = parts.length <= shown
        ? parts.join(' · ')
        : '${parts.take(shown).join(' · ')} · ${l10n.summaryMore(parts.length - shown)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        text,
        key: const Key('selectionSummary'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(color: scheme.primary),
      ),
    );
  }
}
