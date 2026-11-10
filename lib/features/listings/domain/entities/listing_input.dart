import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// The fields a business fills in when creating or editing a listing. The
/// id, status and createdAt are decided by the repository, not the form.
class ListingInput extends Equatable {
  const ListingInput({
    required this.title,
    required this.description,
    required this.category,
    required this.originalPrice,
    required this.discountPrice,
    required this.quantity,
    required this.madeAt,
    required this.pickupBy,
    required this.instructions,
    this.imageUrl = '',
  });

  final String title;
  final String description;
  final ListingCategory category;
  final int originalPrice;
  final int discountPrice;
  final int quantity;
  final DateTime madeAt;
  final DateTime pickupBy;
  final String instructions;
  final String imageUrl;

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    originalPrice,
    discountPrice,
    quantity,
    madeAt,
    pickupBy,
    instructions,
    imageUrl,
  ];
}
