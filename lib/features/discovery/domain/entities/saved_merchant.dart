import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';

/// A business the customer saved, from users/{uid}/savedMerchants. Only
/// savedAt is stored there; the business itself is read from businesses.
class SavedMerchant extends Equatable {
  const SavedMerchant({required this.business, required this.savedAt});

  final Business business;
  final DateTime savedAt;

  @override
  List<Object?> get props => [business, savedAt];
}
