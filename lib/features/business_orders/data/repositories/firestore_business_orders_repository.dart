import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_orders/data/repositories/business_orders_error_mapper.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/orders/data/models/order_model.dart';
import 'package:sokosafi/features/orders/data/models/pickup_code.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

class FirestoreBusinessOrdersRepository implements BusinessOrdersRepository {
  FirestoreBusinessOrdersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 20);
  static const String _codePrefix = 'SKS-';

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');
  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  @override
  Stream<List<BusinessOrder>> watchOrders(String businessId) {
    return _orders
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap(
          (snapshot) => _withListingTitles(
            snapshot.docs.map(OrderModel.fromSnapshot).toList(),
          ),
        )
        .handleError((Object error) => throw toBusinessOrdersFailure(error));
  }

  @override
  Future<void> confirmPickup({
    required String businessId,
    required String pickupCode,
  }) async {
    final code = _normalise(pickupCode);
    if (!PickupCode.pattern.hasMatch(code)) {
      throw const BusinessOrdersFailure('Enter a code like SKS-4A7F2B');
    }
    try {
      // Transactions can only read documents by id, so the order is found
      // with a query first. Searching only this business's orders means a
      // code from another business is never accepted.
      final matches = await _orders
          .where('businessId', isEqualTo: businessId)
          .where('pickupCode', isEqualTo: code)
          .limit(1)
          .get()
          .timeout(_timeout);
      if (matches.docs.isEmpty) {
        throw const BusinessOrdersFailure(
          'No order with this code at your business',
        );
      }
      final orderRef = matches.docs.first.reference;

      // The status is checked again inside the transaction, so if the same
      // code is scanned twice at once, only one scan marks it collected.
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(orderRef);
        final order = OrderModel.fromSnapshot(snapshot);
        if (order.status == OrderStatus.collected) {
          throw const BusinessOrdersFailure('This order was already picked up');
        }
        if (order.status == OrderStatus.cancelled) {
          throw const BusinessOrdersFailure(
            'This order was cancelled by the customer',
          );
        }
        transaction.update(orderRef, {
          'status': OrderStatus.collected.name,
          'collectedAt': FieldValue.serverTimestamp(),
        });
      }, timeout: _timeout);
    } catch (error) {
      throw toBusinessOrdersFailure(error);
    }
  }

  /// Accepts "sks-4a7f2b" or just "4A7F2B" as well as "SKS-4A7F2B".
  String _normalise(String typedCode) {
    final upper = typedCode.trim().toUpperCase();
    return upper.startsWith(_codePrefix) ? upper : '$_codePrefix$upper';
  }

  Future<List<BusinessOrder>> _withListingTitles(
    List<CustomerOrder> orders,
  ) async {
    final listingIds = orders
        .map((order) => order.listingId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final snapshots = await Future.wait(
      listingIds.map((id) => _listings.doc(id).get().timeout(_timeout)),
    );
    final titles = {
      for (final snapshot in snapshots)
        if (snapshot.exists)
          snapshot.id: (snapshot.data() ?? const <String, dynamic>{})
              .readString('title'),
    };
    return [
      for (final order in orders)
        BusinessOrder(
          order: order,
          listingTitle: titles[order.listingId] ?? '',
        ),
    ];
  }
}
