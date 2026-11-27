import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/study_note.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/learning_path_widgets.dart';
import '../widgets/note_blocks.dart';
import '../widgets/note_labels.dart';

/// Generated / saved notes: header, table of contents, collapsible sections.
/// [initial] (passed right after generation) avoids a second fetch.
class NoteViewScreen extends ConsumerWidget {
  const NoteViewScreen({
    super.key,
    required this.noteId,
    this.initial,
    this.banner,
    this.bottomBar,
  });

  final String noteId;
  final StudyNote? initial;

  /// Shown under the header (e.g. the development-sample label).
  final Widget? banner;

  /// e.g. section navigation (previous / mark complete / next).
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (initial?.content != null) {
      return _NoteView(note: initial!, banner: banner, bottomBar: bottomBar);
    }
    final note = ref.watch(studyNoteProvider(noteId));
    return note.when(
      data: (n) => _NoteView(note: n, banner: banner, bottomBar: bottomBar),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: ResponsiveCenter(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const Skeleton(height: 90),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: StateMessage(
          icon: Icons.error_outline_rounded,
          title: l10n.noteNotFound,
          body: apiErrorText(l10n, e),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(studyNoteProvider(noteId)),
        ),
      ),
    );
  }
}

/// One rendered part of a note (also used for streamed, partial notes).
typedef NoteSec = ({
  String id,
  String title,
  IconData icon,
  Color color,
  List<Widget> body,
});

/// Sections of a note, built from its content. [note] is null for a note
/// still being written (streaming): parts that need the saved note
/// ("What to Study Next" links) are left out until it is saved.
List<NoteSec> noteSections(
  AppLocalizations l10n,
  NoteContent c, {
  StudyNote? note,
}) {
  final out = <NoteSec>[];
  void add(
    String id,
    String title,
    IconData icon,
    Color color,
    List<Widget> body,
  ) {
    if (body.isNotEmpty) {
      out.add((id: id, title: title, icon: icon, color: color, body: body));
    }
  }

  add(
    'overview',
    l10n.nOverview,
    Icons.lightbulb_outline_rounded,
    AppColors.primary,
    [if (c.overview.isNotEmpty) NoteText(c.overview)],
  );
  add('objectives', l10n.nObjectives, Icons.flag_outlined, AppColors.primary, [
    if (c.objectives.isNotEmpty)
      NoteBullets(
        c.objectives,
        icon: Icons.flag_rounded,
        color: AppColors.primary,
      ),
  ]);
  add('detailed', l10n.nDetailed, Icons.menu_book_rounded, AppColors.primary, [
    for (final p in c.explanation)
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.heading.isNotEmpty) NoteSubheading(p.heading),
            NoteText(p.body),
          ],
        ),
      ),
  ]);
  add('timeline', l10n.nTimeline, Icons.timeline_rounded, AppColors.accent, [
    if (c.timeline.isNotEmpty) NoteTimelineView(c.timeline),
  ]);
  add('concepts', l10n.nConcepts, Icons.hub_outlined, AppColors.accent, [
    for (final k in c.concepts) NoteConceptTile(k),
  ]);
  add('examples', l10n.nExamples, Icons.science_outlined, AppColors.railway, [
    for (final e in c.examples) NoteExampleCard(e),
    for (final code in c.codeExamples) NoteCodeBlock(code),
  ]);
  add('sql', l10n.nSql, Icons.storage_rounded, AppColors.primary, [
    for (final q in c.sqlExamples) NoteSqlCard(q),
  ]);
  add(
    'diagrams',
    l10n.nDiagrams,
    Icons.account_tree_outlined,
    AppColors.previousYear,
    [
      for (final f in c.flowcharts) NoteFlowchartView(f),
      for (final g in c.graphs) NoteGraphView(g),
    ],
  );
  add('formulas', l10n.nFormulas, Icons.functions_rounded, AppColors.accent, [
    for (final f in c.formulas) NoteFormulaCard(f),
    for (final t in c.tables) NoteTableView(t),
  ]);
  add(
    'derivations',
    l10n.nDerivations,
    Icons.calculate_outlined,
    AppColors.accent,
    [for (final d in c.derivations) NoteDerivationCard(d)],
  );
  add(
    'tips',
    l10n.nTips,
    Icons.tips_and_updates_outlined,
    AppColors.secondary,
    [
      if (c.tips.isNotEmpty)
        NoteBullets(
          c.tips,
          icon: Icons.bolt_rounded,
          color: AppColors.secondary,
        ),
    ],
  );
  add(
    'mistakes',
    l10n.nMistakes,
    Icons.report_gmailerrorred_rounded,
    AppColors.error,
    [
      if (c.mistakes.isNotEmpty)
        NoteBullets(
          c.mistakes,
          icon: Icons.close_rounded,
          color: AppColors.error,
        ),
    ],
  );
  add(
    'keyPoints',
    l10n.nKeyPoints,
    Icons.star_outline_rounded,
    AppColors.banking,
    [
      if (c.keyPoints.isNotEmpty)
        NoteBullets(
          c.keyPoints,
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.banking,
        ),
    ],
  );
  add(
    'keyFacts',
    l10n.nKeyFacts,
    Icons.fact_check_outlined,
    AppColors.banking,
    [
      if (c.keyFacts.isNotEmpty)
        NoteBullets(
          c.keyFacts,
          icon: Icons.push_pin_outlined,
          color: AppColors.banking,
        ),
    ],
  );
  add(
    'revision',
    l10n.nRevision,
    Icons.flash_on_rounded,
    AppColors.studyNotes,
    [if (c.quickRevision.isNotEmpty) NoteBullets(c.quickRevision)],
  );
  add('mcqs', l10n.nMcqs, Icons.quiz_outlined, AppColors.mockTests, [
    for (final (i, q) in c.mcqs.indexed) NoteMcqCard(q, number: i + 1),
  ]);
  add('practice', l10n.nPractice, Icons.edit_note_rounded, AppColors.success, [
    for (final (i, x) in c.practice.indexed) NotePracticeCard(x, number: i + 1),
  ]);
  add('related', l10n.nRelated, Icons.link_rounded, AppColors.previousYear, [
    if (c.relatedConcepts.isNotEmpty) NoteBullets(c.relatedConcepts),
    if (c.furtherLearning.isNotEmpty) ...[
      NoteSubheading(l10n.nFurther),
      NoteBullets(c.furtherLearning, icon: Icons.arrow_forward_rounded),
    ],
  ]);
  add('next', l10n.nNext, Icons.arrow_forward_rounded, AppColors.primary, [
    // Syllabus topics: each row opens Create Notes for it (prefilled).
    if (note != null && c.nextTopics.isNotEmpty)
      NextTopicsList(note: note, topics: c.nextTopics),
  ]);
  return out;
}

