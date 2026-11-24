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
import '../../../../localization/settings_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../dashboard/domain/dashboard_models.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/presentation/widgets/exam_category_cards.dart';
import '../../../subscription/domain/subscription_models.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/widgets/upgrade_sheet.dart';
import '../../domain/generated_question.dart';
import '../../domain/question_generator_repository.dart';
import '../../domain/syllabus.dart';
import '../providers/question_generator_providers.dart';
import '../widgets/practice_setup_widgets.dart';

/// Topics shown before "Show all" on a subject with many topics.
const kCollapsedTopicCount = 8;

/// One-screen preparation for an exam category:
/// exam chips → subject → topics → question count → fixed Start Practice.
///
/// Opened with a [categoryId] (dashboard card) or an [examId] (old
/// `/syllabus/:examId` links); the other is resolved from the catalog.
/// The question source is chosen automatically: the Question Bank when it
/// has enough questions, otherwise AI when the plan allows another AI set.
class PreparationScreen extends ConsumerStatefulWidget {
  const PreparationScreen({super.key, this.categoryId, this.examId});

  final String? categoryId;
  final String? examId;

  @override
  ConsumerState<PreparationScreen> createState() => _PreparationScreenState();
}

class _PreparationScreenState extends ConsumerState<PreparationScreen> {
  String? _examId;

  /// The category to show and the initially selected exam.
  ({ExamCategory category, String examId})? _resolve(List<ExamCategory> cats) {
    for (final c in cats) {
      final inCategory = widget.categoryId == null
          ? c.exams.any((e) => e.id == widget.examId)
          : c.id == widget.categoryId;
      if (!inCategory || c.exams.isEmpty) continue;
      final target = ref.read(sessionProvider)?.targetExamId;
      final preferred = [_examId, widget.examId, target];
      final initial = preferred.firstWhere(
        (id) => id != null && c.exams.any((e) => e.id == id),
        orElse: () => c.exams.first.id,
      )!;
      return (category: c, examId: initial);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = ref.watch(examCatalogProvider);
    final plan = ref.watch(subscriptionProvider).value;
    final resolved = catalog.whenOrNull(data: _resolve);
    final title = resolved == null
        ? l10n.createPractice
        : l10n.prepTitle(categoryStyle(context, resolved.category).shortLabel);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (plan != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Center(child: PlanBadge(isPro: plan.isPro)),
            ),
        ],
      ),
      body: catalog.when(
        loading: () => const _LoadingList(),
        error: (e, _) => StateMessage(
          icon: Icons.wifi_off_rounded,
          title: apiErrorText(l10n, e),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(examCatalogProvider),
        ),
        data: (_) => resolved == null
            ? StateMessage(icon: Icons.school_outlined, title: l10n.comingSoon)
            : _ExamPrep(
                // A new key per exam: fresh form, scroll and busy state.
                key: ValueKey(resolved.examId),
                category: resolved.category,
                examId: resolved.examId,
                onExamChanged: (id) => setState(() => _examId = id),
              ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.page),
    children: [
      for (var i = 0; i < 4; i++) ...[
        const Skeleton(height: 56, radius: AppSpacing.tileRadius),
        const SizedBox(height: AppSpacing.sm),
      ],
    ],
  );
}

class _ExamPrep extends ConsumerStatefulWidget {
  const _ExamPrep({
    super.key,
    required this.category,
    required this.examId,
    required this.onExamChanged,
  });

  final ExamCategory category;
  final String examId;
  final ValueChanged<String> onExamChanged;

  @override
  ConsumerState<_ExamPrep> createState() => _ExamPrepState();
}

class _ExamPrepState extends ConsumerState<_ExamPrep> {
  /// True while checking / starting: prevents repeated submissions.
  bool _busy = false;
  bool _showAllTopics = false;

  String get examId => widget.examId;

  SubscriptionStatus? get _plan => ref.read(subscriptionProvider).value;

  String get _language =>
      ref.read(localeProvider).languageCode == 'hi' ? 'hi' : 'en';

  int _maxCount(SubscriptionStatus? plan) =>
      plan?.limits.maxQuestionsPerSet ?? kDefaultQuestionCount;

