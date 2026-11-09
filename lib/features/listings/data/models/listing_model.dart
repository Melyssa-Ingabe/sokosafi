import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// Maps listings documents to [Listing]. Field names match the ERD exactly;
/// the listingId is the document id, not a field.
class ListingModel extends Listing {
  const ListingModel({
    required super.id,
    required super.businessId,
    required super.title,
    required super.description,
    required super.category,
    required super.originalPrice,
    required super.discountPrice,
    required super.quantity,
    required super.madeAt,
    required super.pickupBy,
    required super.imageUrl,
    required super.instructions,
    required super.status,
    required super.createdAt,
  });

  factory ListingModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    // createdAt is a server timestamp, so it is null in the local copy
    // until the write reaches Firestore.
    final createdAt = _readDate(data['createdAt']) ?? DateTime.now();
    return ListingModel(
      id: snapshot.id,
      businessId: data['businessId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: ListingCategory.fromName(data['category'] as String?),
      originalPrice: (data['originalPrice'] as num?)?.round() ?? 0,
      discountPrice: (data['discountPrice'] as num?)?.round() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      madeAt: _readDate(data['madeAt']) ?? createdAt,
      pickupBy: _readDate(data['pickupBy']) ?? createdAt,
      imageUrl: data['imageUrl'] as String? ?? '',
      instructions: data['instructions'] as String? ?? '',
      status: ListingStatus.fromName(data['status'] as String?),
      createdAt: createdAt,
    );
  }

  /// Fields written for a brand-new listing.
  static Map<String, dynamic> createMap({
    required String businessId,
    required ListingInput input,
  }) {
    return {
      'businessId': businessId,
      ...editableFields(input),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Fields the owner may change when editing. businessId and createdAt are
  /// left out so an edit can never move a listing to another business.
  static Map<String, dynamic> editableFields(ListingInput input) {
    return {
      'title': input.title.trim(),
      'description': input.description.trim(),
      'category': input.category.name,
      'originalPrice': input.originalPrice,
      'discountPrice': input.discountPrice,
      'quantity': input.quantity,
      'madeAt': Timestamp.fromDate(input.madeAt),
      'pickupBy': Timestamp.fromDate(input.pickupBy),
      'imageUrl': input.imageUrl,
      'instructions': input.instructions.trim(),
      'status': ListingStatus.forQuantity(input.quantity).name,
    };
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
