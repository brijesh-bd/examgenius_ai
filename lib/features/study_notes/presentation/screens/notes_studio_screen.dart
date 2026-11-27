import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../dashboard/domain/dashboard_models.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';
import '../../../question_generator/domain/concept_hierarchy.dart';
import '../../../question_generator/domain/syllabus.dart';
import '../../../question_generator/presentation/providers/question_generator_providers.dart';
import '../../../question_generator/presentation/widgets/concept_tree.dart';
import '../../../question_generator/presentation/widgets/practice_setup_widgets.dart';
import '../../domain/study_note.dart';
import '../providers/notes_studio_providers.dart';
import 'note_view_screen.dart' show NoteSec, NoteSectionCard, noteSections;

/// AI Study Notes on one progressive screen, with the same chip selection as
/// Create Practice: category → exam → subject → syllabus tree (chapter /
/// topic / subtopic / micro-topic, searchable) → topic overview → Generate
/// complete notes. No difficulty or section choices: the notes cover the
/// whole selected topic. Old notes links open here with a preselection.
class NotesStudioScreen extends ConsumerWidget {
  const NotesStudioScreen({super.key, this.args = _none});

  static const NotesStudioArgs _none = (
    categoryId: null,
    examId: null,
    subjectId: null,
    targetId: null,
    language: null,
  );

  final NotesStudioArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nothing given: start from the student's target exam.
    final start = args.categoryId == null && args.examId == null
        ? (
            categoryId: null,
            examId: ref.read(sessionProvider)?.targetExamId,
            subjectId: null,
            targetId: null,
            language: args.language,
          )
        : args;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aiStudyNotes)),
      body: _Studio(args: start),
    );
  }
}

class _Studio extends ConsumerWidget {
  const _Studio({required this.args});

  final NotesStudioArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(examCatalogProvider);
    return catalog.when(
      loading: () => const _Skeletons(count: 4),
      error: (e, _) => StateMessage(
        icon: Icons.wifi_off_rounded,
        title: apiErrorText(l10n, e),
        actionLabel: l10n.retry,
        onAction: () => ref.invalidate(examCatalogProvider),
      ),
      data: (cats) => _Selection(args: args, categories: cats),
    );
  }
}

class _Selection extends ConsumerWidget {
  const _Selection({required this.args, required this.categories});

  final NotesStudioArgs args;
  final List<ExamCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(notesStudioProvider(args));
    final c = ref.read(notesStudioProvider(args).notifier);
    final locked = s.generating;

    // Category: chosen, or the one containing the chosen exam, or the first.
    final category =
        categories.where((x) => x.id == s.categoryId).firstOrNull ??
        categories
            .where((x) => x.exams.any((e) => e.id == s.examId))
            .firstOrNull ??
        categories.firstOrNull;
    final exam = category?.exams.where((e) => e.id == s.examId).firstOrNull;

    // While writing (or after a dropped connection) the notes so far are
    // shown here; the selection comes back once done or dismissed.
    if (s.generating || (s.error != null && s.partial != null)) {
      return Column(
        children: [
          Expanded(child: _LiveNotes(content: s.partial)),
          _BottomBar(args: args),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xs,
                  AppSpacing.page,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Exam category
                    SetupLabel(l10n.notesStepCategory),
                    _Chips(
                      children: [
                        for (final x in categories)
                          ChoiceChip(
                            key: ValueKey('cat_${x.id}'),
                            label: Text(categoryStyle(context, x).shortLabel),
                            selected: x.id == category?.id,
                            onSelected: locked
                                ? null
                                : (_) => c.selectCategory(x.id),
                          ),
                      ],
                    ),
                    // 2. Exam
                    if (category != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SetupLabel(l10n.stepExam),
                      _Chips(
                        children: [
                          for (final e in category.exams)
                            ChoiceChip(
                              key: ValueKey('exam_${e.id}'),
                              label: Text(e.name),
                              selected: e.id == exam?.id,
                              onSelected: locked
                                  ? null
                                  : (_) => c.selectExam(
                                      e.id,
                                      categoryId: category.id,
                                    ),
                            ),
                        ],
                      ),
                    ],
                    // 3. Subject → syllabus → overview
                    if (exam != null)
                      _ExamSyllabus(args: args, examId: exam.id),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomBar(args: args),
      ],
    );
  }
}

