import 'package:examgenius_ai/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile validation', () {
    expect(Validators.mobile(''), ValidationError.required);
    expect(Validators.mobile('12345'), ValidationError.mobile);
    expect(Validators.mobile('5876543210'), ValidationError.mobile);
    expect(Validators.mobile('9876543210'), isNull);
  });

  test('password validation', () {
    expect(Validators.password('short'), ValidationError.password);
    expect(Validators.password('longenough'), isNull);
    expect(Validators.confirmPassword('a', 'b'), ValidationError.passwordMatch);
  });

  test('optional email', () {
    expect(Validators.optionalEmail(''), isNull);
    expect(Validators.optionalEmail('bad'), ValidationError.email);
    expect(Validators.optionalEmail('a@b.in'), isNull);
  });
}
