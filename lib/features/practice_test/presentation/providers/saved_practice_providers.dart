import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../data/mock_saved_practice_repository.dart';
import '../../domain/practice_result.dart';
import '../../domain/saved_practice.dart';

/// Swap for an API-backed repository when the backend is live.
final savedPracticeRepositoryProvider = Provider<SavedPracticeRepository>(
  (ref) => MockSavedPracticeRepository(ref.watch(sharedPreferencesProvider)),
);

/// Save status for one result on the scorecard.
@immutable
class SaveState {
  const SaveState({this.saving = false, this.saved, this.error});

  final bool saving;

  /// Set once the backend confirmed the save.
  final SavedPractice? saved;
  final Object? error;

  bool get isSaved => saved != null;
}

/// Saves a result once. Repeated taps while saving or after success are
/// ignored; a failure can be retried.
class SavePracticeController extends Notifier<SaveState> {
  SavePracticeController(this.result);

  final PracticeResult result;

  SavedPracticeRepository get _repo => ref.read(savedPracticeRepositoryProvider);

  @override
  SaveState build() {
    // Already saved earlier (e.g. reopened scorecard): show as saved.
    if (_repo.isSaved(result.resultId)) {
      return SaveState(
        saved: SavedPractice(id: 'saved_${result.resultId}', savedAt: DateTime.now(), result: result),
      );
    }
    return const SaveState();
  }

  /// Returns true only when the backend confirmed the save.
  Future<bool> save() async {
    if (state.saving || state.isSaved) return state.isSaved;
    state = const SaveState(saving: true);
    try {
      final saved = await _repo.save(result);
      if (!ref.mounted) return true;
      state = SaveState(saved: saved);
      return true;
    } on Object catch (e) {
      if (!ref.mounted) return false;
      state = SaveState(error: e);
      return false;
    }
  }
}

final savePracticeProvider = NotifierProvider.autoDispose
    .family<SavePracticeController, SaveState, PracticeResult>(SavePracticeController.new);
