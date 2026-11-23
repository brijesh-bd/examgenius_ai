import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/subscription_models.dart';
import '../providers/subscription_providers.dart';

/// Free vs Pro comparison, the three Pro options (yearly highlighted) and
/// the one-time free trial. Online payment is not wired yet.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  String? _selectedId;
  bool _startingTrial = false;

  Future<void> _startTrial() async {
    setState(() => _startingTrial = true);
    final ok = await ref.read(subscriptionProvider.notifier).startTrial();
    if (!mounted) return;
    setState(() => _startingTrial = false);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? AppColors.success : null,
          content: Text(ok ? l10n.trialStarted : l10n.trialFailed),
        ),
      );
  }

  void _choose(PlanOffer offer) {
    // Google Play Billing / Razorpay are wired in a later step.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.paymentsComingSoon),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proName)),
      body: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => StateMessage(
          icon: Icons.wifi_off_rounded,
          title: apiErrorText(l10n, e),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(subscriptionProvider),
        ),
        data: (s) {
          final offers = s.offers;
          final selected =
              offers.where((o) => o.id == _selectedId).firstOrNull ??
              offers.where((o) => o.popular).firstOrNull ??
              offers.lastOrNull;
          final monthly = offers.where((o) => o.months == 1).firstOrNull;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _Hero(),
              ResponsiveCenter(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (s.isPro) ...[
                      _CurrentPro(status: s),
                      const SizedBox(height: 16),
                    ],
                    _Comparison(status: s),
                    const SizedBox(height: 20),
                    for (final o in offers) ...[
                      _OfferCard(
                        offer: o,
                        selected: o.id == selected?.id,
                        savePercent: monthly == null || o.months == 1
                            ? null
                            : (100 -
                                      o.priceInr *
                                          100 /
                                          (monthly.priceInr * o.months))
                                  .round(),
                        onTap: () => setState(() => _selectedId = o.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                    if (s.trialAvailable)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: _startingTrial ? null : _startTrial,
                        icon: _startingTrial
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              )
                            : const Icon(Icons.card_giftcard_rounded),
                        label: Text(l10n.startTrial(s.trialDays)),
                      ),
                    if (s.trialAvailable) const SizedBox(height: 10),
                    if (selected != null)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () => _choose(selected),
                        child: Text(
                          l10n.choosePlan(l10n.planMonths(selected.months)),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.pricesIncludeGst,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.gold,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proName,
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.proTagline,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPro extends StatelessWidget {
  const _CurrentPro({required this.status});
  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = status.expiresAt == null
        ? ''
        : DateFormat.yMMMd(locale).format(status.expiresAt!);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              status.isTrial ? l10n.trialUntil(date) : l10n.proUntil(date),
              style: AppTextStyles.labelBold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Free vs Pro table built from the server's limits.
class _Comparison extends StatelessWidget {
  const _Comparison({required this.status});
  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    // Free numbers are known even when the student is Pro (shown for reference).
    final freeSets = status.isPro ? 2 : (status.limits.setsPerDay ?? 2);
    final freeSize = status.isPro ? 10 : status.limits.maxQuestionsPerSet;
    // null = unlimited (every generated set is kept in the Library).
    final freeSaved = status.isPro ? null : status.limits.maxSaved;
    const proSize = 30;

    Widget cell(String text, {bool strong = false, Color? color}) => Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: (strong ? AppTextStyles.labelBold : AppTextStyles.bodySmall)
            .copyWith(color: color),
      ),
    );
    Widget yes() => const Expanded(
      child: Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 20,
      ),
    );
    Widget no() => Expanded(
      child: Icon(Icons.remove_rounded, color: scheme.outline, size: 20),
    );
    Widget row(String label, Widget free, Widget pro) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTextStyles.body)),
          free,
          pro,
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  l10n.featureCompare,
                  style: AppTextStyles.labelBold,
                ),
              ),
              cell(l10n.planFree, strong: true, color: scheme.onSurfaceVariant),
              cell(l10n.planPro, strong: true, color: AppColors.accent),
            ],
          ),
          const Divider(),
          row(
            l10n.featurePracticeSets,
            cell(l10n.featureFreeSets(freeSets)),
            cell(l10n.featureUnlimited, strong: true),
          ),
          row(
            l10n.featureQuestionsPerSet,
            cell(l10n.featureUpTo(freeSize)),
            cell(l10n.featureUpTo(proSize), strong: true),
          ),
          row(l10n.featureReview, yes(), yes()),
          row(
            l10n.featureSaved,
            freeSaved == null
                ? cell(l10n.featureUnlimited, strong: true)
                : cell('$freeSaved'),
            cell(l10n.featureUnlimited, strong: true),
          ),
          row(l10n.featureFreshAi, no(), yes()),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.selected,
    required this.onTap,
    this.savePercent,
  });

  final PlanOffer offer;
  final bool selected;
  final int? savePercent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected
            ? AppColors.accent.withValues(alpha: 0.08)
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppColors.accent : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.accent : scheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.planMonths(offer.months),
                            style: AppTextStyles.labelBold,
                          ),
                          if (offer.popular)
                            _Tag(
                              text: l10n.mostPopular,
                              color: AppColors.accent,
                            ),
                          if (savePercent != null && savePercent! > 0)
                            _Tag(
                              text: l10n.savePercent(savePercent!),
                              color: AppColors.success,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.perMonth(offer.perMonthInr),
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(l10n.priceInr(offer.priceInr), style: AppTextStyles.h3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: AppTextStyles.tiny.copyWith(
        color: color,
        fontWeight: AppFontWeights.bold,
      ),
    ),
  );
}