  /// Explains a plan limit BEFORE sending a request the server would refuse.
  bool _passesPlan(GenerationRequest r) {
    final plan = _plan;
    if (plan == null) return true; // server still enforces
    PlanLimitHit? hit;
    if (r.count > plan.limits.maxQuestionsPerSet) {
      hit = PlanLimitHit(
        PlanLimitKind.setSize,
        max: plan.limits.maxQuestionsPerSet,
      );
    } else if (plan.setsLeftToday == 0) {
      hit = PlanLimitHit(
        PlanLimitKind.dailySets,
        max: plan.limits.setsPerDay,
        resetsAt: plan.resetsAt,
      );
    } else if (plan.questionsLeftToday != null &&
        plan.questionsLeftToday! < r.count) {
      hit = PlanLimitHit(
        PlanLimitKind.dailyQuestions,
        max: plan.limits.questionsPerDay,
        resetsAt: plan.resetsAt,
      );
    }
    if (hit == null) return true;
    showUpgradeSheet(context, hit);
    return false;
  }

  /// Question Bank first; AI when the bank is short and the plan allows
  /// another AI set; otherwise explains and offers the available questions.
  Future<void> _start(GenerationRequest request) async {
    if (_busy || !_passesPlan(request)) return;
    setState(() => _busy = true);
    var r = request.copyWith(source: QuestionSource.bank);
    int? available;
    try {
      available = await ref
          .read(practiceSetupRepositoryProvider)
          .bankAvailability(
            examId: r.examId,
            mode: r.mode,
            topicIds: r.topicIds,
            difficulty: r.difficulty,
            language: _language,
          );
    } on Object {
      available = null; // the server checks again and explains
    }
    if (!mounted) return;
    if (available != null && available < r.count) {
      final plan = _plan;
      final aiOk = plan == null || plan.canStartAiSet;
      if (aiOk) {
        r = r.copyWith(source: QuestionSource.ai);
      } else {
        setState(() => _busy = false);
        final count = await _bankShort(r, available);
        if (count == null || !mounted) return;
        r = r.copyWith(count: count);
        setState(() => _busy = true);
      }
    }
    await ref
        .read(lastPracticeStoreProvider)
        .save(LastPracticeConfig.fromRequest(r, language: _language));
    if (!mounted) return;
    setState(() => _busy = false);
    await context.push(AppRoutes.generatedQuestions, extra: r);
  }

