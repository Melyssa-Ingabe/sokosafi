import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_orders/data/repositories/business_orders_error_mapper.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/orders/data/models/order_listing_model.dart';
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

  @override
  Future<void> cancelOrder({
    required String businessId,
    required String orderId,
  }) async {
    try {
      final orderRef = _orders.doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final orderSnapshot = await transaction.get(orderRef);
        if (!orderSnapshot.exists) {
          throw const BusinessOrdersFailure('We could not find that order');
        }
        final order = OrderModel.fromSnapshot(orderSnapshot);
        if (order.businessId != businessId) {
          throw const BusinessOrdersFailure('This order is not for your shop');
        }
        if (order.status == OrderStatus.collected) {
          throw const BusinessOrdersFailure('This order was already picked up');
        }
        if (order.status == OrderStatus.cancelled) {
          throw const BusinessOrdersFailure('This order is already cancelled');
        }
        // Every read must happen before the first write in a transaction.
        final listingRef = _listings.doc(order.listingId);
        final listingSnapshot = await transaction.get(listingRef);

        transaction.update(orderRef, {'status': OrderStatus.cancelled.name});
        if (!listingSnapshot.exists) return;
        final listing = OrderListingModel.fromSnapshot(listingSnapshot);
        final wasSoldOut =
            listingSnapshot.data()?['status'] ==
            OrderListingModel.soldOutStatus;
        transaction.update(listingRef, {
          'quantity': listing.quantityLeft + order.quantity,
          if (wasSoldOut && listing.pickupBy.isAfter(DateTime.now()))
            'status': OrderListingModel.activeStatus,
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
        .toSet()
        .toList();
    final snapshots = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < listingIds.length; i += 10) {
      final batch = listingIds.sublist(
        i,
        i + 10 > listingIds.length ? listingIds.length : i + 10,
      );
      final result = await _listings
          .where(FieldPath.documentId, whereIn: batch)
          .get()
          .timeout(_timeout);
      snapshots.addAll(result.docs);
    }
    final titles = {
      for (final snapshot in snapshots)
        if (snapshot.exists) snapshot.id: snapshot.data().readString('title'),
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
