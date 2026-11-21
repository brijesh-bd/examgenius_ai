// Contract test: the app's REAL repositories against a running backend.
// Proves the JSON the server sends parses into the app's models.
//
//   1. cd ../examgenius_backend && npm start
//   2. flutter test test/backend_contract_test.dart
//
// Skipped automatically when the server is not reachable. Uses
// API_CONTRACT_URL (default http://127.0.0.1:3000/api/v1).

import 'dart:io';

import 'package:examgenius_ai/core/network/api_client.dart';
import 'package:examgenius_ai/core/network/token_store.dart';
import 'package:examgenius_ai/features/authentication/data/api_auth_repository.dart';
import 'package:examgenius_ai/features/authentication/domain/student_user.dart';
import 'package:examgenius_ai/features/dashboard/data/api_dashboard_repository.dart';
import 'package:examgenius_ai/features/practice_test/data/api_practice_repository.dart';
import 'package:examgenius_ai/features/practice_test/data/api_saved_practice_repository.dart';
import 'package:examgenius_ai/features/practice_test/domain/practice_result.dart';
import 'package:examgenius_ai/features/question_generator/data/api_syllabus_repository.dart';
import 'package:examgenius_ai/features/question_generator/domain/generated_question.dart';
import 'package:examgenius_ai/features/subscription/data/subscription_repositories.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

const _base = String.fromEnvironment('API_CONTRACT_URL', defaultValue: 'http://127.0.0.1:3000/api/v1');

Future<bool> _serverUp() async {
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    final req = await client.getUrl(Uri.parse('$_base/health'));
    final res = await req.close();
    client.close(force: true);
    return res.statusCode == 200;
  } on Object {
    return false;
  }
}

void main() {
  late bool up;
  late TokenStore tokens;
  late ApiClient api;
  late ApiAuthRepository auth;

  setUpAll(() async {
    up = await _serverUp();
    if (!up) return;
    SharedPreferences.setMockInitialValues({});
    // No device keystore in a host test: TokenStore falls back to memory.
    tokens = TokenStore(const FlutterSecureStorage());
    api = ApiClient.create(tokens, baseUrl: _base);
    auth = ApiAuthRepository(api, tokens, await SharedPreferences.getInstance());
  });

  test('full student journey against the real backend', () async {
    if (!up) {
      markTestSkipped('Backend not running at $_base');
      return;
    }
    // Unique mobile per run (starts with 7, 10 digits).
    final mobile = '7${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final user = await auth.register(RegisterRequest(
      name: 'Contract Test',
      mobile: mobile,
      password: 'password123',
      targetExamId: 'rrb_ntpc',
      email: 'ct$mobile@example.com',
    ));
    expect(user.mobile, mobile);
    expect(tokens.hasToken, isTrue);
    expect(auth.currentUser()?.id, user.id);

    await expectLater(
      auth.register(RegisterRequest(name: 'Dup', mobile: mobile, password: 'password123', targetExamId: 'rrb_ntpc')),
      throwsA(isA<AuthFailure>().having((f) => f.kind, 'kind', AuthFailureKind.mobileTaken)),
    );
    await expectLater(
      auth.login(identifier: mobile, password: 'wrongpass1'),
      throwsA(isA<AuthFailure>().having((f) => f.kind, 'kind', AuthFailureKind.invalidCredentials)),
    );
    final byEmail = await auth.login(identifier: 'ct$mobile@example.com', password: 'password123', rememberMe: false);
    expect(byEmail.id, user.id);
    await auth.requestPasswordReset(mobile);

    final catalog = await ApiDashboardRepository(api).fetchExamCatalog();
    expect(catalog.map((c) => c.id), containsAll(['railway', 'ssc', 'banking']));
    final summary = await ApiDashboardRepository(api).fetchSummary(user.id);
    expect(summary.testsTaken, 0);

    final syllabus = await ApiSyllabusRepository(api).fetchSyllabus('rrb_ntpc');
    final topic = syllabus.subjects.first.topics.first;

    final practice = ApiPracticeRepository(api, language: () => 'en');
    final session = await practice.startSession(GenerationRequest(
      examId: 'rrb_ntpc',
      examName: 'RRB NTPC',
      topicIds: [topic.id],
      difficulty: Difficulty.easy,
      count: 2,
    ));
    expect(session.questions, isNotEmpty);
    expect(session.timeLimit, isNotNull);

    final q = session.questions.first;
    final result = await practice.submit(PracticeSubmission(
      sessionId: session.sessionId,
      answers: {q.id: 0},
      timeTaken: const Duration(seconds: 42),
      autoSubmitted: false,
    ));
    expect(result.total, session.questions.length);
    expect(result.correct + result.incorrect, 1);
    expect(result.reviews.first.selectedIndex, 0);
    expect(result.timeTaken, const Duration(seconds: 42));
    expect(result.topicStats, isNotEmpty);

    final retry = await practice.retrySession(result, [q.id]);
    expect(retry.questions.single.text, q.text);
    expect(retry.sessionId, isNot(session.sessionId));

    final saved = ApiSavedPracticeRepository(api);
    final s = await saved.save(result);
    expect(saved.isSaved(result.resultId), isTrue);
    final list = await saved.list();
    expect(list.map((e) => e.result.resultId), contains(result.resultId));
    expect(list.first.result.reviews, isNotEmpty);
    await saved.delete(s.id);
    expect(saved.isSaved(result.resultId), isFalse);

    // Free / Pro: one set used today, trial unlocks Pro.
    final subs = ApiSubscriptionRepository(api);
    final plan = await subs.fetchStatus();
    expect(plan.isPro, isFalse);
    expect(plan.setsUsedToday, 1);
    expect(plan.offers, isNotEmpty);
    final trial = await subs.startTrial();
    expect(trial.isTrial, isTrue);
    expect(trial.limits.maxQuestionsPerSet, greaterThan(10));

    await auth.logout();
    expect(tokens.hasToken, isFalse);
    await expectLater(
      ApiDashboardRepository(api).fetchSummary(user.id),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
  }, timeout: const Timeout(Duration(minutes: 5)));
}
