import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';
import 'package:sokosafi/features/business_settings/domain/failures/business_settings_failure.dart';
import 'package:sokosafi/features/business_settings/domain/repositories/business_settings_repository.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';

class FirestoreBusinessSettingsRepository
    implements BusinessSettingsRepository {
  FirestoreBusinessSettingsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 20);

  // Same defaults business setup writes, for documents missing a field.
  static const String _defaultPickupStart = '08:00';
  static const String _defaultPickupEnd = '20:00';

  DocumentReference<Map<String, dynamic>> _business(String businessId) =>
      _firestore.collection('businesses').doc(businessId);

  @override
  Stream<BusinessSettings> watchSettings(String businessId) {
    return _business(businessId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (data == null) {
            throw const BusinessSettingsFailure(
              'We could not find your business',
            );
          }
          final pickupStart = data.readString('pickupStart');
          final pickupEnd = data.readString('pickupEnd');
          return BusinessSettings(
            acceptingOrders: data['acceptingOrders'] as bool? ?? true,
            autoClose: data['autoClose'] as bool? ?? false,
            pickupStart: pickupStart.isEmpty
                ? _defaultPickupStart
                : pickupStart,
            pickupEnd: pickupEnd.isEmpty ? _defaultPickupEnd : pickupEnd,
            // Businesses created before landmark existed have no such field.
            landmark: data.readString('landmark'),
          );
        })
        .handleError((Object error) => throw _toFailure(error));
  }

  @override
  Future<String> loadOwnerPhone(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(ownerId)
          .get()
          .timeout(_timeout);
      return (snapshot.data() ?? const <String, dynamic>{}).readString('phone');
    } catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> updateSettings(
    String businessId, {
    bool? acceptingOrders,
    bool? autoClose,
    String? pickupStart,
    String? pickupEnd,
    String? landmark,
  }) async {
    // A '?' before a value leaves that entry out when the value is null,
    // so only the fields the owner changed are written.
    final changes = <String, Object>{
      'acceptingOrders': ?acceptingOrders,
      'autoClose': ?autoClose,
      'pickupStart': ?pickupStart,
      'pickupEnd': ?pickupEnd,
      if (landmark != null) 'landmark': landmark.trim(),
    };
    if (changes.isEmpty) return;
    try {
      await _business(businessId).update(changes).timeout(_timeout);
    } catch (error) {
      throw _toFailure(error);
    }
  }

  BusinessSettingsFailure _toFailure(Object error) {
    if (error is BusinessSettingsFailure) return error;
    if (error is TimeoutException) {
      return const BusinessSettingsFailure(
        'This is taking too long. Check your connection and try again',
      );
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const BusinessSettingsFailure(
            'You can only change settings for your own business',
          );
        case 'unavailable':
        case 'deadline-exceeded':
          return const BusinessSettingsFailure(
            'You seem to be offline. Check your connection and try again',
          );
      }
    }
    return const BusinessSettingsFailure(
      BusinessSettingsFailure.genericMessage,
    );
  }
}
