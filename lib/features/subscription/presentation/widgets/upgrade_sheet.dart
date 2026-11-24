import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/subscription_models.dart';

/// Title, body and icon explaining a plan limit to the student.
({String title, String body, IconData icon}) limitText(
  AppLocalizations l10n,
  PlanLimitHit hit,
) {
  final max = hit.max ?? 0;
  return switch (hit.kind) {
    PlanLimitKind.dailySets => (
      title: l10n.limitDailySetsTitle,
      body: l10n.limitDailySetsBody(max),
      icon: Icons.hourglass_bottom_rounded,
    ),
    PlanLimitKind.dailyAiSets => (
      title: l10n.limitDailyAiTitle,
      body: l10n.limitDailyAiBody(max),
      icon: Icons.auto_awesome_rounded,
    ),
    PlanLimitKind.aiNotInPlan => (
      title: l10n.limitAiNotInPlanTitle,
      body: l10n.limitAiNotInPlanBody,
      icon: Icons.auto_awesome_rounded,
    ),
    PlanLimitKind.dailyQuestions => (
      title: l10n.limitDailyQuestionsTitle,
      body: l10n.limitDailyQuestionsBody(max),
      icon: Icons.emoji_events_rounded,
    ),
    PlanLimitKind.setSize => (
      title: l10n.limitSetSizeTitle,
      body: l10n.limitSetSizeBody(max),
      icon: Icons.format_list_numbered_rounded,
    ),
    PlanLimitKind.savedLimit => (
      title: l10n.limitSavedTitle,
      body: l10n.limitSavedBody(max),
      icon: Icons.bookmarks_rounded,
    ),
    PlanLimitKind.freshAiPro => (
      title: l10n.limitFreshTitle,
      body: l10n.limitFreshBody,
      icon: Icons.auto_awesome_rounded,
    ),
  };
}

/// Explains why the request was refused and offers Pro. Pro users who hit the
/// daily fair-use cap get no upsell (they already have everything).
Future<void> showUpgradeSheet(BuildContext context, PlanLimitHit hit) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheet) => SafeArea(child: UpgradePrompt(hit: hit, inSheet: true)),
  );
}

/// The upgrade message as a widget (used in the sheet and as a full-screen
/// state on the practice screen).
class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({super.key, required this.hit, this.inSheet = false});

  final PlanLimitHit hit;
  final bool inSheet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final t = limitText(l10n, hit);
    final upsell = hit.kind != PlanLimitKind.dailyQuestions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiGradient,
              ),
              child: Icon(t.icon, color: AppColors.white, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              t.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.body,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (upsell)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                if (inSheet) Navigator.of(context).pop();
                context.push(AppRoutes.plans);
              },
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(l10n.seePlans),
            ),
          if (inSheet) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(upsell ? l10n.maybeLater : l10n.cancel),
            ),
          ],
        ],
      ),
    );
  }
}
