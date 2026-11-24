import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

/// A purchasable Pro option shown on the Plans screen (price incl. GST).
@immutable
class PlanOffer {
  const PlanOffer({
    required this.id,
    required this.months,
    required this.priceInr,
    this.popular = false,
  });

  final String id;
  final int months;
  final int priceInr;
  final bool popular;

  int get perMonthInr => (priceInr / months).round();

  factory PlanOffer.fromJson(Map<String, dynamic> j) => PlanOffer(
    id: j['id'] as String,
    months: (j['months'] as num).toInt(),
    priceInr: (j['priceInr'] as num).toInt(),
    popular: j['popular'] as bool? ?? false,
  );
}

/// Limits of the student's current plan (null = not limited that way).
@immutable
class PlanLimits {
  const PlanLimits({
    required this.maxQuestionsPerSet,
    required this.freshAi,
    this.setsPerDay,
    this.aiSetsPerDay,
    this.questionsPerDay,
    this.maxSaved,
    this.customCount = false,
  });

  /// Practice sets per day (bank + AI together); null = not limited.
  final int? setsPerDay;

  /// AI-generated sets per day; 0 = AI not in the plan, null = no separate cap.
  final int? aiSetsPerDay;

  /// May choose any question count up to [maxQuestionsPerSet].
  final bool customCount;

  bool get aiIncluded => aiSetsPerDay != 0;
  final int? questionsPerDay;
  final int maxQuestionsPerSet;
  final int? maxSaved;
  final bool freshAi;

  factory PlanLimits.fromJson(Map<String, dynamic> j) => PlanLimits(
    setsPerDay: (j['setsPerDay'] as num?)?.toInt(),
    aiSetsPerDay: (j['aiSetsPerDay'] as num?)?.toInt(),
    customCount: j['customCount'] as bool? ?? false,
    questionsPerDay: (j['questionsPerDay'] as num?)?.toInt(),
    maxQuestionsPerSet: (j['maxQuestionsPerSet'] as num).toInt(),
    maxSaved: (j['maxSaved'] as num?)?.toInt(),
    freshAi: j['freshAi'] as bool? ?? false,
  );
}

/// `GET /api/v1/subscription` — the server is the source of truth.
@immutable
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isPro,
    required this.trialAvailable,
    required this.trialDays,
    required this.limits,
    required this.setsUsedToday,
    required this.questionsUsedToday,
    required this.resetsAt,
    this.aiSetsUsedToday = 0,
    required this.offers,
    this.source,
    this.expiresAt,
  });

  final bool isPro;

  /// 'trial' | 'manual' | 'purchase' when Pro.
  final String? source;
  final DateTime? expiresAt;
  final bool trialAvailable;
  final int trialDays;
  final PlanLimits limits;
  final int setsUsedToday;
  final int questionsUsedToday;
  final int aiSetsUsedToday;
  final DateTime resetsAt;
  final List<PlanOffer> offers;

  bool get isTrial => isPro && source == 'trial';

  /// Free sets left today, or null when sets are not limited (Pro).
  int? get setsLeftToday => limits.setsPerDay == null
      ? null
      : (limits.setsPerDay! - setsUsedToday).clamp(0, limits.setsPerDay!);

  /// AI sets left today, or null when not separately capped.
  int? get aiSetsLeftToday => limits.aiSetsPerDay == null
      ? null
      : (limits.aiSetsPerDay! - aiSetsUsedToday).clamp(0, limits.aiSetsPerDay!);

  /// Questions left today under a daily question cap (Pro fair use).
  int? get questionsLeftToday => limits.questionsPerDay == null
      ? null
      : (limits.questionsPerDay! - questionsUsedToday).clamp(
          0,
          limits.questionsPerDay!,
        );

  /// Can start any set today (display only — the server enforces).
  bool get canStartSet => setsLeftToday != 0 && questionsLeftToday != 0;

  /// Can start an AI set today (display only — the server enforces).
  bool get canStartAiSet =>
      limits.aiIncluded && canStartSet && aiSetsLeftToday != 0;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> j) {
    final usage = j['usageToday'] as Map<String, dynamic>? ?? const {};
    return SubscriptionStatus(
      isPro: j['tier'] == 'pro',
      source: j['source'] as String?,
      expiresAt: j['expiresAt'] == null
          ? null
          : DateTime.parse(j['expiresAt'] as String),
      trialAvailable: j['trialAvailable'] as bool? ?? false,
      trialDays: (j['trialDays'] as num?)?.toInt() ?? 7,
      limits: PlanLimits.fromJson(j['limits'] as Map<String, dynamic>),
      setsUsedToday: (usage['sets'] as num?)?.toInt() ?? 0,
      questionsUsedToday: (usage['questions'] as num?)?.toInt() ?? 0,
      aiSetsUsedToday: (usage['aiSets'] as num?)?.toInt() ?? 0,
      resetsAt: DateTime.parse(j['resetsAt'] as String),
      offers: [
        for (final o in (j['offers'] as List<dynamic>? ?? const []))
          PlanOffer.fromJson(o as Map<String, dynamic>),
      ],
    );
  }
}

/// Why the server refused a request on the current plan.
enum PlanLimitKind {
  dailySets,
  dailyAiSets,
  aiNotInPlan,
  dailyQuestions,
  setSize,
  savedLimit,
  freshAiPro,
}

/// A plan limit hit, decoded from the server's 403 `code`.
@immutable
class PlanLimitHit {
  const PlanLimitHit(this.kind, {this.max, this.resetsAt});

  final PlanLimitKind kind;
  final int? max;
  final DateTime? resetsAt;

  /// Returns the limit hit if [error] is one, otherwise null.
  static PlanLimitHit? from(Object? error) {
    if (error is! ApiException || error.statusCode != 403) return null;
    final kind = switch (error.code) {
      'DAILY_SETS' => PlanLimitKind.dailySets,
      'DAILY_AI_SETS' => PlanLimitKind.dailyAiSets,
      'AI_NOT_IN_PLAN' => PlanLimitKind.aiNotInPlan,
      'DAILY_QUESTIONS' => PlanLimitKind.dailyQuestions,
      'SET_SIZE' => PlanLimitKind.setSize,
      'SAVED_LIMIT' => PlanLimitKind.savedLimit,
      'FRESH_AI_PRO' => PlanLimitKind.freshAiPro,
      _ => null,
    };
    if (kind == null) return null;
    final reset = error.details['resetsAt'];
    return PlanLimitHit(
      kind,
      max: (error.details['max'] as num?)?.toInt(),
      resetsAt: reset is String ? DateTime.tryParse(reset) : null,
    );
  }
}

/// Plans are read and the trial is started on the backend.
abstract interface class SubscriptionRepository {
  Future<SubscriptionStatus> fetchStatus();

  /// Starts the one-time free trial and returns the new status.
  Future<SubscriptionStatus> startTrial();
}
