import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/practice_models.dart';
import '../../domain/practice_result.dart';
import '../widgets/review_question_card.dart';

/// Screen 4 — Detailed Answer Review. Every question with the student's
/// answer, the correct answer and the explanation, filterable by status.
class AnswerReviewScreen extends StatefulWidget {
  const AnswerReviewScreen({super.key, required this.result});

  final PracticeResult? result;

  @override
  State<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends State<AnswerReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.result;
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: StateMessage(icon: Icons.quiz_outlined, title: l10n.errorGeneric),
      );
    }

    final items = _filter.apply(r.reviews);
    final wrongIds = r.wrongReviews.map((w) => w.questionId).toList();
    String label(ReviewFilter f) => switch (f) {
      ReviewFilter.all => l10n.filterAll,
      ReviewFilter.correct => l10n.statusCorrect,
      ReviewFilter.incorrect => l10n.statusIncorrect,
      ReviewFilter.unattempted => l10n.statusUnattempted,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Filters above the list; wrap so every filter stays visible.
            ResponsiveCenter(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final f in ReviewFilter.values)
                    ChoiceChip(
                      label: Text(
                        l10n.filterWithCount(
                          label(f),
                          r.reviews.where(f.matches).length,
                        ),
                      ),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? StateMessage(
                      icon: Icons.filter_alt_off_outlined,
                      title: l10n.noReviewItems,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => ResponsiveCenter(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ReviewQuestionCard(
                          number: items[i].$1,
                          review: items[i].$2,
                        ),
                      ),
                    ),
            ),
            Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              shadowColor: AppColors.cardShadow,
              child: ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: wrongIds.isEmpty
                      ? null
                      : () => context.push(
                          AppRoutes.practiceRetry,
                          extra: RetrySource(r, wrongIds),
                        ),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(
                    wrongIds.isEmpty
                        ? l10n.noWrongToRetry
                        : '${l10n.retryWrong} (${wrongIds.length})',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
