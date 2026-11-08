import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:sokosafi/features/auth/domain/failures/auth_failure.dart';

void main() {
  group('authErrorMessage', () {
    test('uses one message for wrong password and invalid credential', () {
      expect(
        authErrorMessage('wrong-password'),
        'Wrong email or password, try again',
      );
      expect(
        authErrorMessage('invalid-credential'),
        'Wrong email or password, try again',
      );
    });

    test('explains that the email is already registered', () {
      expect(
        authErrorMessage('email-already-in-use'),
        'This email is already registered',
      );
    });

    test('explains a network failure', () {
      expect(
        authErrorMessage('network-request-failed'),
        'No internet connection. Check your network and try again',
      );
    });

    test('never exposes an unknown code', () {
      expect(authErrorMessage('some-new-code'), AuthFailure.genericMessage);
    });
  });
}
