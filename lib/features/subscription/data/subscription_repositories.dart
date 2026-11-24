import '../../../core/network/api_client.dart';
import '../domain/subscription_models.dart';

/// `GET /api/v1/subscription`, `POST /api/v1/subscription/trial`.
class ApiSubscriptionRepository implements SubscriptionRepository {
  ApiSubscriptionRepository(this._api);

  final ApiClient _api;

  /// Device UTC offset sent once per app run, so daily limits reset at the
  /// student's local midnight (the server ignores changes within 24 h).
  bool _tzSent = false;

  @override
  Future<SubscriptionStatus> fetchStatus() async {
    if (!_tzSent) {
      try {
        await _api.patch('/auth/me', {
          'tzOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
        });
        _tzSent = true;
      } on Object {
        // Not critical: the server keeps the previous (or India) timezone.
      }
    }
    return SubscriptionStatus.fromJson(await _api.get('/subscription'));
  }

  @override
  Future<SubscriptionStatus> startTrial() async =>
      SubscriptionStatus.fromJson(await _api.post('/subscription/trial'));
}

/// In-app stand-in (tests / USE_MOCK_BACKEND). Free plan; trial turns on Pro.
/// Limits are enforced by the real server only.
class MockSubscriptionRepository implements SubscriptionRepository {
  MockSubscriptionRepository({this.pro = false});

  /// Premium (tests); the trial also turns it on.
  bool pro;
  bool _trialUsed = false;

  /// Today's usage shown by the mock (tests).
  int setsUsedToday = 0;
  int aiSetsUsedToday = 0;

  static const offers = [
    PlanOffer(id: 'pro_monthly', months: 1, priceInr: 99),
    PlanOffer(id: 'pro_quarterly', months: 3, priceInr: 249),
    PlanOffer(id: 'pro_yearly', months: 12, priceInr: 499, popular: true),
  ];

  SubscriptionStatus _status() {
    final now = DateTime.now();
    return SubscriptionStatus(
      isPro: pro,
      source: pro ? 'trial' : null,
      expiresAt: pro ? now.add(const Duration(days: 7)) : null,
      trialAvailable: !pro && !_trialUsed,
      trialDays: 7,
      limits: pro
          ? const PlanLimits(
              maxQuestionsPerSet: 40,
              questionsPerDay: 300,
              freshAi: true,
              customCount: true,
            )
          : const PlanLimits(
              maxQuestionsPerSet: 10,
              setsPerDay: 2,
              aiSetsPerDay: 1,
              maxSaved: 10,
              freshAi: true,
            ),
      setsUsedToday: setsUsedToday,
      aiSetsUsedToday: aiSetsUsedToday,
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
    pro = true;
    _trialUsed = true;
    return _status();
  }
}
