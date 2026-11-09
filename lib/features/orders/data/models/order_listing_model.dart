import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/orders/domain/entities/order_listing.dart';

/// Reads the parts of a listings document that orders need.
abstract final class OrderListingModel {
  static const String activeStatus = 'active';
  static const String soldOutStatus = 'sold out';

  static OrderListing fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OrderListing(
      id: doc.id,
      businessId: data.readString('businessId'),
      title: data.readString('title'),
      imageUrl: data.readString('imageUrl'),
      originalPrice: data.readNum('originalPrice'),
      discountPrice: data.readNum('discountPrice'),
      quantityLeft: data.readInt('quantity'),
      pickupBy:
          data.readDate('pickupBy') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isActive: data.readString('status') == activeStatus,
    );
  }
}
