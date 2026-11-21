import 'package:flutter/material.dart';

import '../../../../core/network/api_error_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/exam_tile.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/syllabus.dart';
import '../providers/question_generator_providers.dart';
import '../widgets/generator_options.dart';
import '../../../subscription/domain/subscription_models.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/widgets/upgrade_sheet.dart';

/// Full syllabus of one exam. The student picks topics, a difficulty level and
/// a question count, then generates questions.
class SyllabusScreen extends ConsumerWidget {
  const SyllabusScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final exam = ref.watch(examByIdProvider(examId));
    final syllabus = ref.watch(syllabusProvider(examId));

    return Scaffold(
      appBar: AppBar(title: Text(exam?.name ?? l10n.syllabusTitle)),
      body: SafeArea(
        top: false,
        child: syllabus.when(
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  const Skeleton(height: 120, radius: AppSpacing.tileRadius),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(syllabusProvider(examId)),
          ),
          data: (s) => s.subjects.isEmpty
              ? StateMessage(
                  icon: Icons.menu_book_outlined,
                  title: l10n.comingSoon,
                )
              : _SyllabusBody(
                  examId: examId,
                  examName: exam?.name ?? examId,
                  syllabus: s,
                ),
        ),
      ),
    );
  }
}

class _SyllabusBody extends ConsumerWidget {
  const _SyllabusBody({
    required this.examId,
    required this.examName,
    required this.syllabus,
  });

  final String examId;
  final String examName;
  final Syllabus syllabus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final form = ref.watch(generatorFormProvider(examId));
    final plan = ref.watch(subscriptionProvider).value;
    final controller = ref.read(generatorFormProvider(examId).notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      title: '1. ${l10n.selectTopics}',
                      action: form.topicIds.isEmpty ? null : l10n.clear,
                      onAction: controller.clearTopics,
                    ),
                    Text(
                      '${l10n.subjectsCount(syllabus.subjects.length)} · '
                      '${l10n.topicsCount(syllabus.topicCount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ExamTileGrid(
                      children: [
                        for (final (i, subject) in syllabus.subjects.indexed)
                          () {
                            final style = subjectStyle(subject, i);
                            final picked = subject.topics
                                .where((t) => form.topicIds.contains(t.id))
                                .length;
                            return ExamTile(
                              title: subject.name,
                              subtitle: picked == 0
                                  ? l10n.topicsCount(subject.topics.length)
                                  : l10n.topicsSelected(picked),
                              icon: style.icon,
                              color: style.color,
                              onTap: () => context.push(
                                AppRoutes.subjectTopicsFor(examId, subject.id),
                              ),
                            );
                          }(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SectionHeader(title: '2. ${l10n.difficultyLevel}'),
                    DifficultySelector(
                      value: form.difficulty,
                      onChanged: controller.setDifficulty,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(title: '3. ${l10n.numberOfQuestions}'),
                    QuestionCountSelector(
                      value: form.count,
                      onChanged: controller.setCount,
                      maxAllowed: plan?.limits.maxQuestionsPerSet,
                      onLocked: () => showUpgradeSheet(
                        context,
                        PlanLimitHit(
                          PlanLimitKind.setSize,
                          max: plan?.limits.maxQuestionsPerSet,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Pro: brand-new AI questions instead of the shared bank.
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.accent,
                      ),
                      title: Text(l10n.freshAiToggle),
                      subtitle: Text(l10n.freshAiToggleHint),
                      value: form.fresh && (plan?.limits.freshAi ?? false),
                      onChanged: (v) => (plan?.limits.freshAi ?? false)
                          ? controller.setFresh(v)
                          : showUpgradeSheet(
                              context,
                              const PlanLimitHit(PlanLimitKind.freshAiPro),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _GenerateBar(
          selectedTopics: form.topicIds.length,
          enabled: form.isComplete,
          onGenerate: () {
            final request = controller.buildRequest(
              examName: examName,
              syllabus: syllabus,
            );
            if (request == null) return;
            context.push(AppRoutes.generatedQuestions, extra: request);
          },
        ),
      ],
    );
  }
}

class _GenerateBar extends StatelessWidget {
  const _GenerateBar({
    required this.selectedTopics,
    required this.enabled,
    required this.onGenerate,
  });

  final int selectedTopics;
  final bool enabled;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surface,
      child: ResponsiveCenter(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              enabled
                  ? l10n.topicsSelected(selectedTopics)
                  : l10n.generatorIncomplete,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: l10n.generateQuestions,
              icon: Icons.auto_awesome,
              onPressed: enabled ? onGenerate : null,
            ),
          ],
        ),
      ),
    );
  }
}
