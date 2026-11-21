import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/token_store.dart';
import '../domain/auth_repository.dart';
import '../domain/student_user.dart';

/// Real backend auth (`/api/v1/auth/*`). The JWT lives in [TokenStore]
/// (secure storage when remembered); only the non-sensitive profile is cached
/// in SharedPreferences so the app can open straight to Home.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._api, this._tokens, this._prefs);

  final ApiClient _api;
  final TokenStore _tokens;
  final SharedPreferences _prefs;

  @override
  StudentUser? currentUser() {
    if (!_tokens.hasToken) return null;
    final raw = _prefs.getString(PrefKeys.sessionUser);
    if (raw == null) return null;
    try {
      return StudentUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  @override
  Future<StudentUser> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
  }) => _authenticate(
    () => _api.post('/auth/login', {
      'identifier': identifier,
      'password': password,
    }),
    remember: rememberMe,
  );

  @override
  Future<StudentUser> register(RegisterRequest request) => _authenticate(
    () => _api.post('/auth/register', {
      'name': request.name.trim(),
      'mobile': request.mobile,
      'email': (request.email?.trim().isEmpty ?? true)
          ? null
          : request.email!.trim(),
      'password': request.password,
      'targetExamId': request.targetExamId,
    }),
    remember: true,
  );

  @override
  Future<void> requestPasswordReset(String identifier) async {
    try {
      await _api.post('/auth/forgot-password', {'identifier': identifier});
    } on ApiException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    await _tokens.clear();
    await _prefs.remove(PrefKeys.sessionUser);
  }

  Future<StudentUser> _authenticate(
    Future<Map<String, dynamic>> Function() call, {
    required bool remember,
  }) async {
    final Map<String, dynamic> body;
    try {
      body = await call();
    } on ApiException catch (e) {
      throw _toFailure(e);
    }
    final user = StudentUser.fromJson(body['user'] as Map<String, dynamic>);
    await _tokens.save(body['token'] as String, remember: remember);
    if (remember) {
      await _prefs.setString(PrefKeys.sessionUser, jsonEncode(user.toJson()));
    } else {
      await _prefs.remove(PrefKeys.sessionUser);
    }
    return user;
  }

  AuthFailure _toFailure(ApiException e) {
    if (e.isNetwork) return const AuthFailure(AuthFailureKind.network);
    if (e.statusCode == 401) {
      return const AuthFailure(AuthFailureKind.invalidCredentials);
    }
    if (e.statusCode == 409) {
      return AuthFailure(
        e.message.toLowerCase().contains('email')
            ? AuthFailureKind.emailTaken
            : AuthFailureKind.mobileTaken,
      );
    }
    return const AuthFailure(AuthFailureKind.unknown);
  }
}