class _ExamSyllabus extends ConsumerWidget {
  const _ExamSyllabus({required this.args, required this.examId});

  final NotesStudioArgs args;
  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(notesStudioProvider(args));
    final c = ref.read(notesStudioProvider(args).notifier);
    final syllabus = ref.watch(syllabusProvider(examId));

    return switch (syllabus) {
      AsyncData(:final value) when value.subjects.isEmpty => StateMessage(
        icon: Icons.menu_book_outlined,
        title: l10n.comingSoon,
      ),
      AsyncData(:final value) => _subjects(context, ref, value, s, c),
      AsyncError(:final error) => StateMessage(
        icon: Icons.wifi_off_rounded,
        title: apiErrorText(l10n, error),
        actionLabel: l10n.retry,
        onAction: () => ref.invalidate(syllabusProvider(examId)),
      ),
      _ => const Padding(
        padding: EdgeInsets.only(top: AppSpacing.lg),
        child: _Skeletons(count: 2, padded: false),
      ),
    };
  }

  Widget _subjects(
    BuildContext context,
    WidgetRef ref,
    Syllabus syllabus,
    NotesStudio s,
    NotesStudioController c,
  ) {
    final l10n = context.l10n;
    final subject = syllabus.subjects
        .where((x) => x.id == s.subjectId)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SetupLabel(l10n.stepSubject),
        _Chips(
          children: [
            for (final x in syllabus.subjects)
              ChoiceChip(
                key: ValueKey('subject_${x.id}'),
                label: Text(x.name),
                selected: x.id == subject?.id,
                onSelected: s.generating ? null : (_) => c.selectSubject(x.id),
              ),
          ],
        ),
        if (subject != null)
          _SubjectTopics(args: args, examId: examId, subject: subject),
      ],
    );
  }
}

/// The subject's syllabus: the hierarchical tree when it has one (any
/// level selectable), otherwise its topics as chips. Then the overview.
class _SubjectTopics extends ConsumerWidget {
  const _SubjectTopics({
    required this.args,
    required this.examId,
    required this.subject,
  });

  final NotesStudioArgs args;
  final String examId;
  final SyllabusSubject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(notesStudioProvider(args));
    final c = ref.read(notesStudioProvider(args).notifier);
    final key = (examId: examId, subjectId: subject.id);
    final treeAsync = ref.watch(conceptHierarchyProvider(key));

    Widget hint(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.tiny.copyWith(color: scheme.onSurfaceVariant),
      ),
    );

    final List<Widget> picker = switch (treeAsync) {
      AsyncData(value: final ConceptHierarchy tree)
          when tree.chapters.isNotEmpty =>
        [
          hint(l10n.notesTopicHint),
          if (!tree.hasOfficial) hint(l10n.syllabusUnverifiedNote),
          ConceptTree(
            key: ValueKey('tree_${examId}_${subject.id}'),
            tree: tree,
            languageCode: s.language,
            picked: s.targetId,
            enabled: !s.generating,
            onPick: c.pick,
          ),
        ],
      AsyncData() => [
        hint(l10n.notesNoTreeHint),
        _Chips(
          children: [
            for (final t in subject.topics)
              ChoiceChip(
                key: ValueKey('topic_${t.id}'),
                label: Text(t.name),
                selected: t.id == s.targetId,
                onSelected: s.generating ? null : (_) => c.pick(t.id),
              ),
          ],
        ),
      ],
      AsyncError(:final error) => [
        StateMessage(
          icon: Icons.wifi_off_rounded,
          title: apiErrorText(l10n, error),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(conceptHierarchyProvider(key)),
        ),
      ],
      _ => [const _Skeletons(count: 3, padded: false)],
    };

    final tree = treeAsync.value;
    final target = s.targetId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SetupLabel(l10n.notesStepTopic),
        ...picker,
        if (target != null) ...[
          const SizedBox(height: AppSpacing.lg),
          SetupLabel(l10n.notesLanguageLabel),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(l10n.english)),
                ButtonSegment(value: 'hi', label: Text(l10n.hindi)),
              ],
              selected: {s.language},
              onSelectionChanged: s.generating
                  ? null
                  : (v) => c.setLanguage(v.first),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TopicOverview(
            examId: examId,
            targetId: target,
            language: s.language,
            tree: tree != null && tree.contains(target) ? tree : null,
            fallbackTitle: subject.topics
                .where((t) => t.id == target)
                .firstOrNull
                ?.name,
          ),
        ],
      ],
    );
  }
}

