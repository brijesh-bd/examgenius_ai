import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../localization/settings_providers.dart';
import '../../../question_generator/presentation/providers/question_generator_providers.dart';
import '../../../question_generator/presentation/widgets/concept_tree.dart';

/// Hierarchical syllabus picker (any subject) for AI Study Notes: the same hierarchy
/// (and node ids) as Create Practice. Tapping a node opens Create Notes.
class NotesConceptScreen extends ConsumerWidget {
  const NotesConceptScreen({
    super.key,
    required this.examId,
    required this.subjectId,
  });

  final String examId;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tree = ref.watch(
      conceptHierarchyProvider((examId: examId, subjectId: subjectId)),
    );
    final lang = ref.watch(localeProvider).languageCode == 'hi' ? 'hi' : 'en';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesConceptPickerTitle)),
      body: SafeArea(
        top: false,
        child: tree.when(
          loading: () => ResponsiveCenter(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  const Skeleton(height: 48),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
            ),
          ),
          error: (e, _) => StateMessage(
            icon: Icons.wifi_off_rounded,
            title: apiErrorText(l10n, e),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(
              conceptHierarchyProvider((examId: examId, subjectId: subjectId)),
            ),
          ),
          data: (t) => t == null || t.chapters.isEmpty
              ? StateMessage(
                  icon: Icons.menu_book_outlined,
                  title: l10n.comingSoon,
                )
              : ListView(
                  children: [
                    ResponsiveCenter(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: ConceptTree(
                        tree: t,
                        languageCode: lang,
                        onPick: (id) =>
                            context.push(AppRoutes.notesCreateFor(examId, id)),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
