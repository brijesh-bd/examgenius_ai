import 'package:flutter/material.dart';

import '../../../../core/network/api_error_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/practice_models.dart';
import '../../domain/saved_practice.dart';
import '../providers/saved_practice_providers.dart';
import '../widgets/saved_practice_card.dart';

/// Screen 6 — My Saved Practice. Saved sets as cards with Review, Practice
/// Again, Retry Wrong and Delete. Re-attempts open new sessions, so the saved
/// attempt itself never changes.
class SavedPracticeScreen extends ConsumerWidget {
  const SavedPracticeScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SavedPractice s,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
        title: Text(l10n.deletePracticeTitle),
        content: Text(l10n.deletePracticeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.deletePractice),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await ref
        .read(savedPracticeListProvider.notifier)
        .delete(s.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(deleted ? l10n.practiceDeleted : l10n.deleteFailed),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final list = ref.watch(savedPracticeListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySavedPractice)),
      body: SafeArea(
        top: false,
        child: list.when(
          loading: () => ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              for (var i = 0; i < 3; i++) ...[
                const ResponsiveCenter(
                  child: Skeleton(height: 220, radius: AppSpacing.tileRadius),
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(savedPracticeListProvider),
          ),
          data: (items) => items.isEmpty
              ? StateMessage(
                  icon: Icons.bookmarks_outlined,
                  title: l10n.savedEmptyTitle,
                  body: l10n.savedEmptyBody,
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(savedPracticeListProvider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final s = items[i];
                      final r = s.result;
                      final wrong = r.wrongReviews
                          .map((w) => w.questionId)
                          .toList();
                      return ResponsiveCenter(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SavedPracticeCard(
                          key: ValueKey(s.id),
                          saved: s,
                          onReview: () =>
                              context.push(AppRoutes.practiceReview, extra: r),
                          onPracticeAgain: () => context.push(
                            AppRoutes.practiceRetry,
                            extra: RetrySource(
                              r,
                              r.reviews.map((q) => q.questionId).toList(),
                            ),
                          ),
                          onRetryWrong: wrong.isEmpty
                              ? null
                              : () => context.push(
                                  AppRoutes.practiceRetry,
                                  extra: RetrySource(r, wrong),
                                ),
                          onDelete: () => _delete(context, ref, s),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