  /// Not enough stored questions and no AI set left today: the student may
  /// practise the available ones (never reduced silently) or change topics.
  Future<int?> _bankShort(GenerationRequest r, int available) {
    final l10n = context.l10n;
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.bankInsufficientTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              Text(
                available == 0
                    ? l10n.bankNoneBody
                    : l10n.bankInsufficientBody(available, r.count),
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              if (available > 0)
                FilledButton(
                  onPressed: () => Navigator.pop(sheet, available),
                  child: Text(l10n.bankUseAvailable(available)),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(sheet),
                child: Text(l10n.changeSelection),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final exam = widget.category.exams.firstWhere((e) => e.id == examId);
    final syllabus = ref.watch(syllabusProvider(examId));
    final form = ref.watch(generatorFormProvider(examId));
    final controller = ref.read(generatorFormProvider(examId).notifier);
    final plan = ref.watch(subscriptionProvider).value;
    final max = _maxCount(plan);
    final s = syllabus.value;
    final subject = s?.subjects
        .where((x) => x.id == form.activeSubjectId)
        .firstOrNull;
    final count = form.count <= max ? form.count : kDefaultQuestionCount;
    final selected = subject == null
        ? 0
        : subject.topics.where((t) => form.topicIds.contains(t.id)).length;
    final hint = subject == null
        ? l10n.chooseSubjectFirst
        : selected == 0
        ? l10n.selectAtLeastOneTopic
        : null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              ResponsiveCenter(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xs,
                  AppSpacing.page,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Examination chips (one at a time)
                    SetupLabel(l10n.stepExam),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final e in widget.category.exams)
                          ChoiceChip(
                            label: Text(e.name),
                            selected: e.id == examId,
                            onSelected: _busy || e.id == examId
                                ? null
                                : (_) => widget.onExamChanged(e.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...switch (syllabus) {
                      AsyncData(:final value) when value.subjects.isEmpty => [
                        StateMessage(
                          icon: Icons.menu_book_outlined,
                          title: l10n.comingSoon,
                        ),
                      ],
                      AsyncData(:final value) => _sections(
                        context,
                        value,
                        form,
                        controller,
                        subject,
                        selected,
                        count,
                        max,
                        plan,
                      ),
                      AsyncError(:final error) => [
                        StateMessage(
                          icon: Icons.wifi_off_rounded,
                          title: apiErrorText(l10n, error),
                          actionLabel: l10n.retry,
                          onAction: () =>
                              ref.invalidate(syllabusProvider(examId)),
                        ),
                      ],
                      _ => [
                        for (var i = 0; i < 3; i++) ...[
                          const Skeleton(
                            height: 48,
                            radius: AppSpacing.tileRadius,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
        GenerateBar(
          label: l10n.startPracticeCount(count),
          hint: s == null ? l10n.chooseSubjectFirst : hint,
          busy: _busy,
          onPressed: () {
            if (s == null) return;
            final request = controller.buildRequest(
              examName: exam.name,
              syllabus: s,
            );
            if (request != null) _start(request.copyWith(count: count));
          },
        ),
      ],
    );
  }

  List<Widget> _sections(
    BuildContext context,
    Syllabus syllabus,
    GeneratorForm form,
    GeneratorFormController controller,
    SyllabusSubject? subject,
    int selected,
    int count,
    int max,
    SubscriptionStatus? plan,
  ) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final topics = subject?.topics ?? const <SyllabusTopic>[];
    final collapsed = !_showAllTopics && topics.length > kCollapsedTopicCount;
    final shown = collapsed ? topics.take(kCollapsedTopicCount) : topics;
    final allPicked = subject != null && selected == topics.length;

    return [
      // 2. Subject (one at a time; changing it clears the topics)
      SetupLabel(l10n.stepSubject),
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final x in syllabus.subjects)
            ChoiceChip(
              label: Text(x.name),
              selected: x.id == subject?.id,
              onSelected: (_) {
                if (x.id == subject?.id) return;
                setState(() => _showAllTopics = false);
                controller.selectSubject(x.id);
              },
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),

      // 3. Topics of the selected subject (multi-select)
      if (subject != null) ...[
        SetupLabel(
          selected == 0
              ? l10n.stepTopics
              : '${l10n.stepTopics} · ${l10n.topicsSelected(selected)}',
          trailing: TextButton(
            onPressed: () => allPicked
                ? controller.clearTopics()
                : controller.selectAllIn(subject),
            child: Text(allPicked ? l10n.clearTopics : l10n.selectAll),
          ),
        ),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final t in shown)
              FilterChip(
                label: Text(t.name),
                selected: form.topicIds.contains(t.id),
                onSelected: (_) => controller.toggleTopic(t.id),
              ),
          ],
        ),
        if (topics.length > kCollapsedTopicCount)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAllTopics = collapsed),
              icon: Icon(
                collapsed
                    ? Icons.expand_more_rounded
                    : Icons.expand_less_rounded,
              ),
              label: Text(
                collapsed ? l10n.showAllTopics(topics.length) : l10n.showFewer,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],

      // 4. Number of questions (Free 5/10; Premium up to 40; locked above max)
      SetupLabel(l10n.stepQuestions),
      CountPresets(
        value: count,
        max: max,
        customAllowed: false,
        onChanged: controller.setCount,
        onLocked: () => showUpgradeSheet(
          context,
          PlanLimitHit(PlanLimitKind.setSize, max: max),
        ),
      ),
      if (plan != null && kQuestionCountOptions.any((n) => n > max)) ...[
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.moreQuestionsPremium,
          style: AppTextStyles.tiny.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],

      // 5. Remaining allowance
      if (plan != null) ...[
        const SizedBox(height: AppSpacing.md),
        UsageStrip(status: plan),
      ],
    ];
  }
}
