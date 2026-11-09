import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';

/// Maps businesses documents to [Business]. Field names match the ERD
/// exactly; the businessId is the document id, not a field.
class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.type,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.photoUrl,
    required super.acceptingOrders,
    required super.pickupStart,
    required super.pickupEnd,
    required super.autoClose,
    required super.createdAt,
  });

  static const String defaultPickupStart = '08:00';
  static const String defaultPickupEnd = '20:00';

  factory BusinessModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return BusinessModel(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: BusinessType.fromName(data['type'] as String?),
      address: data['address'] as String? ?? '',
      latitude: (data['lat'] as num?)?.toDouble() ?? 0,
      longitude: (data['lng'] as num?)?.toDouble() ?? 0,
      photoUrl: data['photoUrl'] as String? ?? '',
      acceptingOrders: data['acceptingOrders'] as bool? ?? true,
      pickupStart: data['pickupStart'] as String? ?? defaultPickupStart,
      pickupEnd: data['pickupEnd'] as String? ?? defaultPickupEnd,
      autoClose: data['autoClose'] as bool? ?? false,
      // createdAt is a server timestamp, so it is null in the local copy
      // until the write reaches Firestore.
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  /// Fields of a new businesses document, with the settings at their
  /// defaults.
  static Map<String, dynamic> createMap({
    required String ownerId,
    required BusinessSetupInput input,
  }) {
    return {
      'ownerId': ownerId,
      'name': input.name.trim(),
      'type': input.type.name,
      'address': input.address.trim(),
      'lat': input.latitude,
      'lng': input.longitude,
      'photoUrl': input.photoUrl,
      'acceptingOrders': true,
      'pickupStart': defaultPickupStart,
      'pickupEnd': defaultPickupEnd,
      'autoClose': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
