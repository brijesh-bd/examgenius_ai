import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../data/mock_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/student_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(ref.watch(sharedPreferencesProvider)),
);

/// Current session. `null` = logged out. Router redirects listen to this.
class SessionController extends Notifier<StudentUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  StudentUser? build() => ref.read(authRepositoryProvider).currentUser();

  Future<void> login(String identifier, String password, {bool rememberMe = true}) async {
    state = await _repo.login(
        identifier: identifier, password: password, rememberMe: rememberMe);
  }

  Future<void> register(RegisterRequest request) async {
    state = await _repo.register(request);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = null;
  }
}

final sessionProvider =
    NotifierProvider<SessionController, StudentUser?>(SessionController.new);

/// Submission status for auth forms (keeps loading/error out of widgets).
class AuthFormController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> login(String identifier, String password, {bool rememberMe = true}) =>
      _run(() => ref
          .read(sessionProvider.notifier)
          .login(identifier, password, rememberMe: rememberMe));

  Future<bool> register(RegisterRequest request) =>
      _run(() => ref.read(sessionProvider.notifier).register(request));

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authFormProvider =
    NotifierProvider.autoDispose<AuthFormController, AsyncValue<void>>(
  AuthFormController.new,
);

/// Forgot-password request. `AsyncData(null)` = form, `AsyncData(target)` =
/// instructions sent to `target`, plus loading / error.
class ForgotPasswordController extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  Future<void> send(String identifier) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).requestPasswordReset(identifier);
      return identifier;
    });
  }

  /// Back to the form (e.g. to change the address).
  void reset() => state = const AsyncData(null);
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, AsyncValue<String?>>(
  ForgotPasswordController.new,
);