class _NoteView extends ConsumerStatefulWidget {
  const _NoteView({required this.note, this.banner, this.bottomBar});
  final StudyNote note;
  final Widget? banner;
  final Widget? bottomBar;

  @override
  ConsumerState<_NoteView> createState() => _NoteViewState();
}

enum _MenuAction { personalNote, revision, flashcards, delete }

class _NoteViewState extends ConsumerState<_NoteView> {
  final _keys = <String, GlobalKey>{};
  final _collapsed = <String>{};

  /// Local copy; replaced only with what the server returned.
  late StudyNote _note = widget.note;
  bool _busy = false;

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(text)),
    );

  /// Runs a backend change; shows the error and keeps the old state on failure.
  Future<void> _run(Future<StudyNote> Function() change, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final updated = await change();
      if (!mounted) return;
      setState(() => _note = updated);
      _snack(done);
    } on Object catch (e) {
      if (mounted) _snack(apiErrorText(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleBookmark() {
    final l10n = context.l10n;
    final next = !_note.bookmarked;
    _run(
      () => ref.read(noteActionsProvider).setBookmarked(_note, next),
      next ? l10n.noteBookmarked : l10n.noteUnbookmarked,
    );
  }

  Future<void> _editPersonalNote() async {
    final l10n = context.l10n;
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PersonalNoteSheet(initial: _note.personalNote),
    );
    if (text == null || text.trim() == _note.personalNote.trim()) return;
    await _run(
      () => ref.read(noteActionsProvider).savePersonalNote(_note, text),
      l10n.personalNoteSaved,
    );
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.noteDeleteTitle),
        content: Text(l10n.noteDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.noteDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(noteActionsProvider).delete(_note);
      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.noteDeleted),
        ),
      );
    } on Object catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _snack(apiErrorText(l10n, e));
      }
    }
  }

  /// Opens a revision tool; a leftover snackbar would cover its buttons.
  void _openTool(String route) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.push(route, extra: _note);
  }

  void _onMenu(_MenuAction a) => switch (a) {
    _MenuAction.personalNote => _editPersonalNote(),
    _MenuAction.revision => _openTool(AppRoutes.noteRevisionFor(_note.id)),
    _MenuAction.flashcards => _openTool(AppRoutes.noteFlashcardsFor(_note.id)),
    _MenuAction.delete => _delete(),
  };

  void _jump(String id) {
    setState(() => _collapsed.remove(id));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[id]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final note = _note;
    final sections = noteSections(
      l10n,
      note.content ?? const NoteContent(overview: ''),
      note: note,
    );
    final allCollapsed = sections.every((s) => _collapsed.contains(s.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(note.topicName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: note.bookmarked
                ? l10n.noteRemoveBookmark
                : l10n.noteBookmark,
            icon: Icon(
              note.bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: note.bookmarked ? AppColors.accent : null,
            ),
            onPressed: _busy ? null : _toggleBookmark,
          ),
          IconButton(
            tooltip: allCollapsed ? l10n.noteExpandAll : l10n.noteCollapseAll,
            icon: Icon(
              allCollapsed
                  ? Icons.unfold_more_rounded
                  : Icons.unfold_less_rounded,
            ),
            onPressed: () => setState(() {
              allCollapsed
                  ? _collapsed.clear()
                  : _collapsed.addAll(sections.map((s) => s.id));
            }),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: l10n.noteMoreActions,
            enabled: !_busy,
            onSelected: _onMenu,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _MenuAction.personalNote,
                child: ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: Text(l10n.personalNote),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.revision,
                child: ListTile(
                  leading: const Icon(Icons.flash_on_rounded),
                  title: Text(l10n.quickRevision),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.flashcards,
                child: ListTile(
                  leading: const Icon(Icons.style_rounded),
                  title: Text(l10n.flashcards),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: Text(l10n.noteDelete),
                ),
              ),
            ],
          ),
        ],
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      bottomNavigationBar: widget.bottomBar,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(note.topicName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  [
                    note.examName,
                    note.subjectName,
                    ?note.parentTopicName,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    Chip(label: Text(noteLevelLabel(l10n, note.level))),
                    Chip(
                      label: Text(
                        note.language == 'hi' ? l10n.hindi : l10n.english,
                      ),
                    ),
                  ],
                ),
                if (widget.banner case final banner?) ...[
                  const SizedBox(height: AppSpacing.xs),
                  banner,
                ],
                const SizedBox(height: AppSpacing.sm),
                // Revision tools (built from this saved note, no AI call).
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _onMenu(_MenuAction.revision),
                      icon: const Icon(Icons.flash_on_rounded),
                      label: Text(l10n.quickRevision),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _onMenu(_MenuAction.flashcards),
                      icon: const Icon(Icons.style_rounded),
                      label: Text(l10n.flashcards),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _PersonalNoteCard(
                  text: note.personalNote,
                  onEdit: _busy ? null : _editPersonalNote,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Learning path: position, progress, Mark as completed,
                // Continue to Next Topic.
                NotePathPanel(note: note),
                const SizedBox(height: AppSpacing.md),
                // Table of contents
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notesContents,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (final (i, s) in sections.indexed)
                          InkWell(
                            onTap: () => _jump(s.id),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: AppSpacing.minTouch - 8,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '${i + 1}.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final s in sections)
                  NoteSectionCard(
                    key: _keys.putIfAbsent(s.id, GlobalKey.new),
                    section: s,
                    expanded: !_collapsed.contains(s.id),
                    onToggle: () => setState(() {
                      _collapsed.contains(s.id)
                          ? _collapsed.remove(s.id)
                          : _collapsed.add(s.id);
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoteSectionCard extends StatelessWidget {
  const NoteSectionCard({
    super.key,
    required this.section,
    required this.expanded,
    required this.onToggle,
  });

  final NoteSec section;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            button: true,
            expanded: expanded,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(section.icon, color: section.color),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        section.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: section.body,
              ),
            ),
        ],
      ),
    );
  }
}

/// The student's own note on this topic (or a button to add one).
class _PersonalNoteCard extends StatelessWidget {
  const _PersonalNoteCard({required this.text, required this.onEdit});

  final String text;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (text.trim().isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_note_rounded),
          label: Text(l10n.personalNoteAdd),
        ),
      );
    }
    return NoteBox(
      color: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.personalNote,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(l10n.personalNoteEdit)),
            ],
          ),
          SelectableText(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Bottom sheet editor; returns the text on Save, null when dismissed.
class _PersonalNoteSheet extends StatefulWidget {
  const _PersonalNoteSheet({required this.initial});
  final String initial;

  @override
  State<_PersonalNoteSheet> createState() => _PersonalNoteSheetState();
}

class _PersonalNoteSheetState extends State<_PersonalNoteSheet> {
  late final _ctl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.personalNote,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _ctl,
            autofocus: true,
            minLines: 4,
            maxLines: 10,
            maxLength: 5000,
            decoration: InputDecoration(hintText: l10n.personalNoteHint),
          ),
          const SizedBox(height: AppSpacing.xs),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ctl.text),
            child: Text(l10n.noteSave),
          ),
        ],
      ),
    );
  }
}
