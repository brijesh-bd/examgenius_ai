/// Authenticated student. JSON keys mirror the planned backend contract
/// (`{ id, name, mobile, email, targetExamId }`).
class StudentUser {
  const StudentUser({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.targetExamId = 'rrb_ntpc',
  });

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String targetExamId;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  factory StudentUser.fromJson(Map<String, dynamic> json) => StudentUser(
        id: json['id'] as String,
        name: json['name'] as String,
        mobile: json['mobile'] as String,
        email: json['email'] as String?,
        targetExamId: (json['targetExamId'] as String?) ?? 'rrb_ntpc',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'targetExamId': targetExamId,
      };
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.mobile,
    required this.password,
    required this.targetExamId,
    this.email,
  });

  final String name;
  final String mobile;
  final String password;
  final String targetExamId;
  final String? email;
}

/// Domain-level auth failure; UI maps [kind] to a localized message.
class AuthFailure implements Exception {
  const AuthFailure(this.kind);
  final AuthFailureKind kind;
}

enum AuthFailureKind { invalidCredentials, network, unknown }
