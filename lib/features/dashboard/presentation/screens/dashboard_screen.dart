import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/exam_tile.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/exam_category_cards.dart';

/// Student home: gradient greeting header + "Choose your exam" card grid.
/// Exam categories come from [examCatalogProvider]; module tiles follow them.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final catalog = ref.watch(examCatalogProvider);

    final modules = <Widget>[
      ExamTile(
        title: l10n.mockTests,
        subtitle: l10n.mockTestsSub,
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.mockTests,
        onTap: () => context.go(AppRoutes.tests),
      ),
      ExamTile(
        title: l10n.dailyPractice,
        subtitle: l10n.dailyPracticeSub,
        icon: Icons.track_changes_rounded,
        color: AppColors.dailyPractice,
        onTap: () => context.go(AppRoutes.practice),
      ),
      ExamTile(
        title: l10n.previousYearPapers,
        subtitle: l10n.previousYearSub,
        icon: Icons.menu_book_rounded,
        color: AppColors.previousYear,
        onTap: () => context.openComingSoon(l10n.previousYearPapers),
      ),
    ];

    final List<Widget> categoryTiles = catalog.when(
      loading: () => const [Skeleton(height: 160), Skeleton(height: 160), Skeleton(height: 160)],
      error: (_, _) => const [],
      data: (cats) => [
        for (final c in cats)
          () {
            final style = categoryStyle(context, c);
            return ExamTile(
              title: style.shortLabel,
              subtitle: c.exams.take(3).map((e) => shortExamName(e.name)).join(", "),
              icon: style.icon,
              color: style.color,
              onTap: () => context.push(AppRoutes.examsFor(c.id)),
            );
          }(),
      ],
    );
    final firstCategoryId = catalog.value?.firstOrNull?.id;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          const _GreetingHeader(),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(examCatalogProvider.future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 22, 0, 24),
                  children: [
                    ResponsiveCenter(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    l10n.homeChooseExam,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface,
                                        ),
                                  ),
                                ),
                              ),
                              if (firstCategoryId != null)
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.examsFor(firstCategoryId)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.viewAll,
                                          style: AppTextStyles.labelBold),
                                      const Icon(Icons.chevron_right_rounded, size: 22),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (catalog.value?.isEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StateMessage(
                                icon: Icons.school_outlined,
                                title: l10n.comingSoon,
                              ),
                            ),
                          if (catalog.hasError && !catalog.isLoading)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StateMessage(
                                icon: Icons.wifi_off_rounded,
                                title: l10n.errorGeneric,
                                actionLabel: l10n.retry,
                                onAction: () => ref.invalidate(examCatalogProvider),
                              ),
                            ),
                          ExamTileGrid(children: [...categoryTiles, ...modules]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rawName = ref.watch(sessionProvider.select((u) => u?.name.trim() ?? ''));
    final name =
        rawName.isEmpty ? l10n.defaultStudentName : rawName.split(RegExp(r'\s+')).first;
    final unread = ref.watch(
      dashboardSummaryProvider.select((s) => s.value?.unreadNotifications ?? 0),
    );
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.greetingMorning(name)
        : hour < 17
            ? l10n.greetingAfternoon(name)
            : l10n.greetingEvening(name);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: SafeArea(
        bottom: false,
        child: ResponsiveCenter(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 30),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.greeting,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.keepLearning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.greetingSub,
                    ),
                  ],
                ),
              ),
              _CircleButton(
                tooltip: l10n.notifications,
                onTap: () => context.openComingSoon(l10n.notifications),
                background: Colors.white.withValues(alpha: 0.18),
                child: Badge(
                  isLabelVisible: unread > 0,
                  smallSize: 9,
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              _CircleButton(
                tooltip: l10n.profile,
                onTap: () => context.push(AppRoutes.profile),
                background: Colors.white,
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.tooltip,
    required this.onTap,
    required this.background,
    required this.child,
  });
  final String tooltip;
  final VoidCallback onTap;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(dimension: 48, child: Center(child: child)),
        ),
      ),
    );
  }
}
