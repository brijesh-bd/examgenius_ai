import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../practice_test/domain/practice_models.dart';
import '../../domain/library_models.dart';
import '../providers/library_providers.dart';

void _snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(text)),
    );
}

/// Review: answers and explanations of the latest attempt. Never before the
/// set has been attempted.
Future<void> reviewLibrarySet(
  BuildContext context,
  WidgetRef ref,
  LibrarySet set,
) async {
  final l10n = context.l10n;
  final resultId = set.stats.latestResultId;
  if (!set.stats.attempted || resultId == null) {
    _snack(context, l10n.attemptFirstToReview);
    return;
  }
  final nav = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final result = await ref
        .read(libraryRepositoryProvider)
        .fetchResult(resultId);
    nav.pop();
    if (context.mounted) {
      await context.push(AppRoutes.practiceReview, extra: result);
    }
  } on Object catch (e) {
    nav.pop();
    if (context.mounted) _snack(context, apiErrorText(l10n, e));
  }
}

/// Practice Again: same questions, a new attempt in the set's history.
void practiceLibrarySet(BuildContext context, LibrarySet set) => context.push(
  AppRoutes.libraryPractice,
  extra: LibrarySetSource(set.id, examName: set.examName),
);

/// Practice History: every attempt of the set (newest first); tapping one
/// opens its scorecard.
Future<void> openLibraryHistory(
  BuildContext context,
  WidgetRef ref,
  LibrarySet set,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _HistorySheet(set: set),
);

class _HistorySheet extends ConsumerWidget {
  const _HistorySheet({required this.set});

  final LibrarySet set;

  /// 7.5 → "7.5", 8 → "8", 6.25 → "6.25" (marks are in 0.25 steps).
  String _n(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    String resultId,
  ) async {
    final l10n = context.l10n;
    final nav = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final result = await ref
          .read(libraryRepositoryProvider)
          .fetchResult(resultId);
      nav.pop(); // progress
      nav.pop(); // sheet
      await router.push(AppRoutes.practiceResult, extra: result);
    } on Object catch (e) {
      nav.pop();
      if (context.mounted) _snack(context, apiErrorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final attempts = ref.watch(setAttemptsProvider(set.id));
    final dateFmt = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_jm();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                l10n.historyTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(set.examName, style: theme.textTheme.bodySmall),
            ),
            Flexible(
              child: attempts.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => StateMessage(
                  icon: Icons.wifi_off_rounded,
                  title: apiErrorText(l10n, e),
                  actionLabel: l10n.retry,
                  onAction: () => ref.invalidate(setAttemptsProvider(set.id)),
                ),
                data: (items) => items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.historyEmpty,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final a = items[i];
                          final no = a.attemptNo ?? items.length - i;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: Text('$no'),
                            ),
                            title: Text(l10n.historyAttempt(no)),
                            subtitle: Text(
                              '${l10n.historyLine(_n(a.score), _n(a.maxScore), '${(a.accuracy * 100).round()}%')}\n'
                              '${dateFmt.format(a.completedAt)}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _open(context, ref, a.resultId),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirms, then deletes on the backend. The card is removed only after the
/// server confirmed.
Future<void> deleteLibrarySet(
  BuildContext context,
  WidgetRef ref,
  LibrarySet set,
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
  final deleted = await ref
      .read(libraryListProvider(set.category).notifier)
      .delete(set.id);
  if (context.mounted) {
    _snack(context, deleted ? l10n.practiceDeleted : l10n.deleteFailed);
  }
}
