import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../data/api_saved_practice_repository.dart';
import '../../data/mock_saved_practice_repository.dart';
import '../../domain/practice_result.dart';
import '../../domain/saved_practice.dart';

/// Real backend by default; in-app mock under `flutter test` or USE_MOCK_BACKEND.
final savedPracticeRepositoryProvider = Provider<SavedPracticeRepository>((
  ref,
) {
  if (ref.watch(useMockBackendProvider)) {
    return MockSavedPracticeRepository(ref.watch(sharedPreferencesProvider));
  }
  return ApiSavedPracticeRepository(ref.watch(apiClientProvider));
});

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

  SavedPracticeRepository get _repo =>
      ref.read(savedPracticeRepositoryProvider);

  @override
  SaveState build() {
    // Already saved earlier (e.g. reopened scorecard): show as saved.
    if (_repo.isSaved(result.resultId)) {
      return SaveState(
        saved: SavedPractice(
          id: 'saved_${result.resultId}',
          savedAt: DateTime.now(),
          result: result,
        ),
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
      ref.invalidate(savedPracticeListProvider); // list shows it next time
      return true;
    } on Object catch (e) {
      if (!ref.mounted) return false;
      state = SaveState(error: e);
      return false;
    }
  }
}

final savePracticeProvider = NotifierProvider.autoDispose
    .family<SavePracticeController, SaveState, PracticeResult>(
      SavePracticeController.new,
    );

/// My Saved Practice list (newest first) with delete.
class SavedPracticeListController extends AsyncNotifier<List<SavedPractice>> {
  SavedPracticeRepository get _repo =>
      ref.read(savedPracticeRepositoryProvider);

  @override
  Future<List<SavedPractice>> build() => _repo.list();

  /// Deletes on the backend first; removes the card only after it confirms.
  /// Returns false on failure (the card stays).
  Future<bool> delete(String id) async {
    try {
      await _repo.delete(id);
    } on Object {
      return false;
    }
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((s) => s.id != id).toList());
    }
    return true;
  }
}

final savedPracticeListProvider =
    AsyncNotifierProvider.autoDispose<
      SavedPracticeListController,
      List<SavedPractice>
    >(SavedPracticeListController.new);
