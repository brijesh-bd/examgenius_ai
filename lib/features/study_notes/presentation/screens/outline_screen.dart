import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../localization/settings_providers.dart';
import '../../domain/note_outline.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/hierarchy_tree.dart';

String learningModeLabel(AppLocalizations l10n, LearningMode m) => switch (m) {
  LearningMode.quick => l10n.learningModeQuick,
  LearningMode.detailed => l10n.learningModeDetailed,
  LearningMode.complete => l10n.learningModeComplete,
};

/// "Development sample" label for fixture content (never real material).
class SampleContentBanner extends StatelessWidget {
  const SampleContentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              Icons.science_outlined,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                context.l10n.sampleContentLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outline preview: chapters → sections with this student's progress,
/// learning mode picker and "Continue" to the first unfinished section.
class OutlineScreen extends ConsumerStatefulWidget {
  const OutlineScreen({super.key, required this.examId, required this.unitId});

  final String examId;
  final String unitId;

  @override
  ConsumerState<OutlineScreen> createState() => _OutlineScreenState();
}

class _OutlineScreenState extends ConsumerState<OutlineScreen> {
  LearningMode _mode = LearningMode.complete;

  OutlineKey get _key => (
    examId: widget.examId,
    unitId: widget.unitId,
    language: ref.read(localeProvider).languageCode == 'hi' ? 'hi' : 'en',
    mode: _mode,
  );

