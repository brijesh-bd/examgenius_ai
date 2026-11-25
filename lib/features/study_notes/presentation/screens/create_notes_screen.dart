import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../question_generator/domain/concept_hierarchy.dart';
import '../../../question_generator/domain/syllabus.dart';
import '../../../question_generator/presentation/providers/question_generator_providers.dart';
import '../../domain/study_note.dart';
import '../providers/study_notes_providers.dart';

String noteSectionLabel(AppLocalizations l10n, NoteSection s) => switch (s) {
  NoteSection.explanation => l10n.secExplanation,
  NoteSection.definitions => l10n.secDefinitions,
  NoteSection.examples => l10n.secExamples,
  NoteSection.stepByStep => l10n.secStepByStep,
  NoteSection.diagrams => l10n.secDiagrams,
  NoteSection.graphs => l10n.secGraphs,
  NoteSection.formulas => l10n.secFormulas,
  NoteSection.tips => l10n.secTips,
  NoteSection.mistakes => l10n.secMistakes,
  NoteSection.keyPoints => l10n.secKeyPoints,
  NoteSection.revision => l10n.secRevision,
  NoteSection.mcqs => l10n.secMcqs,
};

String noteLevelLabel(AppLocalizations l10n, NoteLevel l) => switch (l) {
  NoteLevel.basic => l10n.noteLevelBasic,
  NoteLevel.examStandard => l10n.noteLevelExam,
  NoteLevel.advanced => l10n.noteLevelAdvanced,
};

/// Create Notes: shows exam / subject / topic, then language, level and the
/// sections to include. Opens the saved note only after the server saved it.
class CreateNotesScreen extends ConsumerWidget {
  const CreateNotesScreen({
    super.key,
    required this.examId,
    required this.topicId,
    this.prefill,
  });

  final String examId;

  /// A syllabus topic, or a unit of a broad topic (learning path).
  final String topicId;

  /// Language / level carried over (e.g. from "What to Study Next").
  final NotesPrefill? prefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (isConceptNode(topicId)) return _conceptForm(context, ref);
    final syllabus = ref.watch(syllabusProvider(examId));
    // Units are not in the syllabus model; the learning path knows them.
    final path = ref.watch(
      learningPathProvider((examId: examId, subjectId: subjectIdOf(topicId))),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createNotesTitle)),
      body: SafeArea(
        top: false,
        child: syllabus.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(syllabusProvider(examId)),
          ),
          data: (s) {
            final subject = s.subjects
                .where((x) => x.id == subjectIdOf(topicId))
                .firstOrNull;
            final topic = subject?.topics
                .where((t) => t.id == topicId)
                .firstOrNull;
            final unit = path.value?.item(topicId);
            final topicName = topic?.name ?? unit?.fullName;
            if (subject == null || topicName == null) {
              if (path.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return StateMessage(
                icon: Icons.search_off_rounded,
                title: l10n.noteNotFound,
              );
            }
            return _Form(
              target: (
                examId: examId,
                topicId: topicId,
                language: prefill?.language,
                level: prefill?.level,
              ),
              subjectName: subject.name,
              topicName: topicName,
            );
          },
        ),
      ),
    );
  }
}

extension on CreateNotesScreen {
  /// A hierarchical-syllabus node: names come from that subject's tree.
  ConceptKey get _conceptKey =>
      (examId: examId, subjectId: conceptSubjectOf(topicId) ?? kMathSubjectId);

  Widget _conceptForm(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Subject display name from the exam's catalogue (localised by backend).
    final subjects =
        ref.watch(syllabusProvider(examId)).value?.subjects ??
        const <SyllabusSubject>[];
    final tree = ref.watch(conceptHierarchyProvider(_conceptKey));
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createNotesTitle)),
      body: SafeArea(
        top: false,
        child: tree.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () =>
                ref.invalidate(conceptHierarchyProvider(_conceptKey)),
          ),
          data: (t) {
            final path = t?.pathOf(topicId) ?? const <ConceptNode>[];
            if (path.isEmpty) {
              return StateMessage(
                icon: Icons.search_off_rounded,
                title: l10n.noteNotFound,
              );
            }
            return _Form(
              target: (
                examId: examId,
                topicId: topicId,
                language: prefill?.language,
                level: prefill?.level,
              ),
              subjectName:
                  subjects
                      .where((x) => x.id == _conceptKey.subjectId)
                      .firstOrNull
                      ?.name ??
                  _conceptKey.subjectId,
              topicName: path.map((n) => n.title(hi ? 'hi' : 'en')).join(' › '),
            );
          },
        ),
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({
    required this.target,
    required this.subjectName,
    required this.topicName,
  });

  final NotesTarget target;
  final String subjectName;
  final String topicName;
  String get examId => target.examId;

  Future<void> _generate(
    BuildContext context,
    WidgetRef ref,
    NotesTarget target,
  ) async {
    final note = await ref.read(notesFormProvider(target).notifier).generate();
    if (note == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.notesSaved)));
    context.pushReplacement(AppRoutes.noteViewFor(note.id), extra: note);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final exam = ref.watch(examByIdProvider(examId));
    final form = ref.watch(notesFormProvider(target));
    final ctl = ref.read(notesFormProvider(target).notifier);

    Widget info(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.titleSmall)),
        ],
      ),
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ResponsiveCenter(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: AbsorbPointer(
                  absorbing: form.generating,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              info(l10n.notesExam, exam?.name ?? examId),
                              info(l10n.notesSubject, subjectName),
                              info(l10n.notesTopic, topicName),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: l10n.language),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'en', label: Text(l10n.english)),
                          ButtonSegment(value: 'hi', label: Text(l10n.hindi)),
                        ],
                        selected: {form.language},
                        onSelectionChanged: (v) => ctl.setLanguage(v.first),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: l10n.notesLevel),
                      SegmentedButton<NoteLevel>(
                        showSelectedIcon: false,
                        segments: [
                          for (final lv in NoteLevel.values)
                            ButtonSegment(
                              value: lv,
                              label: Text(noteLevelLabel(l10n, lv)),
                            ),
                        ],
                        selected: {form.level},
                        onSelectionChanged: (v) => ctl.setLevel(v.first),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(
                        title: l10n.notesSections,
                        action: l10n.notesSectionsReset,
                        onAction: ctl.resetSections,
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final s in NoteSection.values)
                            FilterChip(
                              label: Text(noteSectionLabel(l10n, s)),
                              selected: form.sections.contains(s),
                              onSelected: (_) => ctl.toggle(s),
                            ),
                        ],
                      ),
                      if (form.sections.isEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.notesPickOneSection,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                      if (form.error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Card(
                          color: theme.colorScheme.errorContainer,
                          child: ListTile(
                            leading: Icon(
                              Icons.error_outline_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            title: Text(
                              l10n.notesFailed,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            subtitle: Text(
                              apiErrorText(l10n, form.error),
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: ResponsiveCenter(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xs,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (form.generating) ...[
                  Text(
                    l10n.generatingNotes,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                PrimaryButton(
                  label: l10n.generateNotes,
                  icon: Icons.auto_awesome_rounded,
                  loading: form.generating,
                  onPressed: form.canGenerate
                      ? () => _generate(context, ref, target)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
