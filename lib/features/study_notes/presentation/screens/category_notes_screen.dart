import 'dart:async';

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
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';
import '../../../library/domain/library_models.dart';
import '../../../library/presentation/widgets/filter_picker.dart';
import '../../domain/notes_library.dart';
import '../../domain/study_note.dart';
import '../providers/study_notes_providers.dart';
import '../widgets/note_list_card.dart';
import 'create_notes_screen.dart' show noteLevelLabel;

/// One category's study notes (e.g. SSC only): search, filters (exam,
/// subject, topic, language, level, date), sort, and note cards.
class CategoryNotesScreen extends ConsumerStatefulWidget {
  const CategoryNotesScreen({super.key, required this.category});

  final String category;

  @override
  ConsumerState<CategoryNotesScreen> createState() =>
      _CategoryNotesScreenState();
}

class _CategoryNotesScreenState extends ConsumerState<CategoryNotesScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  String get _cat => widget.category;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final c = ref.read(notesFilterProvider(_cat).notifier);
      c.set(ref.read(notesFilterProvider(_cat)).copyWith(query: text));
    });
  }

  void _clearAll() {
    _search.clear();
    ref.read(notesFilterProvider(_cat).notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = ref
        .watch(examCatalogProvider)
        .value
        ?.where((c) => c.id == _cat)
        .firstOrNull;
    final style = category == null ? null : categoryStyle(context, category);
    final label = style?.shortLabel ?? _cat;
    final color = style?.color ?? AppColors.primary;
    final filter = ref.watch(notesFilterProvider(_cat));
    final list = ref.watch(notesListProvider(_cat));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesLibraryTitle(label))),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () {
            ref.invalidate(notesFacetsProvider(_cat));
            return ref.refresh(notesListProvider(_cat).future);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    0,
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: _onSearch,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchNotesHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: _search,
                        builder: (_, v, _) => v.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                tooltip: l10n.clear,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _search.clear();
                                  _onSearch('');
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    0,
                  ),
                  // My Study Notes / Bookmarks / Personal Notes — always
                  // inside this one category, so categories never mix.
                  child: SegmentedButton<NotesView>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: NotesView.all,
                        icon: const Icon(Icons.auto_stories_outlined),
                        label: Text(l10n.notesViewAll),
                      ),
                      ButtonSegment(
                        value: NotesView.bookmarked,
                        icon: const Icon(Icons.bookmark_border_rounded),
                        label: Text(l10n.notesViewBookmarked),
                      ),
                      ButtonSegment(
                        value: NotesView.personal,
                        icon: const Icon(Icons.sticky_note_2_outlined),
                        label: Text(l10n.notesViewPersonal),
                      ),
                    ],
                    selected: {filter.view},
                    onSelectionChanged: (v) => ref
                        .read(notesFilterProvider(_cat).notifier)
                        .set(filter.copyWith(view: v.first)),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _NotesFilterBar(category: _cat)),
              ...switch (list) {
                AsyncData(:final value) => _results(
                  context,
                  value,
                  filter,
                  label,
                  color,
                ),
                AsyncError(:final error) when !list.isLoading => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: StateMessage(
                      icon: Icons.wifi_off_rounded,
                      title: apiErrorText(l10n, error),
                      actionLabel: l10n.retry,
                      onAction: () => ref.invalidate(notesListProvider(_cat)),
                    ),
                  ),
                ],
                _ => [
                  SliverList.list(
                    children: [
                      for (var i = 0; i < 3; i++)
                        const ResponsiveCenter(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Skeleton(
                            height: 96,
                            radius: AppSpacing.tileRadius,
                          ),
                        ),
                    ],
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _results(
    BuildContext context,
    NotesListState s,
    NotesFilter filter,
    String label,
    Color color,
  ) {
    final l10n = context.l10n;
    if (s.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: filter.isActive
              ? StateMessage(
                  icon: Icons.filter_alt_off_rounded,
                  title: l10n.noMatchingNotes,
                  actionLabel: l10n.clearFilters,
                  onAction: _clearAll,
                )
              : switch (filter.view) {
                  NotesView.bookmarked => StateMessage(
                    icon: Icons.bookmark_border_rounded,
                    title: l10n.noBookmarkedNotes,
                    body: l10n.noBookmarkedNotesBody,
                  ),
                  NotesView.personal => StateMessage(
                    icon: Icons.sticky_note_2_outlined,
                    title: l10n.noPersonalNotes,
                    body: l10n.noPersonalNotesBody,
                  ),
                  NotesView.all => StateMessage(
                    icon: Icons.auto_stories_outlined,
                    title: l10n.notesEmptyTitle(label),
                    body: l10n.notesEmptyBody,
                    actionLabel: l10n.createNotesCta,
                    onAction: () => context.push(AppRoutes.notesExamsFor(_cat)),
                  ),
                },
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.notesCount(s.total),
                  style: AppTextStyles.label,
                ),
              ),
              if (filter.isActive)
                TextButton(
                  onPressed: _clearAll,
                  child: Text(l10n.clearFilters),
                ),
            ],
          ),
        ),
      ),
      SliverList.separated(
        itemCount: s.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, i) {
          final note = s.items[i];
          return ResponsiveCenter(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NoteListCard(
              key: ValueKey(note.id),
              note: note,
              color: color,
              // Opens the full note (fetched with its content by id).
              onOpen: () => context.push(AppRoutes.noteViewFor(note.id)),
            ),
          );
        },
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Center(
            child: s.loadingMore
                ? const CircularProgressIndicator()
                : s.hasMore
                ? OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(notesListProvider(_cat).notifier).loadMore(),
                    icon: Icon(
                      s.loadMoreError == null
                          ? Icons.expand_more_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(
                      s.loadMoreError == null
                          ? l10n.loadMore
                          : apiErrorText(l10n, s.loadMoreError!),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ];
  }
}