/// Topic overview: the syllabus path and subtopics (from the tree, instant)
/// plus a short AI summary (cached on the server). Never full notes.
class _TopicOverview extends ConsumerWidget {
  const _TopicOverview({
    required this.examId,
    required this.targetId,
    required this.language,
    this.tree,
    this.fallbackTitle,
  });

  final String examId;
  final String targetId;
  final String language;
  final ConceptHierarchy? tree;
  final String? fallbackTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final key = (examId: examId, targetId: targetId, language: language);
    final summary = ref.watch(topicSummaryProvider(key));
    final path = tree?.pathOf(targetId) ?? const <ConceptNode>[];
    final node = tree?.node(targetId);
    final title = node?.title(language) ?? fallbackTitle ?? '';
    final subtopics = [
      for (final ch in node?.children ?? const <ConceptNode>[])
        ch.title(language),
    ];

    return Container(
      key: const Key('topicOverview'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.topicSummaryTitle,
            style: AppTextStyles.tiny.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.titleMedium),
          if (path.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                path.map((p) => p.title(language)).join(' › '),
                style: AppTextStyles.tiny.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (subtopics.isNotEmpty)
            _Block(
              title: l10n.topicSummarySubtopics,
              child: Wrap(
                spacing: AppSpacing.xxs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final t in subtopics)
                    Chip(label: Text(t), visualDensity: VisualDensity.compact),
                ],
              ),
            ),
          ...switch (summary) {
            AsyncData(:final value) => _summary(l10n, value),
            AsyncError() => [
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.topicSummaryUnavailable,
                style: AppTextStyles.bodySmall,
              ),
              TextButton.icon(
                onPressed: () => ref.invalidate(topicSummaryProvider(key)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
            _ => [
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < 3; i++) ...[
                const Skeleton(height: 14),
                const SizedBox(height: 6),
              ],
            ],
          },
        ],
      ),
    );
  }

  List<Widget> _summary(AppLocalizations l10n, TopicSummary v) => [
    _Block(title: l10n.topicSummaryCovers, child: Text(v.covers)),
    if (v.keyConcepts.isNotEmpty)
      _Block(title: l10n.topicSummaryConcepts, child: _Bullets(v.keyConcepts)),
    if (v.definitions.isNotEmpty)
      _Block(
        title: l10n.topicSummaryDefinitions,
        child: _Bullets([
          for (final d in v.definitions) '${d.term}: ${d.definition}',
        ]),
      ),
    if (v.formulas.isNotEmpty)
      _Block(
        title: l10n.topicSummaryFormulas,
        child: _Bullets([
          for (final f in v.formulas)
            f.name.isEmpty ? f.expression : '${f.name}: ${f.expression}',
        ]),
      ),
    if (v.principles.isNotEmpty)
      _Block(title: l10n.topicSummaryPrinciples, child: _Bullets(v.principles)),
    if (v.examFocus.isNotEmpty)
      _Block(title: l10n.topicSummaryExamFocus, child: _Bullets(v.examFocus)),
  ];
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),
        const SizedBox(height: 4),
        child,
      ],
    ),
  );
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final t in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  '),
              Expanded(child: Text(t, style: AppTextStyles.body)),
            ],
          ),
        ),
    ],
  );
}

