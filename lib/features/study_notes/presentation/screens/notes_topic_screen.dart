import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../question_generator/presentation/providers/question_generator_providers.dart';

/// Subject → topic picker for one exam, built from the same syllabus the
/// practice generator uses (`syllabusProvider`) — no duplicate data.
class NotesTopicScreen extends ConsumerWidget {
  const NotesTopicScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final exam = ref.watch(examByIdProvider(examId));
    final syllabus = ref.watch(syllabusProvider(examId));

    return Scaffold(
      appBar: AppBar(title: Text(exam?.name ?? l10n.notesChooseTopic)),
      body: SafeArea(
        top: false,
        child: syllabus.when(
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  const Skeleton(height: 56),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(syllabusProvider(examId)),
          ),
          data: (s) => s.subjects.isEmpty
              ? StateMessage(
                  icon: Icons.menu_book_outlined,
                  title: l10n.comingSoon,
                )
              : ListView(
                  children: [
                    ResponsiveCenter(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(title: l10n.notesChooseTopic),
                          Text(
                            l10n.notesChooseTopicBody(exam?.name ?? ''),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          for (final (i, subject) in s.subjects.indexed)
                            Card(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ExpansionTile(
                                initiallyExpanded: i == 0,
                                shape: const Border(),
                                title: Text(
                                  subject.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                                subtitle: Text('${subject.topics.length}'),
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.route_rounded,
                                      color: AppColors.accent,
                                    ),
                                    title: Text(
                                      l10n.openLearningPath,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(color: AppColors.accent),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    onTap: () => context.push(
                                      AppRoutes.notesPathFor(
                                        examId,
                                        subject.id,
                                      ),
                                    ),
                                  ),
                                  for (final t in subject.topics)
                                    ListTile(
                                      title: Text(t.name),
                                      trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                      ),
                                      onTap: () => context.push(
                                        AppRoutes.notesCreateFor(examId, t.id),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