  Future<void> _open(OutlineKey key, SectionRef s) async {
    await context.push(notesSectionRoute(key, s.chapterId, s.sectionId));
    // Progress may have changed while reading.
    if (mounted) ref.invalidate(outlineProvider(key));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    ref.watch(localeProvider);
    final key = _key;
    final outline = ref.watch(outlineProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(outline.value?.title ?? '')),
      body: outline.when(
        loading: () => ResponsiveCenter(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                const Skeleton(height: 72),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
        error: (e, _) => _OutlineError(error: e, outlineKey: key),
        data: (o) => RefreshIndicator(
          onRefresh: () => ref.refresh(outlineProvider(key).future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              if (o.isSample) ...[
                const SampleContentBanner(),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (o.fromAi)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_outlined, size: 18),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        l10n.outlineAiReviewed,
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              if (o.isDraft)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        l10n.outlineDraft,
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              SegmentedButton<LearningMode>(
                segments: [
                  for (final m in LearningMode.values)
                    ButtonSegment(
                      value: m,
                      label: Text(
                        learningModeLabel(l10n, m),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              // Content coverage (shared) and the student's progress, apart.
              Text(
                l10n.outlineContentCoverage(o.contentReady, o.total),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: o.total == 0 ? 0 : o.contentReady / o.total,
                minHeight: 4,
                color: AppColors.success,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                o.coverageComplete
                    ? l10n.outlineCoverageComplete
                    : l10n.outlineProgress(o.completed, o.total),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: o.total == 0 ? 0 : o.completed / o.total,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              if (o.continueAt case final next?) ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => _open(key, next),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.outlineContinue),
                ),
              ],
              // LEARNING_COMPLETED: no new parts; point to final revision.
              if (o.coverageComplete && o.revisionPlan.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.outlineRevisionPlan),
                        for (final (i, step) in o.revisionPlan.indexed)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${i + 1}. $step'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              for (final c in o.chapters)
                _ChapterCard(chapter: c, onOpen: (s) => _open(key, s)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Outline could not be shown. A topic without an index offers the Chapter
/// Builder; one waiting for review says so; anything else can be retried.
class _OutlineError extends ConsumerWidget {
  const _OutlineError({required this.error, required this.outlineKey});

  final Object error;
  final OutlineKey outlineKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = error is ApiException ? (error as ApiException).code : null;
    final request = ref.watch(chapterIndexProvider);
    final pending =
        code == 'OUTLINE_PENDING_REVIEW' ||
        request.value == ChapterIndexStatus.pendingReview;
    if (pending) {
      return StateMessage(
        icon: Icons.hourglass_top_rounded,
        title: l10n.chapterIndexPendingTitle,
        body: l10n.chapterIndexPendingBody,
      );
    }
    if (code == 'NO_OUTLINE' && request.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (code == 'NO_OUTLINE') {
      return StateMessage(
        icon: Icons.auto_awesome_outlined,
        title: request.hasError
            ? apiErrorText(l10n, request.error)
            : l10n.chapterIndexMissingTitle,
        body: l10n.chapterIndexMissingBody,
        actionLabel: l10n.chapterIndexBuild,
        onAction: () =>
            ref.read(chapterIndexProvider.notifier).request(outlineKey),
      );
    }
    return StateMessage(
      icon: Icons.error_outline_rounded,
      title: apiErrorText(l10n, error),
      actionLabel: l10n.retry,
      onAction: () => ref.invalidate(outlineProvider(outlineKey)),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter, required this.onOpen});

  final OutlineChapter chapter;
  final void Function(SectionRef) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        initiallyExpanded: !chapter.complete,
        title: Text(chapter.title),
        subtitle: Text(
          [
            '${chapter.completed}/${chapter.sections.length}',
            if (chapter.weight == 'high') l10n.sectionOftenTested,
          ].join(' · '),
        ),
        leading: Icon(
          chapter.complete
              ? Icons.check_circle_rounded
              : Icons.menu_book_rounded,
          color: chapter.complete
              ? AppColors.success
              : theme.colorScheme.primary,
        ),
        children: [
          for (final (i, s) in chapter.sections.indexed) ...[
            // Nested outlines: a subtopic heading whenever the path changes.
            for (final (d, title) in s.path.indexed)
              if (i == 0 ||
                  chapter.sections[i - 1].path.length <= d ||
                  chapter.sections[i - 1].path[d] != title)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.0 + d * 16,
                    8,
                    16,
                    2,
                  ),
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsetsDirectional.only(
                start: 16.0 + s.path.length * 16,
                end: 16,
              ),
              leading: _SectionStateIcon(s.state),
              title: Text(s.title),
              subtitle: Text(
                [
                  _stateLabel(l10n, s.state),
                  // Shared content readiness, not the student's progress.
                  contentLook(
                    l10n,
                    _wire(s.contentStatus),
                    theme.colorScheme,
                  ).label,
                  if (s.origin == 'recommended') l10n.sectionRecommended,
                  if (s.origin == 'ai_suggested') l10n.sectionAiSuggested,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onOpen((chapterId: chapter.id, sectionId: s.id)),
            ),
          ],
        ],
      ),
    );
  }
}

String _wire(ContentStatus c) => switch (c) {
  ContentStatus.ready => 'ready',
  ContentStatus.generating => 'generating',
  ContentStatus.incomplete => 'incomplete',
  ContentStatus.validationFailed => 'validation_failed',
  ContentStatus.failed => 'failed',
  ContentStatus.notGenerated => 'not_generated',
};

String _stateLabel(AppLocalizations l10n, SectionState s) => switch (s) {
  SectionState.pending => l10n.sectionStatePending,
  SectionState.generated => l10n.sectionStateGenerated,
  SectionState.completed => l10n.sectionStateCompleted,
  SectionState.failed => l10n.sectionStateFailed,
};

class _SectionStateIcon extends StatelessWidget {
  const _SectionStateIcon(this.state);
  final SectionState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (state) {
      SectionState.completed => (Icons.check_circle_rounded, AppColors.success),
      SectionState.generated => (Icons.article_outlined, scheme.primary),
      SectionState.failed => (Icons.error_outline_rounded, scheme.error),
      SectionState.pending => (Icons.radio_button_unchecked, scheme.outline),
    };
    return Icon(icon, color: color, size: 20);
  }
}

String notesSectionRoute(OutlineKey k, String chapterId, String sectionId) =>
    AppRoutes.notesSectionPath(
      k.examId,
      k.unitId,
      chapterId,
      sectionId,
      language: k.language,
      mode: k.mode.wire,
    );
