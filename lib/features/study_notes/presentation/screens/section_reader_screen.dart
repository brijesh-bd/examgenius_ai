import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/note_outline.dart';
import '../providers/study_notes_providers.dart';
import 'note_view_screen.dart';
import 'outline_screen.dart';

/// One outline section: its notes plus Previous / Mark complete / Next.
/// On failure (e.g. AI quota used up) the student stays on this section and
/// can retry later — nothing was saved.
class SectionReaderScreen extends ConsumerWidget {
  const SectionReaderScreen({
    super.key,
    required this.outlineKey,
    required this.section,
  });

  final OutlineKey outlineKey;
  final SectionRef section;

  SectionKey get _key => (outline: outlineKey, section: section);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final opened = ref.watch(openSectionProvider(_key));
    final nav = _SectionNavBar(outlineKey: outlineKey, section: section);

    return opened.when(
      data: (s) => NoteViewScreen(
        noteId: s.note.id,
        initial: s.note,
        banner: s.isSample
            ? const SampleContentBanner()
            : ContentStatusBanner(opened: s),
        bottomBar: nav,
      ),
      loading: () => Scaffold(
        appBar: AppBar(),
        bottomNavigationBar: nav,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.sectionPreparing),
            ],
          ),
        ),
      ),
      error: (e, _) {
        void retry() {
          ref.invalidate(openSectionProvider(_key));
          ref.invalidate(outlineProvider(outlineKey));
        }

        // Another request is preparing this section (202): check again.
        if (e is SectionGeneratingException) {
          return Scaffold(
            appBar: AppBar(),
            bottomNavigationBar: nav,
            body: StateMessage(
              icon: Icons.hourglass_top_rounded,
              title: l10n.sectionGeneratingTitle,
              body: l10n.sectionGeneratingBody,
              actionLabel: l10n.checkAgain,
              onAction: retry,
            ),
          );
        }
        // Checked against the coverage list and still incomplete: say what.
        final missing = e is ApiException && e.code == 'CONTENT_INCOMPLETE'
            ? [
                for (final k in [
                  'missingConcepts',
                  'missingFacts',
                  'missingBlocks',
                ])
                  for (final v in (e.details[k] as List<dynamic>? ?? const []))
                    v.toString().replaceAll('_', ' '),
              ]
            : const <String>[];
        return Scaffold(
          appBar: AppBar(),
          bottomNavigationBar: nav,
          body: StateMessage(
            icon: missing.isEmpty
                ? Icons.cloud_off_rounded
                : Icons.rule_rounded,
            title: apiErrorText(l10n, e),
            body: missing.isEmpty
                ? null
                : l10n.sectionMissingList(missing.join(', ')),
            actionLabel: l10n.retry,
            onAction: retry,
          ),
        );
      },
    );
  }
}

/// What the content is: AI-checked or expert-reviewed, preview, facts
/// unverified, structure-only check. Never claims more than the server says.
class ContentStatusBanner extends StatelessWidget {
  const ContentStatusBanner({super.key, required this.opened});
  final OpenedSection opened;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = <(IconData, String)>[
      if (opened.contentStatus == 'ready_for_review')
        (Icons.rate_review_outlined, l10n.statusUnderReview)
      else if (opened.review == 'human')
        (Icons.verified_outlined, l10n.statusReviewed)
      else
        (Icons.smart_toy_outlined, l10n.statusAiChecked),
      if (opened.verification != 'sources_listed')
        (Icons.info_outline_rounded, l10n.statusFactsUnverified),
      if (opened.coverageBasis == 'structure_only')
        (Icons.rule_rounded, l10n.statusStructureOnly),
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: 4,
      children: [
        for (final (icon, text) in items)
          Chip(
            visualDensity: VisualDensity.compact,
            avatar: Icon(icon, size: 16),
            label: Text(text, style: theme.textTheme.labelSmall),
          ),
      ],
    );
  }
}

class _SectionNavBar extends ConsumerStatefulWidget {
  const _SectionNavBar({required this.outlineKey, required this.section});

  final OutlineKey outlineKey;
  final SectionRef section;

  @override
  ConsumerState<_SectionNavBar> createState() => _SectionNavBarState();
}

class _SectionNavBarState extends ConsumerState<_SectionNavBar> {
  bool _saving = false;

  void _go((OutlineChapter, OutlineSection)? target) {
    if (target == null) return;
    context.pushReplacement(
      notesSectionRoute(widget.outlineKey, target.$1.id, target.$2.id),
    );
  }

  Future<void> _toggle(bool completed) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(outlineRepositoryProvider)
          .setSectionCompleted(
            widget.outlineKey,
            widget.section,
            completed: completed,
          );
      ref.invalidate(outlineProvider(widget.outlineKey));
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(apiErrorText(context.l10n, e)),
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
    final outline = ref.watch(outlineProvider(widget.outlineKey)).value;
    final opened = ref
        .watch(
          openSectionProvider((
            outline: widget.outlineKey,
            section: widget.section,
          )),
        )
        .hasValue;
    final i = outline?.indexOf(widget.section) ?? -1;
    final current = outline?.at(i)?.$2;
    final done = current?.state == SectionState.completed;

    return SafeArea(
      child: Material(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outline != null && i >= 0)
                Text(
                  l10n.sectionOf(i + 1, outline.total),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.sectionPrevious,
                    onPressed: outline?.at(i - 1) == null
                        ? null
                        : () => _go(outline!.at(i - 1)),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: done
                        ? OutlinedButton.icon(
                            onPressed: _saving ? null : () => _toggle(false),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                            ),
                            label: Text(l10n.sectionMarkedComplete),
                          )
                        : FilledButton.icon(
                            // Only a section that loaded can be completed.
                            onPressed: _saving || !opened
                                ? null
                                : () => _toggle(true),
                            icon: const Icon(Icons.done_rounded),
                            label: Text(l10n.sectionMarkComplete),
                          ),
                  ),
                  IconButton(
                    tooltip: l10n.sectionNext,
                    onPressed: outline?.at(i + 1) == null
                        ? null
                        : () => _go(outline!.at(i + 1)),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
