import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

abstract final class OrderModel {
  static CustomerOrder fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return CustomerOrder(
      id: doc.id,
      customerId: data.readString('customerId'),
      businessId: data.readString('businessId'),
      listingId: data.readString('listingId'),
      quantity: data.readInt('quantity'),
      total: data.readNum('total'),
      pickupCode: data.readString('pickupCode'),
      paymentMethod: PaymentMethod.fromName(data.readString('paymentMethod')),
      status: OrderStatus.fromName(data.readString('status')),
      // The server timestamp is null until the write is confirmed.
      createdAt: data.readDate('createdAt') ?? DateTime.now(),
      collectedAt: data.readDate('collectedAt'),
    );
  }

  /// Fields of a new order. They match the ERD; the id is the document id.
  static Map<String, dynamic> newOrderMap({
    required String customerId,
    required String businessId,
    required String listingId,
    required int quantity,
    required num total,
    required String pickupCode,
    required PaymentMethod paymentMethod,
  }) {
    return {
      'customerId': customerId,
      'businessId': businessId,
      'listingId': listingId,
      'quantity': quantity,
      'total': total,
      'pickupCode': pickupCode,
      'paymentMethod': paymentMethod.name,
      'status': OrderStatus.paid.name,
      'createdAt': FieldValue.serverTimestamp(),
      'collectedAt': null,
    };
  }
}
