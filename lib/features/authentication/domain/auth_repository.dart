import 'student_user.dart';

/// Contract the UI depends on. Swap [MockAuthRepository] for an API-backed
/// implementation (Dio + JWT in secure storage) without touching screens.
abstract interface class AuthRepository {
  StudentUser? currentUser();
  /// [identifier] is a mobile number or an email. When [rememberMe] is false
  /// the session lives only in memory and is gone on the next app start.
  Future<StudentUser> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
  });
  Future<StudentUser> register(RegisterRequest request);

  /// Sends reset instructions to an email or mobile (`POST /api/v1/auth/forgot-password`).
  Future<void> requestPasswordReset(String identifier);
  Future<void> logout();
}
