import '../../../../l10n/app_localizations.dart';
import '../../domain/study_note.dart';

/// Labels for saved notes (Library filters, note header). Older notes carry
/// a level / sections; new notes are complete-coverage (level "exam").
String noteSectionLabel(AppLocalizations l10n, NoteSection s) => switch (s) {
  NoteSection.explanation => l10n.secExplanation,
  NoteSection.definitions => l10n.secDefinitions,
  NoteSection.examples => l10n.secExamples,
  NoteSection.stepByStep => l10n.secStepByStep,
  NoteSection.diagrams => l10n.secDiagrams,
  NoteSection.graphs => l10n.secGraphs,
  NoteSection.formulas => l10n.secFormulas,
  NoteSection.tips => l10n.secTips,
  NoteSection.mistakes => l10n.secMistakes,
  NoteSection.keyPoints => l10n.secKeyPoints,
  NoteSection.revision => l10n.secRevision,
  NoteSection.mcqs => l10n.secMcqs,
};

String noteLevelLabel(AppLocalizations l10n, NoteLevel l) => switch (l) {
  NoteLevel.basic => l10n.noteLevelBasic,
  NoteLevel.examStandard => l10n.noteLevelExam,
  NoteLevel.advanced => l10n.noteLevelAdvanced,
};
