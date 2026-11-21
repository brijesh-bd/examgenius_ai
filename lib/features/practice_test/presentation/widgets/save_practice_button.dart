import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/practice_result.dart';
import '../providers/saved_practice_providers.dart';

/// Screen 5 — Save Practice. Idle → "Saving…" → "Saved to My Practice".
/// The success message is shown only after the backend confirms.
class SavePracticeButton extends ConsumerWidget {
  const SavePracticeButton({super.key, required this.result});

  final PracticeResult result;

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(savePracticeProvider(result).notifier).save();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        ok
            ? SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
                persist: false, // auto-dismiss even though it has an action
                content: Text(l10n.saveSuccess),
                action: SnackBarAction(
                  label: l10n.viewAction,
                  textColor: AppColors.white,
                  // My Saved Practice ships with Screen 6.
                  onPressed: () {
                    if (context.mounted) context.openComingSoon(l10n.mySavedPractice);
                  },
                ),
              )
            : SnackBar(
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 6),
                persist: false,
                content: Text(l10n.saveFailed),
                action: SnackBarAction(
                  label: l10n.retry,
                  onPressed: () {
                    if (context.mounted) _save(context, ref);
                  },
                ),
              ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(savePracticeProvider(result));

    final (label, icon) = state.isSaved
        ? (l10n.practiceSaved, Icons.bookmark_added_rounded)
        : state.saving
            ? (l10n.savingPractice, Icons.bookmark_add_outlined)
            : (l10n.savePractice, Icons.bookmark_add_outlined);

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        disabledBackgroundColor:
            state.isSaved ? AppColors.success.withValues(alpha: 0.15) : null,
        disabledForegroundColor: state.isSaved ? AppColors.success : null,
      ),
      onPressed: state.saving || state.isSaved ? null : () => _save(context, ref),
      icon: state.saving
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
