import 'package:flutter/material.dart';

import '../../../../core/network/api_error_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/exam_tile.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/dashboard_models.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/exam_category_cards.dart';

/// Lists the exams of one category (Railway / SSC / Banking) from the catalog.
class ExamSelectionScreen extends ConsumerWidget {
  const ExamSelectionScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(examCatalogProvider);
    final category = catalog.value
        ?.where((c) => c.id == categoryId)
        .firstOrNull;
    final title = category == null
        ? l10n.selectExam
        : categoryStyle(context, category).label;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: catalog.when(
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
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
          data: (_) => category == null || category.exams.isEmpty
              ? StateMessage(
                  icon: Icons.school_outlined,
                  title: l10n.comingSoon,
                )
              : _ExamList(category: category),
        ),
      ),
    );
  }
}

/// One card per exam in the category, same style as the Home cards.
class _ExamList extends ConsumerWidget {
  const _ExamList({required this.category});

  final ExamCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final style = categoryStyle(context, category);
    final targetId = ref.watch(sessionProvider.select((u) => u?.targetExamId));

    return ListView(
      children: [
        ResponsiveCenter(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.selectExamBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ExamTileGrid(
                children: [
                  for (final exam in category.exams)
                    ExamTile(
                      title: exam.name,
                      subtitle: exam.id == targetId
                          ? l10n.currentTarget
                          : l10n.syllabusTitle,
                      icon: style.icon,
                      color: style.color,
                      onTap: () => context.push(AppRoutes.syllabusFor(exam.id)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
