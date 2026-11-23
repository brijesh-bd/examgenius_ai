import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';
import '../../../question_generator/domain/generated_question.dart';
import '../../../question_generator/presentation/widgets/generator_options.dart';
import '../../domain/library_models.dart';
import '../providers/library_providers.dart';
import '../widgets/library_actions.dart';
import '../widgets/filter_picker.dart';
import '../widgets/library_set_card.dart';

/// One category's library (e.g. Banking only): search, filters (exam,
/// subject, topic, difficulty, language, date), sort, and set cards.
class CategoryLibraryScreen extends ConsumerStatefulWidget {
  const CategoryLibraryScreen({super.key, required this.category});

  final String category;

  @override
  ConsumerState<CategoryLibraryScreen> createState() =>
      _CategoryLibraryScreenState();
}

class _CategoryLibraryScreenState extends ConsumerState<CategoryLibraryScreen> {
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
      final c = ref.read(libraryFilterProvider(_cat).notifier);
      c.set(ref.read(libraryFilterProvider(_cat)).copyWith(query: text));
    });
  }

  void _clearAll() {
    _search.clear();
    ref.read(libraryFilterProvider(_cat).notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = ref.watch(examCatalogProvider).value;
    final category = catalog?.where((c) => c.id == _cat).firstOrNull;
    final label = category == null
        ? _cat
        : categoryStyle(context, category).shortLabel;
    final filter = ref.watch(libraryFilterProvider(_cat));
    final list = ref.watch(libraryListProvider(_cat));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryLibraryTitle(label))),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () {
            ref.invalidate(libraryFacetsProvider(_cat));
            return ref.refresh(libraryListProvider(_cat).future);
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
                      hintText: l10n.searchSetsHint,
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
              SliverToBoxAdapter(child: _FilterBar(category: _cat)),
              ...switch (list) {
                AsyncData(:final value) => _results(
                  context,
                  value,
                  filter,
                  label,
                ),
                AsyncError(:final error) when !list.isLoading => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: StateMessage(
                      icon: Icons.wifi_off_rounded,
                      title: apiErrorText(l10n, error),
                      actionLabel: l10n.retry,
                      onAction: () => ref.invalidate(libraryListProvider(_cat)),
                    ),
                  ),
                ],
                _ => [
                  SliverList.list(
                    children: [
                      for (var i = 0; i < 2; i++)
                        const ResponsiveCenter(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Skeleton(
                            height: 220,
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
    LibraryListState s,
    LibraryFilter filter,
    String label,
  ) {
    final l10n = context.l10n;
    if (s.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: filter.isActive
              ? StateMessage(
                  icon: Icons.filter_alt_off_rounded,
                  title: l10n.noMatchingSets,
                  actionLabel: l10n.clearFilters,
                  onAction: _clearAll,
                )
              : StateMessage(
                  icon: Icons.auto_stories_outlined,
                  title: l10n.categoryEmptyTitle(label),
                  body: l10n.categoryEmptyBody,
                ),
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
                  l10n.librarySetsCount(s.total),
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
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final set = s.items[i];
          return ResponsiveCenter(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LibrarySetCard(
              key: ValueKey(set.id),
              set: set,
              onReview: () => reviewLibrarySet(context, ref, set),
              onPracticeAgain: () => practiceLibrarySet(context, set),
              onHistory: () => openLibraryHistory(context, ref, set),
              onDelete: () => deleteLibrarySet(context, ref, set),
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
                        ref.read(libraryListProvider(_cat).notifier).loadMore(),
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

/// Horizontal row of filter chips; each opens a bottom sheet of options.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final f = ref.watch(libraryFilterProvider(category));
    final ctrl = ref.read(libraryFilterProvider(category).notifier);
    final facets =
        ref.watch(libraryFacetsProvider(category)).value ??
        const LibraryFacets();

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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFmt = DateFormat.MMMd(locale);

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
            label: l10n.filterDifficulty,
            value: f.difficulty?.label(l10n),
            onTap: () => showFilterPicker<Difficulty>(
              context,
              title: l10n.filterDifficulty,
              anyLabel: l10n.filterAny,
              selected: f.difficulty,
              options: [for (final d in Difficulty.values) (d, d.label(l10n))],
              onPick: (v) => ctrl.set(f.copyWith(difficulty: () => v)),
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
    LibraryFilter f,
  ) async {
    final l10n = context.l10n;
    final ctrl = ref.read(libraryFilterProvider(category).notifier);
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
            // Inclusive end: up to the last moment of that day.
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
