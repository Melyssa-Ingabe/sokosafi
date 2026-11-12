import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_settings/domain/entities/payout_account.dart';

void main() {
  test('078 numbers are MTN and only part of the number is shown', () {
    final account = PayoutAccount.fromPhone('0788 123 192');

    expect(account.provider, MobileMoneyProvider.mtn);
    expect(account.maskedNumber, '+250 788 ••• 192');
  });

  test('+250 73 numbers are Airtel', () {
    final account = PayoutAccount.fromPhone('+250731234567');

    expect(account.provider, MobileMoneyProvider.airtel);
    expect(account.maskedNumber, '+250 731 ••• 567');
  });

  test('a missing phone gives no provider and an empty number', () {
    final account = PayoutAccount.fromPhone('');

    expect(account.provider, isNull);
    expect(account.maskedNumber, isEmpty);
  });
}
