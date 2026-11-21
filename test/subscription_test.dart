import 'package:examgenius_ai/core/network/api_client.dart';
import 'package:examgenius_ai/features/subscription/data/subscription_repositories.dart';
import 'package:examgenius_ai/features/subscription/domain/subscription_models.dart';
import 'package:examgenius_ai/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:examgenius_ai/features/subscription/presentation/screens/plans_screen.dart';
import 'package:examgenius_ai/features/subscription/presentation/widgets/upgrade_sheet.dart';
import 'package:examgenius_ai/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:examgenius_ai/core/services/preferences_service.dart';

late SharedPreferences _prefs;

Widget _app(Widget home, {SubscriptionRepository? repo}) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        if (repo != null) subscriptionRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  test('status JSON from the server parses (free and pro)', () {
    final free = SubscriptionStatus.fromJson({
      'tier': 'free',
      'source': null,
      'expiresAt': null,
      'trialAvailable': true,
      'trialDays': 7,
      'limits': {'setsPerDay': 2, 'questionsPerDay': null, 'maxQuestionsPerSet': 10, 'maxSaved': 10, 'freshAi': false},
      'usageToday': {'sets': 1, 'questions': 5},
      'resetsAt': '2026-11-21T18:30:00.000Z',
      'offers': [
        {'id': 'pro_monthly', 'months': 1, 'priceInr': 99},
        {'id': 'pro_yearly', 'months': 12, 'priceInr': 499, 'popular': true},
      ],
    });
    expect(free.isPro, isFalse);
    expect(free.setsLeftToday, 1);
    expect(free.offers.last.popular, isTrue);
    expect(free.offers.last.perMonthInr, 42);

    final pro = SubscriptionStatus.fromJson({
      'tier': 'pro',
      'source': 'trial',
      'expiresAt': '2026-11-28T10:00:00.000Z',
      'trialAvailable': false,
      'limits': {'questionsPerDay': 300, 'maxQuestionsPerSet': 30, 'freshAi': true},
      'usageToday': {'sets': 4, 'questions': 40},
      'resetsAt': '2026-11-21T18:30:00.000Z',
      'offers': <dynamic>[],
    });
    expect(pro.isTrial, isTrue);
    expect(pro.setsLeftToday, isNull);
  });

  test('server 403 codes map to plan limits; other errors do not', () {
    final hit = PlanLimitHit.from(const ApiException('x', statusCode: 403, code: 'DAILY_SETS',
        details: {'max': 2, 'resetsAt': '2026-11-21T18:30:00.000Z'}));
    expect(hit?.kind, PlanLimitKind.dailySets);
    expect(hit?.max, 2);
    expect(hit?.resetsAt, DateTime.utc(2026, 11, 21, 18, 30));
    expect(PlanLimitHit.from(const ApiException('x', statusCode: 403, code: 'SAVED_LIMIT'))?.kind,
        PlanLimitKind.savedLimit);
    expect(PlanLimitHit.from(const ApiException('x', statusCode: 503)), isNull);
    expect(PlanLimitHit.from(Exception('boom')), isNull);
  });

  testWidgets('plans screen: compare, yearly highlighted, trial turns on Pro', (tester) async {
    tester.view.physicalSize = const Size(390, 1400) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const PlansScreen(), repo: MockSubscriptionRepository()));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Free vs Pro'), findsOneWidget);
    expect(find.text('2 per day'), findsOneWidget);
    expect(find.text('₹499'), findsOneWidget);
    expect(find.text('Most Popular'), findsOneWidget);
    expect(find.text('Save 58%'), findsOneWidget); // yearly vs 12 × ₹99
    expect(find.text('Choose 12 Months'), findsOneWidget); // yearly preselected

    await tester.tap(find.text('3 Months'));
    await tester.pumpAndSettle();
    expect(find.text('Choose 3 Months'), findsOneWidget);

    await tester.tap(find.text('Start 7-day free trial'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pro trial has started'), findsOneWidget);
    expect(find.textContaining('Free trial until'), findsOneWidget);
    expect(find.text('Start 7-day free trial'), findsNothing);
  });

  testWidgets('upgrade prompt explains the limit and offers plans', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(
      body: UpgradePrompt(hit: PlanLimitHit(PlanLimitKind.dailySets, max: 2)),
    )));
    await tester.pumpAndSettle();
    expect(find.text("You have used today's free sets"), findsOneWidget);
    expect(find.textContaining('2 practice sets per day'), findsOneWidget);
    expect(find.text('See Pro plans'), findsOneWidget);

    // Pro fair-use cap: no upsell.
    await tester.pumpWidget(_app(const Scaffold(
      body: UpgradePrompt(hit: PlanLimitHit(PlanLimitKind.dailyQuestions, max: 300)),
    )));
    await tester.pumpAndSettle();
    expect(find.text('See Pro plans'), findsNothing);
  });
}
