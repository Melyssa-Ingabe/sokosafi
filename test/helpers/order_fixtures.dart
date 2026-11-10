import 'package:sokosafi/features/orders/domain/entities/checkout_item.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_business.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_listing.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

final DateTime fixtureNow = DateTime(2026, 11, 9, 17);

OrderListing breadListing({int quantityLeft = 3}) => OrderListing(
  id: 'bread',
  businessId: 'bakery',
  title: 'Fresh Artisan Breads',
  imageUrl: '',
  originalPrice: 1000,
  discountPrice: 600,
  quantityLeft: quantityLeft,
  pickupBy: fixtureNow.add(const Duration(hours: 2)),
  isActive: true,
);

const OrderBusiness bakery = OrderBusiness(
  id: 'bakery',
  name: 'Boulangerie de Kigali',
  address: 'KG 5 Ave, Kacyiru',
);

CheckoutItem breadCheckout({int quantityLeft = 3}) => CheckoutItem(
  listing: breadListing(quantityLeft: quantityLeft),
  business: bakery,
);

OrderDetails orderDetails({
  String id = 'order-1',
  OrderStatus status = OrderStatus.paid,
  int quantity = 2,
}) {
  return OrderDetails(
    order: CustomerOrder(
      id: id,
      customerId: 'customer-1',
      businessId: 'bakery',
      listingId: 'bread',
      quantity: quantity,
      total: 600 * quantity,
      pickupCode: 'SKS-4A7F2B',
      paymentMethod: PaymentMethod.mtnMomo,
      status: status,
      createdAt: fixtureNow,
    ),
    listing: breadListing(),
    business: bakery,
  );
}
