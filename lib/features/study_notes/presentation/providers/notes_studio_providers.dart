import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../localization/settings_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/study_note.dart';
import 'study_notes_providers.dart';

/// Where the AI Study Notes screen starts (old links keep working):
/// any of category / exam / subject / topic may be given.
typedef NotesStudioArgs = ({
  String? categoryId,
  String? examId,
  String? subjectId,
  String? targetId,
  String? language,
});

/// One progressive selection: category → exam → subject → topic (a syllabus
/// node of any level, or a flat topic id), then complete notes generation.
class NotesStudio {
  const NotesStudio({
    this.categoryId,
    this.examId,
    this.subjectId,
    this.targetId,
    required this.language,
    this.generating = false,
    this.startedAt,
    this.error,
    this.stage,
    this.joined = false,
    this.partial,
    this.result,
    this.resultSource,
  });

  final String? categoryId;
  final String? examId;
  final String? subjectId;

  /// Selected topic: node id (tree subjects) or topic id (flat subjects).
  final String? targetId;
  final String language;

  final bool generating;

  /// When the current generation started (real elapsed time is shown).
  final DateTime? startedAt;
  final Object? error;

  /// Real stage reported by the server while generating.
  final NotesStage? stage;

  /// The same topic was already being generated: this request shares it.
  final bool joined;

  /// Readable part of the notes so far; kept if the connection drops.
  final NoteContent? partial;

  /// The saved note once done (source: saved / cache / ai / joined).
  final StudyNote? result;
  final String? resultSource;

  bool get canGenerate => examId != null && targetId != null && !generating;

  NotesStudio copyWith({
    String? Function()? categoryId,
    String? Function()? examId,
    String? Function()? subjectId,
    String? Function()? targetId,
    String? language,
    bool? generating,
    DateTime? Function()? startedAt,
    Object? Function()? error,
    NotesStage? Function()? stage,
    bool? joined,
    NoteContent? Function()? partial,
    StudyNote? Function()? result,
    String? Function()? resultSource,
  }) => NotesStudio(
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    examId: examId == null ? this.examId : examId(),
    subjectId: subjectId == null ? this.subjectId : subjectId(),
    targetId: targetId == null ? this.targetId : targetId(),
    language: language ?? this.language,
    generating: generating ?? this.generating,
    startedAt: startedAt == null ? this.startedAt : startedAt(),
    error: error == null ? this.error : error(),
    stage: stage == null ? this.stage : stage(),
    joined: joined ?? this.joined,
    partial: partial == null ? this.partial : partial(),
    result: result == null ? this.result : result(),
    resultSource: resultSource == null ? this.resultSource : resultSource(),
  );
}

class NotesStudioController extends Notifier<NotesStudio> {
  NotesStudioController(this.args);

  final NotesStudioArgs args;

  /// Same request object until the selection changes, so a retry after a
  /// failure or timeout reuses the idempotency key (never a duplicate note).
  NotesRequest? _pending;

  @override
  NotesStudio build() => NotesStudio(
    categoryId: args.categoryId,
    examId: args.examId,
    subjectId: args.subjectId,
    targetId: args.targetId,
    language:
        args.language ??
        (ref.read(localeProvider).languageCode == 'hi' ? 'hi' : 'en'),
  );

  void _set(NotesStudio next) {
    if (state.generating) return; // selection is locked while generating
    _pending = null;
    state = next.copyWith(error: () => null);
  }

  /// A new category clears everything below it.
  void selectCategory(String id) {
    if (id == state.categoryId) return;
    _set(
      state.copyWith(
        categoryId: () => id,
        examId: () => null,
        subjectId: () => null,
        targetId: () => null,
      ),
    );
  }

  void selectExam(String id, {String? categoryId}) {
    if (id == state.examId) return;
    _set(
      state.copyWith(
        categoryId: categoryId == null ? null : () => categoryId,
        examId: () => id,
        subjectId: () => null,
        targetId: () => null,
      ),
    );
  }

  void selectSubject(String id) {
    if (id == state.subjectId) return;
    _set(state.copyWith(subjectId: () => id, targetId: () => null));
  }

  /// Tapping the selected topic again clears it.
  void pick(String id) =>
      _set(state.copyWith(targetId: () => id == state.targetId ? null : id));

  void setLanguage(String code) {
    if (code == state.language) return;
    _set(state.copyWith(language: code));
  }

  /// Generates and saves complete notes. Returns the note, or null on
  /// failure (the error is in [state]; nothing was saved or counted).
  Future<StudyNote?> generate({bool regenerate = false}) async {
    if (!state.canGenerate) return null;
    final request = _pending ??= NotesRequest.complete(
      examId: state.examId!,
      topicId: state.targetId!,
      language: state.language,
    );
    state = state.copyWith(
      generating: true,
      startedAt: DateTime.now,
      error: () => null,
      stage: () => NotesStage.checking,
      joined: false,
      partial: () => null,
      result: () => null,
      resultSource: () => null,
    );
    final repo = ref.read(studyNotesRepositoryProvider);
    // One automatic resume after a dropped connection: same request key, so
    // the server returns the saved note or rejoins (never a second AI call).
    for (var attempt = 0; ; attempt++) {
      try {
        await for (final e in repo.generateStream(
          request,
          regenerate: regenerate && attempt == 0,
        )) {
          if (!ref.mounted) break;
          switch (e) {
            case NotesStatus(:final stage, :final joined):
              state = state.copyWith(
                stage: () => stage,
                joined: joined || state.joined,
              );
            case NotesPartial(:final content):
              state = state.copyWith(partial: () => content);
            case NotesDone(:final note, :final source):
              ref.read(notesRevisionProvider.notifier).bump();
              if (!ref.mounted) return note;
              _pending = null;
              state = state.copyWith(
                generating: false,
                startedAt: () => null,
                stage: () => null,
                result: () => note,
                resultSource: () => source,
              );
              return note;
          }
        }
        if (!ref.mounted) return null;
        throw const ApiException('Connection lost', isNetwork: true);
      } catch (e) {
        final dropped = e is ApiException && e.isNetwork;
        if (dropped && attempt == 0 && ref.mounted) continue;
        if (ref.mounted) {
          // The partial notes stay visible; Retry resumes with the same key.
          state = state.copyWith(
            generating: false,
            startedAt: () => null,
            stage: () => null,
            error: () => e,
          );
        }
        return null;
      }
    }
  }

  /// Leaves the kept partial notes and goes back to the selection.
  void dismissPartial() {
    if (state.generating) return;
    state = state.copyWith(partial: () => null, error: () => null);
  }

  /// The result was opened; the screen is ready for the next topic.
  void clearResult() {
    if (state.result == null) return;
    state = state.copyWith(result: () => null, resultSource: () => null);
  }
}

final notesStudioProvider = NotifierProvider.autoDispose
    .family<NotesStudioController, NotesStudio, NotesStudioArgs>(
      NotesStudioController.new,
    );

typedef TopicSummaryKey = ({String examId, String targetId, String language});

/// Topic overview before notes (cached on the server, shared by students).
final topicSummaryProvider = FutureProvider.autoDispose
    .family<TopicSummary, TopicSummaryKey>(
      (ref, k) => ref
          .watch(studyNotesRepositoryProvider)
          .topicSummary(
            examId: k.examId,
            targetId: k.targetId,
            language: k.language,
          ),
      // No silent background retries of an AI call: the overview shows the
      // failure and a Retry button (and never blocks generating the notes).
      retry: (_, _) => null,
    );
