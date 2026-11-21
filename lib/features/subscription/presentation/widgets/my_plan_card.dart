import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/subscription_providers.dart';

/// Profile card: current plan, today's free sets / Pro expiry, upgrade button.
class MyPlanCard extends ConsumerWidget {
  const MyPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final status = ref.watch(subscriptionProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return status.when(
      loading: () => const Skeleton(height: 96, radius: 16),
      error: (_, _) => const SizedBox.shrink(), // plan info is optional here
      data: (s) {
        final date = s.expiresAt == null
            ? ''
            : DateFormat.yMMMd(locale).format(s.expiresAt!);
        final subtitle = s.isPro
            ? (s.isTrial ? l10n.trialUntil(date) : l10n.proUntil(date))
            : l10n.freeSetsLeft(s.setsLeftToday ?? 0, s.limits.setsPerDay ?? 0);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: s.isPro ? AppColors.aiGradient : null,
            color: s.isPro ? null : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: s.isPro
                ? null
                : Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                s.isPro
                    ? Icons.workspace_premium_rounded
                    : Icons.star_outline_rounded,
                color: s.isPro ? AppColors.gold : AppColors.accent,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.myPlan}: ${s.isPro ? l10n.planPro : l10n.planFree}',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: AppFontSizes.lg,
                        color: s.isPro ? AppColors.white : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: s.isPro
                            ? AppColors.white.withValues(alpha: 0.92)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              s.isPro
                  ? IconButton(
                      tooltip: l10n.proName,
                      onPressed: () => context.push(AppRoutes.plans),
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.white,
                      ),
                    )
                  : FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () => context.push(AppRoutes.plans),
                      child: Text(l10n.planPro),
                    ),
            ],
          ),
        );
      },
    );
  }
}
