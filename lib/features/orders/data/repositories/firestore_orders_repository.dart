import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/data/models/order_business_model.dart';
import 'package:sokosafi/features/orders/data/models/order_listing_model.dart';
import 'package:sokosafi/features/orders/data/models/order_model.dart';
import 'package:sokosafi/features/orders/data/models/pickup_code.dart';
import 'package:sokosafi/features/orders/data/repositories/orders_error_mapper.dart';
import 'package:sokosafi/features/orders/domain/entities/checkout_item.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_business.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_listing.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';

class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository({
    FirebaseFirestore? firestore,
    DateTime Function()? clock,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _clock = clock ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _clock;

  static const Duration _timeout = Duration(seconds: 20);
  static const OrdersFailure _unavailable = OrdersFailure(
    'This item is no longer available',
  );

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');
  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');
  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection('businesses');

  @override
  Future<CheckoutItem> loadCheckoutItem(String listingId) {
    return _guard(() async {
      final listing = await _readListing(listingId);
      if (listing == null) throw _unavailable;
      final business = await _readBusiness(listing.businessId);
      if (business == null) throw _unavailable;
      return CheckoutItem(listing: listing, business: business);
    });
  }

  @override
  Future<String> placeOrder({
    required String customerId,
    required String listingId,
    required int quantity,
    required PaymentMethod paymentMethod,
  }) {
    if (quantity < 1) {
      return Future.error(const OrdersFailure('Choose at least one item'));
    }
    return _guard(() async {
      final listingRef = _listings.doc(listingId);
      final orderRef = _orders.doc();

      // Reading the listing inside the transaction means two customers can
      // never buy the last item at the same time: Firestore retries the
      // slower one, which then sees the reduced quantity.
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(listingRef);
        if (!snapshot.exists) throw _unavailable;
        final listing = OrderListingModel.fromSnapshot(snapshot);
        if (!listing.isAvailableAt(_clock())) throw _unavailable;
        if (listing.quantityLeft < quantity) {
          throw OrdersFailure(
            'Only ${listing.quantityLeft} left. Lower the quantity',
          );
        }

        final remaining = listing.quantityLeft - quantity;
        transaction.update(listingRef, {
          'quantity': remaining,
          if (remaining == 0) 'status': OrderListingModel.soldOutStatus,
        });
        transaction.set(
          orderRef,
          OrderModel.newOrderMap(
            customerId: customerId,
            businessId: listing.businessId,
            listingId: listingId,
            quantity: quantity,
            total: listing.discountPrice * quantity,
            pickupCode: PickupCode.generate(),
            paymentMethod: paymentMethod,
          ),
        );
      }, timeout: _timeout);
      return orderRef.id;
    });
  }

  @override
  Stream<List<OrderDetails>> watchCustomerOrders(String customerId) {
    return _mapErrors(
      _orders
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .asyncMap(
            (snapshot) => _withDetails(
              snapshot.docs.map(OrderModel.fromSnapshot).toList(),
            ),
          ),
    );
  }

  @override
  Stream<OrderDetails> watchOrder(String orderId) {
    return _mapErrors(
      _orders.doc(orderId).snapshots().asyncMap((snapshot) async {
        if (!snapshot.exists) {
          throw const OrdersFailure('We could not find that order');
        }
        final details = await _withDetails([OrderModel.fromSnapshot(snapshot)]);
        return details.single;
      }),
    );
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return _guard(() async {
      final orderRef = _orders.doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final orderSnapshot = await transaction.get(orderRef);
        if (!orderSnapshot.exists) {
          throw const OrdersFailure('We could not find that order');
        }
        final order = OrderModel.fromSnapshot(orderSnapshot);
        if (order.status != OrderStatus.paid) {
          throw const OrdersFailure('Only active orders can be cancelled');
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
          if (wasSoldOut && listing.pickupBy.isAfter(_clock()))
            'status': OrderListingModel.activeStatus,
        });
      }, timeout: _timeout);
    });
  }

  Future<List<OrderDetails>> _withDetails(List<CustomerOrder> orders) async {
    final listingIds = orders.map((order) => order.listingId).toSet();
    final businessIds = orders.map((order) => order.businessId).toSet();
    final listings = await _readAll(listingIds, _readListing);
    final businesses = await _readAll(businessIds, _readBusiness);
    return [
      for (final order in orders)
        OrderDetails(
          order: order,
          listing: listings[order.listingId],
          business: businesses[order.businessId],
        ),
    ];
  }

  Future<Map<String, T>> _readAll<T>(
    Set<String> ids,
    Future<T?> Function(String id) read,
  ) async {
    final idList = ids.toList();
    final values = await Future.wait(idList.map(read));
    return {for (var i = 0; i < idList.length; i++) idList[i]: ?values[i]};
  }

  Future<OrderListing?> _readListing(String id) async {
    if (id.isEmpty) return null;
    final snapshot = await _listings.doc(id).get().timeout(_timeout);
    return snapshot.exists ? OrderListingModel.fromSnapshot(snapshot) : null;
  }

  Future<OrderBusiness?> _readBusiness(String id) async {
    if (id.isEmpty) return null;
    final snapshot = await _businesses.doc(id).get().timeout(_timeout);
    return snapshot.exists ? OrderBusinessModel.fromSnapshot(snapshot) : null;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw toOrdersFailure(error);
    }
  }

  Stream<T> _mapErrors<T>(Stream<T> source) {
    return source.transform(
      StreamTransformer<T, T>.fromHandlers(
        handleError: (error, stackTrace, sink) =>
            sink.addError(toOrdersFailure(error), stackTrace),
      ),
    );
  }
}
