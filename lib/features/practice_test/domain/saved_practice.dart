import 'package:flutter/foundation.dart';

import 'practice_result.dart';

/// A practice attempt the student saved: the complete scored result
/// (questions, options, correct + student answers, explanations, topics,
/// difficulty, scorecard, analytics) plus when it was saved.
@immutable
class SavedPractice {
  const SavedPractice({required this.id, required this.savedAt, required this.result});

  final String id;
  final DateTime savedAt;
  final PracticeResult result;

  factory SavedPractice.fromJson(Map<String, dynamic> json) => SavedPractice(
        id: json['id'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        result: PracticeResult.fromJson(json['result'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'result': result.toJson(),
      };
}

/// Saved practice sets. The backend already holds the full attempt, so saving
/// only sends the result id: `POST /api/v1/practice/saved {resultId}`.
abstract interface class SavedPracticeRepository {
  /// Saves [result]. Idempotent: saving the same result again returns the
  /// existing record. Throws on failure — callers show success only after
  /// this completes.
  Future<SavedPractice> save(PracticeResult result);

  /// Whether [resultId] is already saved (local cache; no network).
  bool isSaved(String resultId);

  /// All saved sets, newest first (`GET /api/v1/practice/saved`).
  Future<List<SavedPractice>> list();

  /// Deletes one saved set (`DELETE /api/v1/practice/saved/:id`).
  Future<void> delete(String id);
}
