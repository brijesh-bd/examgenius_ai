/// Pure validation helpers. They return an error *key* so the UI layer can map
/// it to a localized message, keeping this file free of BuildContext.
enum ValidationError {
  required,
  mobile,
  emailOrMobile,
  password,
  passwordMatch,
  email,
  name,
  terms,
}

abstract final class Validators {
  static final _mobile = RegExp(r'^[6-9]\d{9}$');
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static ValidationError? mobile(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return ValidationError.required;
    if (!_mobile.hasMatch(value)) return ValidationError.mobile;
    return null;
  }

  /// Login identifier: a 10-digit Indian mobile or an email address.
  static ValidationError? emailOrMobile(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return ValidationError.required;
    if (value.contains('@')
        ? !_email.hasMatch(value)
        : !_mobile.hasMatch(value)) {
      return ValidationError.emailOrMobile;
    }
    return null;
  }

  static ValidationError? password(String? v) {
    if (v == null || v.isEmpty) return ValidationError.required;
    if (v.length < 8) return ValidationError.password;
    return null;
  }

  static ValidationError? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return ValidationError.required;
    if (v != original) return ValidationError.passwordMatch;
    return null;
  }

  static ValidationError? name(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return ValidationError.required;
    if (value.length < 2) return ValidationError.name;
    return null;
  }

  static ValidationError? optionalEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    if (!_email.hasMatch(value)) return ValidationError.email;
    return null;
  }
}
