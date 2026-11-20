import 'package:equatable/equatable.dart';

enum MobileMoneyProvider {
  mtn('MTN Mobile Money'),
  airtel('Airtel Money');

  const MobileMoneyProvider(this.label);

  final String label;
}

/// Where the business is paid: the owner's own phone number from users.
/// Nothing extra is stored; the provider is worked out from the number.
class PayoutAccount extends Equatable {
  const PayoutAccount({required this.provider, required this.maskedNumber});

  factory PayoutAccount.fromPhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('250')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);

    final provider = switch (digits.length >= 2 ? digits.substring(0, 2) : '') {
      '78' || '79' => MobileMoneyProvider.mtn,
      '72' || '73' => MobileMoneyProvider.airtel,
      _ => null,
    };
    // Only part of the number is shown, like a bank card.
    final maskedNumber = digits.length == 9
        ? '+250 ${digits.substring(0, 3)} ••• ${digits.substring(6)}'
        : phone.trim();
    return PayoutAccount(provider: provider, maskedNumber: maskedNumber);
  }

  /// Null when the number does not belong to a known provider.
  final MobileMoneyProvider? provider;

  /// Empty when the owner has no phone number saved.
  final String maskedNumber;

  @override
  List<Object?> get props => [provider, maskedNumber];
}
