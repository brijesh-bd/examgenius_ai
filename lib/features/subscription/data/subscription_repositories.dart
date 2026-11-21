import '../../../core/network/api_client.dart';
import '../domain/subscription_models.dart';

/// `GET /api/v1/subscription`, `POST /api/v1/subscription/trial`.
class ApiSubscriptionRepository implements SubscriptionRepository {
  ApiSubscriptionRepository(this._api);

  final ApiClient _api;

  @override
  Future<SubscriptionStatus> fetchStatus() async =>
      SubscriptionStatus.fromJson(await _api.get('/subscription'));

  @override
  Future<SubscriptionStatus> startTrial() async =>
      SubscriptionStatus.fromJson(await _api.post('/subscription/trial'));
}

/// In-app stand-in (tests / USE_MOCK_BACKEND). Free plan; trial turns on Pro.
/// Limits are enforced by the real server only.
class MockSubscriptionRepository implements SubscriptionRepository {
  bool _pro = false;
  bool _trialUsed = false;

  static const offers = [
    PlanOffer(id: 'pro_monthly', months: 1, priceInr: 99),
    PlanOffer(id: 'pro_quarterly', months: 3, priceInr: 249),
    PlanOffer(id: 'pro_yearly', months: 12, priceInr: 499, popular: true),
  ];

  SubscriptionStatus _status() {
    final now = DateTime.now();
    return SubscriptionStatus(
      isPro: _pro,
      source: _pro ? 'trial' : null,
      expiresAt: _pro ? now.add(const Duration(days: 7)) : null,
      trialAvailable: !_pro && !_trialUsed,
      trialDays: 7,
      limits: _pro
          ? const PlanLimits(
              maxQuestionsPerSet: 30,
              questionsPerDay: 300,
              freshAi: true,
            )
          : const PlanLimits(
              maxQuestionsPerSet: 10,
              setsPerDay: 2,
              maxSaved: 10,
              freshAi: false,
            ),
      setsUsedToday: 0,
      questionsUsedToday: 0,
      resetsAt: DateTime(now.year, now.month, now.day + 1),
      offers: offers,
    );
  }

  @override
  Future<SubscriptionStatus> fetchStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _status();
  }

  @override
  Future<SubscriptionStatus> startTrial() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _pro = true;
    _trialUsed = true;
    return _status();
  }
}
