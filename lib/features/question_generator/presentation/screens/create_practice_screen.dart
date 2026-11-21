import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../practice_test/domain/practice_result.dart';
import '../../../practice_test/presentation/providers/practice_providers.dart';
import '../../../subscription/domain/subscription_models.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/widgets/upgrade_sheet.dart';
import '../../domain/generated_question.dart';
import '../../domain/question_generator_repository.dart';
import '../../domain/syllabus.dart';
import '../providers/question_generator_providers.dart';
import '../widgets/generator_options.dart';

/// One screen to set up a practice test: quick-start shortcuts, then
/// subject → topics (inline, multi-select) → level → count, with a sticky
/// summary + Generate bar. Level and count are preselected.
class CreatePracticeScreen extends ConsumerWidget {
  const CreatePracticeScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final exam = ref.watch(examByIdProvider(examId));
    final syllabus = ref.watch(syllabusProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPractice),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ActionChip(
              avatar: const Icon(
                Icons.school_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      exam?.name ?? examId,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
              tooltip: l10n.changeExam,
              onPressed: () => _pickExam(context, ref),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: syllabus.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              for (var i = 0; i < 4; i++) ...[
                const Skeleton(height: 72, radius: AppSpacing.tileRadius),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
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
              : _Body(
                  examId: examId,
                  examName: exam?.name ?? examId,
                  syllabus: s,
                ),
        ),
      ),
    );
  }

  Future<void> _pickExam(BuildContext context, WidgetRef ref) async {
    final cats = ref.read(examCatalogProvider).value ?? const [];
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(context.l10n.changeExam, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              for (final c in cats) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(c.name, style: AppTextStyles.labelBold),
                ),
                for (final e in c.exams)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.name),
                    trailing: e.id == examId
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pop(sheet, e.id),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
    if (picked != null && picked != examId && context.mounted) {
      context.pushReplacement(AppRoutes.syllabusFor(picked));
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.examId,
    required this.examName,
    required this.syllabus,
  });

  final String examId;
  final String examName;
  final Syllabus syllabus;

  /// Saves the setup for "Last practice" and opens the test.
  void _start(BuildContext context, WidgetRef ref, GenerationRequest request) {
    ref.read(lastPracticeStoreProvider).save(request);
    context.push(AppRoutes.generatedQuestions, extra: request);
  }

  int _cappedCount(WidgetRef ref, int wanted) {
    final max = ref.read(subscriptionProvider).value?.limits.maxQuestionsPerSet;
    return max == null ? wanted : math.min(wanted, max);
  }

  void _quick10(BuildContext context, WidgetRef ref) {
    // Server accepts up to 40 topics; take a random spread when the exam has more.
    final all = [
      for (final s in syllabus.subjects)
        for (final t in s.topics) t.id,
    ]..shuffle();
    _start(
      context,
      ref,
      GenerationRequest(
        examId: examId,
        examName: examName,
        topicIds: all.take(40).toList(),
        difficulty: kDefaultDifficulty,
        count: _cappedCount(ref, 10),
      ),
    );
  }

  void _last(BuildContext context, WidgetRef ref) {
    final last = ref.read(lastPracticeStoreProvider).read(examId);
    final valid =
        last?.topicIds.where((id) => syllabus.topicName(id) != null).toSet() ??
        {};
    if (last == null || valid.isEmpty) {
      _toast(context, context.l10n.noLastPractice);
      return;
    }
    _start(
      context,
      ref,
      GenerationRequest(
        examId: examId,
        examName: examName,
        topicIds: [
          for (final s in syllabus.subjects)
            for (final t in s.topics)
              if (valid.contains(t.id)) t.id,
        ],
        difficulty: last.difficulty,
        count: _cappedCount(ref, last.count),
      ),
    );
  }

  Future<void> _weak(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    List<TopicStat> stats;
    try {
      stats = await ref.read(practiceRepositoryProvider).topicStats();
    } on Object catch (e) {
      if (context.mounted) _toast(context, apiErrorText(l10n, e));
      return;
    }
    final examTopics = {
      for (final s in syllabus.subjects)
        for (final t in s.topics) t.id,
    };
    final weak = pickWeakTopics(stats, examTopics);
    if (!context.mounted) return;
    if (weak.isEmpty) {
      _toast(context, l10n.noWeakTopics);
      return;
    }
    _start(
      context,
      ref,
      GenerationRequest(
        examId: examId,
        examName: examName,
        topicIds: weak,
        difficulty: kDefaultDifficulty,
        count: _cappedCount(ref, 10),
      ),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(text)),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final form = ref.watch(generatorFormProvider(examId));
    final controller = ref.read(generatorFormProvider(examId).notifier);
    final plan = ref.watch(subscriptionProvider).value;
    final active = syllabus.subjects.firstWhere(
      (s) => s.id == form.activeSubjectId,
      orElse: () => syllabus.subjects.first,
    );
    int pickedIn(SyllabusSubject s) =>
        s.topics.where((t) => form.topicIds.contains(t.id)).length;
    final pickedHere = pickedIn(active);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.quickStart, style: AppTextStyles.labelBold),
                    const SizedBox(height: AppSpacing.xs),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _QuickCard(
                            icon: Icons.bolt_rounded,
                            color: AppColors.secondary,
                            title: l10n.quick10,
                            hint: l10n.quick10Hint,
                            onTap: () => _quick10(context, ref),
                          ),
                          const SizedBox(width: 8),
                          _QuickCard(
                            icon: Icons.history_rounded,
                            color: AppColors.primary,
                            title: l10n.lastPractice,
                            hint: l10n.lastPracticeHint,
                            onTap: () => _last(context, ref),
                          ),
                          const SizedBox(width: 8),
                          _QuickCard(
                            icon: Icons.gps_fixed_rounded,
                            color: AppColors.error,
                            title: l10n.quickWeakTopics,
                            hint: l10n.weakTopicsHint,
                            onTap: () => _weak(context, ref),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            l10n.orBuildYourOwn,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 1. Subject
                    _StepTitle(number: 1, title: l10n.stepSubject),
                    // One scrollable row so long subject names do not push
                    // the topics down the screen.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          for (final (i, s) in syllabus.subjects.indexed)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                avatar: Icon(
                                  subjectStyle(s, i).icon,
                                  size: 18,
                                  color: subjectStyle(s, i).color,
                                ),
                                label: Text(
                                  pickedIn(s) == 0
                                      ? s.name
                                      : l10n.subjectWithCount(
                                          s.name,
                                          pickedIn(s),
                                        ),
                                ),
                                selected: s.id == active.id,
                                onSelected: (_) =>
                                    controller.setActiveSubject(s.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Topics of the active subject (inline, multi-select)
                    Row(
                      children: [
                        Expanded(
                          child: _StepTitle(
                            number: 2,
                            title: l10n.stepTopics,
                            trailing: form.topicIds.isEmpty
                                ? null
                                : l10n.selectedCount(form.topicIds.length),
                          ),
                        ),
                        if (pickedHere < active.topics.length)
                          TextButton(
                            onPressed: () => controller.selectAllIn(active),
                            child: Text(l10n.selectAll),
                          )
                        else
                          TextButton(
                            onPressed: () => controller.clearSubject(active),
                            child: Text(l10n.clear),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in active.topics)
                          FilterChip(
                            label: Text(t.name),
                            selected: form.topicIds.contains(t.id),
                            onSelected: (_) => controller.toggleTopic(t.id),
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            checkmarkColor: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Level (Medium preselected)
                    _StepTitle(number: 3, title: l10n.stepLevel),
                    DifficultySelector(
                      value: form.difficulty,
                      onChanged: controller.setDifficulty,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4. Questions (10 preselected; Pro sizes locked on Free)
                    _StepTitle(number: 4, title: l10n.stepQuestions),
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
                    const SizedBox(height: AppSpacing.sm),
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
        _SummaryBar(
          summary: form.isComplete
              ? l10n.practiceSummary(
                  [
                    for (final s in syllabus.subjects)
                      if (pickedIn(s) > 0) s.name,
                  ].join(', '),
                  form.topicIds.length,
                  form.difficulty.label(l10n),
                  form.count,
                )
              : l10n.selectAtLeastOneTopic,
          ready: form.isComplete,
          onGenerate: () {
            final request = controller.buildRequest(
              examName: examName,
              syllabus: syllabus,
            );
            if (request != null) _start(context, ref, request);
          },
        ),
      ],
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.number, required this.title, this.trailing});

  final int number;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiGradient,
              ),
              child: Text(
                '$number',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.white,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.labelBold.copyWith(
                fontSize: AppFontSizes.lg,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  trailing!,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(title, style: AppTextStyles.labelBold),
                const SizedBox(height: 2),
                Text(
                  hint,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sticky bottom bar: what will be generated (or what is missing) + Generate.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.summary,
    required this.ready,
    required this.onGenerate,
  });

  final String summary;
  final bool ready;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: scheme.surface,
      shadowColor: AppColors.cardShadow,
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
              summary,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: ready ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: ready
                    ? AppFontWeights.semiBold
                    : AppFontWeights.regular,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: l10n.generateQuestions,
              icon: Icons.auto_awesome,
              onPressed: ready ? onGenerate : null,
            ),
          ],
        ),
      ),
    );
  }
}