/// Exam / Subject / Topic / Language / Difficulty (level) / Date / Sort.
class _NotesFilterBar extends ConsumerWidget {
  const _NotesFilterBar({required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final f = ref.watch(notesFilterProvider(category));
    final ctrl = ref.read(notesFilterProvider(category).notifier);
    final facets =
        ref.watch(notesFacetsProvider(category)).value ?? const LibraryFacets();

    String? nameOf(List<NamedRef> refs, String? id) =>
        id == null ? null : refs.where((r) => r.id == id).firstOrNull?.name;

    final subjects = [
      for (final s in facets.subjects)
        if (f.examId == null || s.examIds.contains(f.examId)) s.subject,
    ];
    final topics = <NamedRef>[
      for (final t in facets.topics)
        if ((f.examId == null || t.examIds.contains(f.examId)) &&
            (f.subjectId == null || t.topic.subjectId == f.subjectId))
          t.topic,
    ];
    final dateFmt = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          FilterPickerChip(
            label: l10n.filterExam,
            value: nameOf(facets.exams, f.examId),
            onTap: () => showFilterPicker<String>(
              context,
              title: l10n.filterExam,
              anyLabel: l10n.filterAny,
              selected: f.examId,
              options: [for (final e in facets.exams) (e.id, e.name)],
              onPick: ctrl.setExam,
            ),
          ),
          FilterPickerChip(
            label: l10n.filterSubject,
            value: nameOf(subjects, f.subjectId),
            onTap: () => showFilterPicker<String>(
              context,
              title: l10n.filterSubject,
              anyLabel: l10n.filterAny,
              selected: f.subjectId,
              options: [for (final s in subjects) (s.id, s.name)],
              onPick: ctrl.setSubject,
            ),
          ),
          FilterPickerChip(
            label: l10n.filterTopic,
            value: nameOf(topics, f.topicId),
            onTap: () => showFilterPicker<String>(
              context,
              title: l10n.filterTopic,
              anyLabel: l10n.filterAny,
              selected: f.topicId,
              options: [for (final t in topics) (t.id, t.name)],
              onPick: (v) => ctrl.set(f.copyWith(topicId: () => v)),
            ),
          ),
          FilterPickerChip(
            label: l10n.filterLanguage,
            value: switch (f.language) {
              'en' => l10n.english,
              'hi' => l10n.hindi,
              _ => null,
            },
            onTap: () => showFilterPicker<String>(
              context,
              title: l10n.filterLanguage,
              anyLabel: l10n.filterAny,
              selected: f.language,
              options: [('en', l10n.english), ('hi', l10n.hindi)],
              onPick: (v) => ctrl.set(f.copyWith(language: () => v)),
            ),
          ),
          FilterPickerChip(
            label: l10n.filterDifficulty,
            value: f.level == null ? null : noteLevelLabel(l10n, f.level!),
            onTap: () => showFilterPicker<NoteLevel>(
              context,
              title: l10n.filterDifficulty,
              anyLabel: l10n.filterAny,
              selected: f.level,
              options: [
                for (final lv in NoteLevel.values)
                  (lv, noteLevelLabel(l10n, lv)),
              ],
              onPick: (v) => ctrl.set(f.copyWith(level: () => v)),
            ),
          ),
          FilterPickerChip(
            label: l10n.filterDate,
            value: f.from == null && f.to == null
                ? null
                : '${f.from == null ? '…' : dateFmt.format(f.from!)} – '
                      '${f.to == null ? '…' : dateFmt.format(f.to!)}',
            onTap: () => _pickDate(context, ref, f),
          ),
          FilterPickerChip(
            label: f.sort == LibrarySort.latest
                ? l10n.sortLatest
                : l10n.sortOldest,
            icon: Icons.swap_vert_rounded,
            onTap: () => ctrl.set(
              f.copyWith(
                sort: f.sort == LibrarySort.latest
                    ? LibrarySort.oldest
                    : LibrarySort.latest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    NotesFilter f,
  ) async {
    final l10n = context.l10n;
    final ctrl = ref.read(notesFilterProvider(category).notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final choice = await showFilterPicker<int>(
      context,
      title: l10n.filterDate,
      anyLabel: l10n.dateAny,
      selected: null,
      options: [
        (7, l10n.dateLast7),
        (30, l10n.dateLast30),
        (0, l10n.dateCustom),
      ],
      onPick: (_) {},
    );
    if (!context.mounted || choice == null) return;
    switch (choice.$1) {
      case null:
        ctrl.set(f.copyWith(from: () => null, to: () => null));
      case 0:
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: today,
          initialDateRange: f.from == null
              ? null
              : DateTimeRange(start: f.from!, end: f.to ?? today),
        );
        if (range == null) return;
        ctrl.set(
          f.copyWith(
            from: () => range.start,
            to: () => range.end.add(const Duration(days: 1, milliseconds: -1)),
          ),
        );
      case final days:
        ctrl.set(
          f.copyWith(
            from: () => today.subtract(Duration(days: days - 1)),
            to: () => null,
          ),
        );
    }
  }
}