/// Generate button, or generation progress, or the failure with retry.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.args});

  final NotesStudioArgs args;

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final note = await ref.read(notesStudioProvider(args).notifier).generate();
    if (note == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.notesSaved)));
    // Push (not replace): back returns to the same selection for the next topic.
    await context.push(AppRoutes.noteViewFor(note.id), extra: note);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(notesStudioProvider(args));
    if (s.generating) return _GenerationProgress(state: s);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s.error != null)
          ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xs,
              AppSpacing.page,
              0,
            ),
            child: _GenerationError(
              error: s.error!,
              partialKept: s.partial != null,
            ),
          ),
        if (s.error != null && s.partial != null)
          TextButton(
            onPressed: () =>
                ref.read(notesStudioProvider(args).notifier).dismissPartial(),
            child: Text(l10n.changeSelection),
          ),
        GenerateBar(
          label: l10n.generateCompleteNotes,
          hint: s.targetId == null ? l10n.notesSelectTopicFirst : null,
          busy: false,
          onPressed: s.canGenerate ? () => _generate(context, ref) : null,
        ),
      ],
    );
  }
}

class _GenerationError extends StatelessWidget {
  const _GenerationError({required this.error, this.partialKept = false});

  final Object error;

  /// Partial notes are still on screen; Retry resumes (same request key).
  final bool partialKept;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('generationError'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.genFailedTitle,
            style: AppTextStyles.label.copyWith(color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 2),
          Text(
            apiErrorText(l10n, error),
            style: AppTextStyles.body.copyWith(color: scheme.onErrorContainer),
          ),
          Text(
            partialKept ? l10n.genPartialKept : l10n.genNothingSaved,
            style: AppTextStyles.tiny.copyWith(color: scheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

/// Generation in progress: the REAL stage the server reports (checking,
/// writing with the parts received so far, saving), real elapsed time and an
/// indeterminate bar. No invented percentages.
class _GenerationProgress extends StatefulWidget {
  const _GenerationProgress({required this.state});

  final NotesStudio state;

  @override
  State<_GenerationProgress> createState() => _GenerationProgressState();
}

class _GenerationProgressState extends State<_GenerationProgress> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _stage(AppLocalizations l10n, NotesStudio s) {
    final parts = s.partial == null ? 0 : noteSections(l10n, s.partial!).length;
    return switch (s.stage) {
      NotesStage.saving => l10n.genStageSaving,
      NotesStage.generating when s.joined && parts == 0 => l10n.genStageJoined,
      NotesStage.generating when parts > 0 => l10n.genStageWriting(parts),
      NotesStage.generating => l10n.genStageStarting,
      _ => l10n.genStageChecking,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final s = widget.state;
    final elapsed = s.startedAt == null
        ? Duration.zero
        : DateTime.now().difference(s.startedAt!);
    final mm = elapsed.inMinutes.toString();
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Material(
      key: const Key('generationProgress'),
      elevation: 3,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _stage(l10n, s),
                      key: const Key('generationStage'),
                      style: AppTextStyles.label,
                    ),
                  ),
                  Text(
                    l10n.genElapsed('$mm:$ss'),
                    style: AppTextStyles.tiny.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              // Indeterminate: the final length is unknown until it is done.
              LinearProgressIndicator(
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.genLeaveHint,
                style: AppTextStyles.tiny.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The notes as they are written (partial content, rendered with the note
/// page's own section cards). Also kept on screen after a dropped connection.
class _LiveNotes extends StatelessWidget {
  const _LiveNotes({required this.content});

  final NoteContent? content;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sections = content == null
        ? const <NoteSec>[]
        : noteSections(l10n, content!);
    return ListView(
      key: const Key('liveNotes'),
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.genLiveTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (sections.isEmpty)
                for (var i = 0; i < 4; i++) ...[
                  const Skeleton(height: 16),
                  const SizedBox(height: AppSpacing.xs),
                ],
              for (final sec in sections)
                NoteSectionCard(
                  key: ValueKey('live_${sec.id}'),
                  section: sec,
                  expanded: true,
                  onToggle: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    children: children,
  );
}

class _Skeletons extends StatelessWidget {
  const _Skeletons({required this.count, this.padded = true});

  final int count;
  final bool padded;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padded ? const EdgeInsets.all(AppSpacing.page) : EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          const Skeleton(height: 48, radius: AppSpacing.tileRadius),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    ),
  );
}
