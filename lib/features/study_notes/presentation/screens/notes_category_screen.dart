import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/exam_tile.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';

/// Home → AI Study Notes: pick Railway / SSC / Banking (from the exam catalog).
class NotesCategoryScreen extends ConsumerWidget {
  const NotesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final catalog = ref.watch(examCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiStudyNotes)),
      body: SafeArea(
        top: false,
        child: catalog.when(
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  const Skeleton(height: 120, radius: AppSpacing.tileRadius),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(examCatalogProvider),
          ),
          data: (cats) => cats.isEmpty
              ? StateMessage(
                  icon: Icons.school_outlined,
                  title: l10n.comingSoon,
                )
              : ListView(
                  children: [
                    ResponsiveCenter(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(title: l10n.notesChooseCategory),
                          Text(
                            l10n.notesChooseCategoryBody,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ExamTileGrid(
                            children: [
                              for (final c in cats)
                                () {
                                  final style = categoryStyle(context, c);
                                  return ExamTile(
                                    title: style.shortLabel,
                                    subtitle: c.exams
                                        .take(3)
                                        .map((e) => shortExamName(e.name))
                                        .join(', '),
                                    icon: style.icon,
                                    color: style.color,
                                    onTap: () => context.push(
                                      AppRoutes.notesExamsFor(c.id),
                                    ),
                                  );
                                }(),
                            ],
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
