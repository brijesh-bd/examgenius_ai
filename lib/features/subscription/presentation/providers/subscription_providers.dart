import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/subscription_repositories.dart';
import '../../domain/subscription_models.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  if (ref.watch(useMockBackendProvider)) return MockSubscriptionRepository();
  return ApiSubscriptionRepository(ref.watch(apiClientProvider));
});

/// Current plan + today's usage. Refreshed after generating, saving or
/// starting the trial; reloads when the logged-in user changes.
class SubscriptionController extends AsyncNotifier<SubscriptionStatus> {
  @override
  Future<SubscriptionStatus> build() {
    ref.watch(sessionProvider.select((u) => u?.id)); // new user → reload
    return ref.read(subscriptionRepositoryProvider).fetchStatus();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(subscriptionRepositoryProvider).fetchStatus(),
    );
  }

  /// Returns true when the trial started.
  /// The current plan stays visible meanwhile; the screen shows its own spinner.
  Future<bool> startTrial() async {
    final next = await AsyncValue.guard(
      () => ref.read(subscriptionRepositoryProvider).startTrial(),
    );
    if (next.hasError) return false; // caller shows the error
    state = next;
    return true;
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionController, SubscriptionStatus>(
      SubscriptionController.new,
    );
