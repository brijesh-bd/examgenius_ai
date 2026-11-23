import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/study_note.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/note_blocks.dart';

/// Revision tools built only from a saved note's content — no AI call.

/// Uses [initial] when it carries content, otherwise loads the note by id.
class _NoteLoader extends ConsumerWidget {
  const _NoteLoader({
    required this.noteId,
    required this.initial,
    required this.title,
    required this.builder,
  });

  final String noteId;
  final StudyNote? initial;
  final String title;
  final Widget Function(BuildContext, StudyNote) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (initial?.content != null) return builder(context, initial!);
    return ref
        .watch(studyNoteProvider(noteId))
        .when(
          data: (n) => builder(context, n),
          loading: () => Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text(title)),
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

/// Quick revision: key points, one-liners, formulas, tips and mistakes only.
class QuickRevisionScreen extends StatelessWidget {
  const QuickRevisionScreen({super.key, required this.noteId, this.initial});

  final String noteId;
  final StudyNote? initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _NoteLoader(
      noteId: noteId,
      initial: initial,
      title: l10n.quickRevision,
      builder: (context, note) {
        final c = note.content ?? const NoteContent(overview: '');
        final blocks = <(String, IconData, Color, Widget)>[
          if (c.keyPoints.isNotEmpty)
            (
              l10n.nKeyPoints,
              Icons.star_outline_rounded,
              AppColors.banking,
              NoteBullets(
                c.keyPoints,
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.banking,
              ),
            ),
          if (c.quickRevision.isNotEmpty)
            (
              l10n.nRevision,
              Icons.flash_on_rounded,
              AppColors.studyNotes,
              NoteBullets(c.quickRevision),
            ),
          if (c.formulas.isNotEmpty)
            (
              l10n.nFormulas,
              Icons.functions_rounded,
              AppColors.accent,
              Column(
                children: [for (final f in c.formulas) NoteFormulaCard(f)],
              ),
            ),
          if (c.tips.isNotEmpty)
            (
              l10n.nTips,
              Icons.tips_and_updates_outlined,
              AppColors.secondary,
              NoteBullets(
                c.tips,
                icon: Icons.bolt_rounded,
                color: AppColors.secondary,
              ),
            ),
          if (c.mistakes.isNotEmpty)
            (
              l10n.nMistakes,
              Icons.report_gmailerrorred_rounded,
              AppColors.error,
              NoteBullets(
                c.mistakes,
                icon: Icons.close_rounded,
                color: AppColors.error,
              ),
            ),
        ];
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.quickRevision)),
          body: SafeArea(
            top: false,
            child: blocks.isEmpty
                ? StateMessage(
                    icon: Icons.flash_off_rounded,
                    title: l10n.noRevision,
                  )
                : ListView(
                    children: [
                      ResponsiveCenter(
                        padding: const EdgeInsets.all(AppSpacing.page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              note.topicName,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            for (final (title, icon, color, body) in blocks)
                              Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(icon, color: color),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: Semantics(
                                              header: true,
                                              child: Text(
                                                title,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      body,
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// One flashcard: a prompt and its answer.
typedef Flashcard = ({String front, String back});

/// Cards from the note's concepts (term → definition) and formulas
/// (name → expression + meaning). Pure, so it is unit-tested.
List<Flashcard> flashcardsFrom(NoteContent c) => [
  for (final k in c.concepts) (front: k.term, back: k.definition),
  for (final f in c.formulas)
    (
      front: f.name.isEmpty ? f.meaning : f.name,
      back: [
        f.expression,
        if (f.name.isNotEmpty && f.meaning.isNotEmpty) f.meaning,
      ].join('\n\n'),
    ),
];

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key, required this.noteId, this.initial});

  final String noteId;
  final StudyNote? initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _NoteLoader(
      noteId: noteId,
      initial: initial,
      title: l10n.flashcards,
      builder: (context, note) {
        final cards = flashcardsFrom(
          note.content ?? const NoteContent(overview: ''),
        );
        return Scaffold(
          appBar: AppBar(title: Text(l10n.flashcards)),
          body: SafeArea(
            top: false,
            child: cards.isEmpty
                ? StateMessage(
                    icon: Icons.style_outlined,
                    title: l10n.noFlashcards,
                  )
                : _FlashcardDeck(cards: cards),
          ),
        );
      },
    );
  }
}

class _FlashcardDeck extends StatefulWidget {
  const _FlashcardDeck({required this.cards});
  final List<Flashcard> cards;

  @override
  State<_FlashcardDeck> createState() => _FlashcardDeckState();
}

class _FlashcardDeckState extends State<_FlashcardDeck> {
  int _index = 0;
  bool _flipped = false;

  void _go(int delta) => setState(() {
    _index = (_index + delta).clamp(0, widget.cards.length - 1);
    _flipped = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final card = widget.cards[_index];
    final color = _flipped ? AppColors.accent : theme.colorScheme.primary;
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        children: [
          LinearProgressIndicator(value: (_index + 1) / widget.cards.length),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.flashcardCount(_index + 1, widget.cards.length),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Semantics(
              button: true,
              label: l10n.flashcardTapToFlip,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                onTap: () => setState(() => _flipped = !_flipped),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey('$_index-$_flipped'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          _flipped ? card.back : card.front,
                          textAlign: TextAlign.center,
                          style: _flipped
                              ? theme.textTheme.bodyLarge?.copyWith(height: 1.5)
                              : theme.textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!_flipped)
            Text(l10n.flashcardTapToFlip, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index == 0 ? null : () => _go(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: Text(l10n.flashcardPrev),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _index == widget.cards.length - 1
                      ? null
                      : () => _go(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: Text(l10n.flashcardNext),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
