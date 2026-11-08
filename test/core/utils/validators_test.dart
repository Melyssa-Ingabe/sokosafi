import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects a blank email', () {
      expect(Validators.email('   '), isNotNull);
    });

    test('rejects an email without a domain', () {
      expect(Validators.email('melyssa@'), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.email('melyssa@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects a password shorter than 8 characters', () {
      expect(Validators.password('abc123'), isNotNull);
    });

    test('accepts a password of 8 characters', () {
      expect(Validators.password('abcd1234'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a password that does not match', () {
      expect(Validators.confirmPassword('abcd1234', 'abcd12345'), isNotNull);
    });

    test('accepts a matching password', () {
      expect(Validators.confirmPassword('abcd1234', 'abcd1234'), isNull);
    });
  });

  group('Validators.phone', () {
    test('accepts a local and an international Rwandan number', () {
      expect(Validators.phone('0788 123 456'), isNull);
      expect(Validators.phone('+250788123456'), isNull);
    });

    test('rejects a number that is too short', () {
      expect(Validators.phone('12345'), isNotNull);
    });
  });
}
