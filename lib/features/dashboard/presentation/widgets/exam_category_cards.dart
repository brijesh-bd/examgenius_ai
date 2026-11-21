import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/dashboard_models.dart';
import '../providers/dashboard_providers.dart';
import 'dashboard_card.dart';

/// Visual style for a backend-provided category id; unknown ids fall back to
/// a neutral style so new categories never break the UI.
({IconData icon, Color color, String label, String shortLabel}) categoryStyle(
  BuildContext context,
  ExamCategory c,
) {
  final l10n = context.l10n;
  return switch (c.id) {
    'railway' => (
      icon: Icons.train_rounded,
      color: AppColors.railway,
      label: l10n.railwayExams,
      shortLabel: l10n.railway,
    ),
    'ssc' => (
      icon: Icons.groups_rounded,
      color: AppColors.ssc,
      label: l10n.sscExams,
      shortLabel: l10n.ssc,
    ),
    'banking' => (
      icon: Icons.account_balance_rounded,
      color: AppColors.banking,
      label: l10n.bankingExams,
      shortLabel: l10n.banking,
    ),
    _ => (
      icon: Icons.school_rounded,
      color: AppColors.primary,
      label: c.name,
      shortLabel: c.name,
    ),
  };
}

/// Short exam label for card subtitles: "RRB NTPC" → "NTPC", "SSC CGL" → "CGL".
String shortExamName(String name) {
  const prefixes = ['RRB ', 'SSC ', 'IBPS '];
  for (final p in prefixes) {
    if (name.startsWith(p) && name.length > p.length) {
      return name.substring(p.length);
    }
  }
  return name;
}

/// The three main exam-category cards, driven by [examCatalogProvider].
class ExamCategoryCards extends ConsumerWidget {
  const ExamCategoryCards({super.key, required this.onCategorySelected});

  final ValueChanged<ExamCategory> onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalog = ref.watch(examCatalogProvider);

    return catalog.when(
      loading: () => const DashboardGrid(
        wideColumns: 3,
        children: [
          Skeleton(height: 140),
          Skeleton(height: 140),
          Skeleton(height: 140),
        ],
      ),
      error: (_, _) => DashboardCard(
        child: StateMessage(
          icon: Icons.wifi_off_rounded,
          title: l10n.errorGeneric,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(examCatalogProvider),
        ),
      ),
      data: (cats) {
        if (cats.isEmpty) {
          return DashboardCard(
            child: StateMessage(
              icon: Icons.school_outlined,
              title: l10n.comingSoon,
            ),
          );
        }
        return DashboardGrid(
          wideColumns: 3,
          children: [
            for (final c in cats)
              ExamCategoryCard(category: c, onTap: () => onCategorySelected(c)),
          ],
        );
      },
    );
  }
}

/// Tinted card: icon, category name, short list of supported exams.
class ExamCategoryCard extends StatelessWidget {
  const ExamCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ExamCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = categoryStyle(context, category);
    final exams = category.exams.map((e) => shortExamName(e.name)).join(' · ');

    return Semantics(
      button: true,
      label: style.label,
      child: DashboardCard(
        onTap: onTap,
        radius: AppSpacing.tileRadius,
        color: style.color.withValues(alpha: isDark ? 0.18 : 0.07),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(style.icon, color: style.color, size: 32),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              style.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              exams,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
