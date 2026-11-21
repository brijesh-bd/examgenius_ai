import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Surface card used across the dashboard: subtle border + soft shadow in
/// light mode, border only in dark mode (shadows read poorly on dark).
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.radius = AppSpacing.cardRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.35),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: color ?? theme.colorScheme.surface,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section title with a brand accent bar and an optional "View All" action.
class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle({super.key, required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(AppSpacing.minTouch, AppSpacing.minTouch),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.viewAll,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grid whose rows size to their tallest child, so long Hindi labels or large
/// text scales grow the tile instead of overflowing. 3 columns on phones,
/// 6 on wide layouts.
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.children,
    this.wideColumns = 6,
    this.compactColumns = 3,
  });

  final List<Widget> children;
  final int wideColumns;
  final int compactColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 600 ? wideColumns : compactColumns;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final cells = <Widget>[];
          for (var j = 0; j < cols; j++) {
            if (j > 0) cells.add(const SizedBox(width: AppSpacing.xs));
            final k = i + j;
            cells.add(Expanded(child: k < children.length ? children[k] : const SizedBox()));
          }
          if (rows.isNotEmpty) rows.add(const SizedBox(height: AppSpacing.xs));
          rows.add(IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
          ));
        }
        return Column(children: rows);
      },
    );
  }
}

/// Icon + label (+ optional subtitle) tile used by the exam and action grids.
class DashboardTile extends StatelessWidget {
  const DashboardTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.tinted = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

  /// Coloured background (exam categories) instead of a white card.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DashboardCard(
      onTap: onTap,
      radius: AppSpacing.tileRadius,
      color: tinted ? color.withValues(alpha: isDark ? 0.18 : 0.08) : null,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.25),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: AppFontSizes.xxs,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
