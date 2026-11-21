import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/practice_result.dart';
import '../domain/saved_practice.dart';

/// Stand-in for the saved-practice API. Persists to SharedPreferences so
/// saved sets survive restarts in the UI phase (practice data only — nothing
/// sensitive). Simulates network latency like the real call.
class MockSavedPracticeRepository implements SavedPracticeRepository {
  MockSavedPracticeRepository(this._prefs);

  final SharedPreferences _prefs;
  static const latency = Duration(milliseconds: 700);

  List<SavedPractice> _read() {
    final raw = _prefs.getString(PrefKeys.savedPractice);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => SavedPractice.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Object {
      return []; // corrupt cache: start fresh rather than crash
    }
  }

  Future<void> _write(List<SavedPractice> items) => _prefs.setString(
    PrefKeys.savedPractice,
    jsonEncode(items.map((e) => e.toJson()).toList()),
  );

  @override
  bool isSaved(String resultId) =>
      _read().any((s) => s.result.resultId == resultId);

  @override
  Future<SavedPractice> save(PracticeResult result) async {
    await Future<void>.delayed(latency);
    final items = _read();
    for (final s in items) {
      if (s.result.resultId == result.resultId) return s;
    }
    final saved = SavedPractice(
      id: 'saved_${result.resultId}',
      savedAt: DateTime.now(),
      result: result,
    );
    await _write([saved, ...items]);
    return saved;
  }

  @override
  Future<List<SavedPractice>> list() async {
    await Future<void>.delayed(latency);
    return _read()..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(latency);
    await _write(_read().where((s) => s.id != id).toList());
  }
}
