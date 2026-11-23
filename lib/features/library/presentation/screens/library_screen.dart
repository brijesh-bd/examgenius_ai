import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../dashboard/domain/dashboard_models.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';
import '../../../question_generator/presentation/widgets/generator_options.dart';
import '../../../study_notes/domain/notes_library.dart';
import '../../../study_notes/presentation/providers/study_notes_providers.dart';
import '../../domain/library_models.dart';
import '../providers/library_providers.dart';

/// My Learning Library (Saved tab): totals, one library per category,
/// recently generated sets. Category data is only shown inside its own
/// library screen, so Railway / SSC / Banking never mix.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(librarySummaryProvider);
    final catalog = ref.watch(examCatalogProvider);
    final notes = ref.watch(notesSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myLibrary)),
      body: SafeArea(
        top: false,
        child: summary.when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const _LoadingView(),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(librarySummaryProvider),
          ),
          data: (s) => RefreshIndicator(
            onRefresh: () {
              ref.invalidate(notesSummaryProvider);
              return ref.refresh(librarySummaryProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                ResponsiveCenter(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatsRow(summary: s),
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: l10n.myPracticeSets),
                      switch (catalog) {
                        AsyncData(:final value) => _CategoryGrid(
                          categories: value,
                          card: (cat) {
                            final count = s.countFor(cat.id);
                            final style = categoryStyle(context, cat);
                            return _CategoryCard(
                              category: cat,
                              title: l10n.categoryLibraryTitle(
                                style.shortLabel,
                              ),
                              subtitle: count.sets == 0
                                  ? l10n.librarySetsCount(0)
                                  : '${l10n.librarySetsCount(count.sets)} · '
                                        '${l10n.questionsShort(count.questions)}',
                              semanticCount: l10n.librarySetsCount(count.sets),
                              onTap: () => context.push(
                                AppRoutes.libraryCategoryFor(cat.id),
                              ),
                            );
                          },
                        ),
                        AsyncError(:final error) => StateMessage(
                          icon: Icons.wifi_off_rounded,
                          title: apiErrorText(l10n, error),
                          actionLabel: l10n.retry,
                          onAction: () => ref.invalidate(examCatalogProvider),
                        ),
                        _ => const Skeleton(
                          height: 120,
                          radius: AppSpacing.tileRadius,
                        ),
                      },
                      const SizedBox(height: AppSpacing.lg),
                      SectionHeader(title: l10n.myStudyNotes),
                      _NotesSection(categories: catalog.value, notes: notes),
                      const SizedBox(height: AppSpacing.lg),
                      if (s.totalSets == 0 && (notes.value?.total ?? 0) == 0)
                        StateMessage(
                          icon: Icons.auto_stories_outlined,
                          title: l10n.libraryEmptyTitle,
                          body: l10n.libraryEmptyBody,
                        )
                      else if (s.totalSets > 0) ...[
                        SectionHeader(title: l10n.recentPracticeSets),
                        for (final set in s.recent) ...[
                          _RecentTile(
                            set: set,
                            category: catalog.value
                                ?.where((c) => c.id == set.category)
                                .firstOrNull,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      children: const [
        ResponsiveCenter(
          child: Column(
            children: [
              Skeleton(height: 84, radius: AppSpacing.tileRadius),
              SizedBox(height: AppSpacing.lg),
              Skeleton(height: 120, radius: AppSpacing.tileRadius),
              SizedBox(height: AppSpacing.lg),
              Skeleton(height: 64, radius: AppSpacing.tileRadius),
              SizedBox(height: AppSpacing.xs),
              Skeleton(height: 64, radius: AppSpacing.tileRadius),
            ],
          ),
        ),
      ],
    );
  }
}

/// Totals: sets, questions, bookmarks, notes.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});
  final LibrarySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = [
      (
        Icons.library_books_rounded,
        summary.totalSets,
        l10n.libraryStatSets,
        AppColors.primary,
      ),
      (
        Icons.quiz_rounded,
        summary.totalQuestions,
        l10n.libraryStatQuestions,
        AppColors.secondary,
      ),
      (
        Icons.bookmark_rounded,
        summary.bookmarks,
        l10n.bookmarks,
        AppColors.accent,
      ),
      (
        Icons.sticky_note_2_rounded,
        summary.notes,
        l10n.libraryStatNotes,
        AppColors.success,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _StatTile(
              icon: tiles[i].$1,
              value: tiles[i].$2,
              label: tiles[i].$3,
              color: tiles[i].$4,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label $value',
      child: ExcludeSemantics(
        child: DashboardCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          radius: AppSpacing.tileRadius,
          color: color.withValues(alpha: 0.08),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                NumberFormat.compact().format(value),
                style: AppTextStyles.labelBold.copyWith(
                  fontSize: AppFontSizes.xl,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
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

/// Railway / SSC / Banking (from the catalog), one card each.
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.card});

  final List<ExamCategory> categories;
  final Widget Function(ExamCategory) card;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 520 ? categories.length : 1;
        if (cols == 1) {
          return Column(
            children: [
              for (final cat in categories) ...[
                card(cat),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < categories.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(child: card(categories[i])),
            ],
          ],
        );
      },
    );
  }
}

/// Category card used for both practice-set and study-note libraries.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.semanticCount,
    required this.onTap,
  });

  final ExamCategory category;
  final String title;
  final String subtitle;
  final String semanticCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(context, category);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: '$title, $semanticCount',
      child: ExcludeSemantics(
        child: DashboardCard(
          onTap: onTap,
          radius: AppSpacing.tileRadius,
          color: style.color.withValues(alpha: isDark ? 0.18 : 0.07),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, color: style.color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: AppFontSizes.lg,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact row for a recent set; opens its category library.
class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.set, required this.category});

  final LibrarySet set;
  final ExamCategory? category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final style = category == null ? null : categoryStyle(context, category!);
    final color = style?.color ?? AppColors.primary;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(set.createdAt);
    return DashboardCard(
      onTap: () => context.push(AppRoutes.libraryCategoryFor(set.category)),
      radius: AppSpacing.tileRadius,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Icon(style?.icon ?? Icons.menu_book_rounded, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${set.examName} · ${set.subjects.map((s) => s.name).join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
                Text(
                  '${l10n.questionsShort(set.questionCount)} · '
                  '${set.difficulty.label(l10n)} · $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!set.stats.attempted)
            Text(
              l10n.notAttempted,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// My Study Notes: one card per category with its note count. Notes are
/// only listed inside a category, so Railway / SSC / Banking never mix.
class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.categories, required this.notes});

  final List<ExamCategory>? categories;
  final AsyncValue<NotesSummary> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cats = categories;
    if (notes case AsyncError(:final error) when !notes.isLoading) {
      return StateMessage(
        icon: Icons.wifi_off_rounded,
        title: apiErrorText(l10n, error),
        actionLabel: l10n.retry,
        onAction: () => ref.invalidate(notesSummaryProvider),
      );
    }
    final summary = notes.value;
    if (cats == null || summary == null) {
      return const Skeleton(height: 120, radius: AppSpacing.tileRadius);
    }
    return _CategoryGrid(
      categories: cats,
      card: (cat) {
        final style = categoryStyle(context, cat);
        final count = l10n.notesCount(summary.countFor(cat.id));
        return _CategoryCard(
          category: cat,
          title: l10n.notesLibraryTitle(style.shortLabel),
          subtitle: count,
          semanticCount: count,
          onTap: () => context.push(AppRoutes.libraryNotesFor(cat.id)),
        );
      },
    );
  }
}
