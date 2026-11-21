import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/syllabus.dart';
import '../providers/question_generator_providers.dart';
import '../widgets/generator_options.dart';

/// Topics of one subject as a list with a Single / Multiple selection switch.
/// Works for every subject; selections live in the exam's
/// [generatorFormProvider], shared with the syllabus screen underneath.
class SubjectTopicsScreen extends ConsumerWidget {
  const SubjectTopicsScreen({super.key, required this.examId, required this.subjectId});

  final String examId;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final syllabus = ref.watch(syllabusProvider(examId));

    return syllabus.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.selectTopics)),
        body: ResponsiveCenter(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            children: [
              for (var i = 0; i < 6; i++) ...[
                const Skeleton(height: 52, radius: AppSpacing.tileRadius),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.selectTopics)),
        body: StateMessage(
          icon: Icons.wifi_off_rounded,
          title: l10n.errorGeneric,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(syllabusProvider(examId)),
        ),
      ),
      data: (s) {
        final index = s.subjects.indexWhere((x) => x.id == subjectId);
        if (index < 0 || s.subjects[index].topics.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.selectTopics)),
            body: StateMessage(icon: Icons.menu_book_outlined, title: l10n.comingSoon),
          );
        }
        return _TopicList(examId: examId, subject: s.subjects[index], index: index);
      },
    );
  }
}

class _TopicList extends ConsumerWidget {
  const _TopicList({required this.examId, required this.subject, required this.index});

  final String examId;
  final SyllabusSubject subject;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final form = ref.watch(generatorFormProvider(examId));
    final controller = ref.read(generatorFormProvider(examId).notifier);
    final style = subjectStyle(subject, index);
    final multi = form.multiSelect;
    final picked = subject.topics.where((t) => form.topicIds.contains(t.id)).length;
    final allPicked = picked == subject.topics.length;

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Mode switch + summary row.
            ResponsiveCenter(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.selectionType, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.xs),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        icon: const Icon(Icons.radio_button_checked_rounded),
                        label: Text(l10n.singleSelection),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: const Icon(Icons.checklist_rounded),
                        label: Text(l10n.multipleSelection),
                      ),
                    ],
                    selected: {multi},
                    onSelectionChanged: (v) => controller.setMultiSelect(v.first),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${multi ? l10n.multipleSelectionHint : l10n.singleSelectionHint}'
                          ' · ${l10n.topicsSelected(picked)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      if (multi && !allPicked)
                        TextButton(
                          onPressed: () => controller.selectAllIn(subject),
                          child: Text(l10n.selectAll),
                        ),
                      if (picked > 0)
                        TextButton(
                          onPressed: () => controller.clearSubject(subject),
                          child: Text(l10n.clear),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount: subject.topics.length,
                itemBuilder: (_, i) {
                  final t = subject.topics[i];
                  final on = form.topicIds.contains(t.id);
                  return ResponsiveCenter(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page, vertical: 3),
                    child: Material(
                      color: on ? style.color.withValues(alpha: 0.10) : scheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
                        side: BorderSide(
                          color: on ? style.color : scheme.outlineVariant.withValues(alpha: 0.6),
                          width: on ? 1.5 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        onTap: () => controller.selectTopic(t.id),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: style.color.withValues(alpha: 0.15),
                          child: Text('${i + 1}',
                              style: AppTextStyles.labelBold.copyWith(color: style.color)),
                        ),
                        title: Text(t.name, style: theme.textTheme.bodyLarge),
                        trailing: multi
                            ? Checkbox(
                                value: on,
                                activeColor: style.color,
                                onChanged: (_) => controller.selectTopic(t.id),
                              )
                            : Icon(
                                on
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: on ? style.color : scheme.outline,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ResponsiveCenter(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: PrimaryButton(
                label: l10n.doneButton,
                icon: Icons.check_rounded,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
