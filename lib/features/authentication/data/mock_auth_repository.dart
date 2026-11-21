import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/auth_repository.dart';
import '../domain/student_user.dart';

/// UI-phase stand-in for the backend. Any valid mobile + password of 8+ chars
/// logs in, except password `wrongpass` which simulates bad credentials.
/// Stores only the non-sensitive profile, never the password.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _latency = Duration(milliseconds: 900);

  @override
  StudentUser? currentUser() {
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
  }) async {
    await Future<void>.delayed(_latency);
    if (password == 'wrongpass') {
      throw const AuthFailure(AuthFailureKind.invalidCredentials);
    }
    final isEmail = identifier.contains('@');
    final user = StudentUser(
      id: 'stu_$identifier',
      name: 'Aspirant',
      mobile: isEmail ? '' : identifier,
      email: isEmail ? identifier : null,
    );
    if (rememberMe) {
      await _save(user);
    } else {
      await _prefs.remove(PrefKeys.sessionUser);
    }
    return user;
  }

  @override
  Future<StudentUser> register(RegisterRequest request) async {
    await Future<void>.delayed(_latency);
    final user = StudentUser(
      id: 'stu_${request.mobile}',
      name: request.name.trim(),
      mobile: request.mobile,
      email: request.email,
      targetExamId: request.targetExamId,
    );
    await _save(user);
    return user;
  }

  @override
  Future<void> requestPasswordReset(String identifier) =>
      Future<void>.delayed(_latency); // mock: always "sent"

  @override
  Future<void> logout() => _prefs.remove(PrefKeys.sessionUser);

  Future<void> _save(StudentUser user) =>
      _prefs.setString(PrefKeys.sessionUser, jsonEncode(user.toJson()));
}
