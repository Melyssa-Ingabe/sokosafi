import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

void main() {
  final now = DateTime(2026, 11, 11, 15);
  final yesterday = now.subtract(const Duration(days: 1));

  Listing listing({
    String id = 'bread',
    int quantity = 14,
    ListingStatus status = ListingStatus.active,
    DateTime? pickupBy,
  }) {
    return Listing(
      id: id,
      businessId: 'bakery',
      title: 'Fresh breads',
      description: '',
      category: ListingCategory.bakery,
      originalPrice: 1000,
      discountPrice: 600,
      quantity: quantity,
      madeAt: now.subtract(const Duration(hours: 3)),
      pickupBy: pickupBy ?? now.add(const Duration(hours: 2)),
      imageUrl: '',
      instructions: '',
      status: status,
      createdAt: now.subtract(const Duration(hours: 3)),
    );
  }

  BusinessOrder order({
    required String id,
    OrderStatus status = OrderStatus.paid,
    int quantity = 1,
    num total = 600,
    DateTime? createdAt,
  }) {
    return BusinessOrder(
      order: CustomerOrder(
        id: id,
        customerId: 'customer-1',
        businessId: 'bakery',
        listingId: 'bread',
        quantity: quantity,
        total: total,
        pickupCode: 'SKS-4A7F2B',
        paymentMethod: PaymentMethod.mtnMomo,
        status: status,
        createdAt: createdAt ?? now,
      ),
      listingTitle: 'Fresh breads',
    );
  }

  test('today counts only orders placed today that were not cancelled', () {
    final summary = DashboardSummary.from(
      listings: const [],
      orders: [
        order(id: 'paid-today', quantity: 2, total: 1200),
        order(
          id: 'collected-today',
          status: OrderStatus.collected,
          quantity: 3,
          total: 1800,
        ),
        order(
          id: 'cancelled-today',
          status: OrderStatus.cancelled,
          quantity: 5,
          total: 3000,
        ),
        order(
          id: 'paid-yesterday',
          quantity: 4,
          total: 2400,
          createdAt: yesterday,
        ),
      ],
      now: now,
    );

    expect(summary.ordersToday, 2);
    expect(summary.itemsSoldToday, 5);
    expect(summary.revenueToday, 3000);
  });

  test('items rescued counts every collected order, not only today', () {
    final summary = DashboardSummary.from(
      listings: const [],
      orders: [
        order(id: 'today', status: OrderStatus.collected, quantity: 3),
        order(
          id: 'yesterday',
          status: OrderStatus.collected,
          quantity: 4,
          createdAt: yesterday,
        ),
        order(id: 'waiting', quantity: 2),
      ],
      now: now,
    );

    expect(summary.itemsRescued, 7);
  });

  test('an active listing shows portions left, reserved and its total', () {
    final summary = DashboardSummary.from(
      listings: [listing(quantity: 14)],
      orders: [
        order(id: 'waiting', quantity: 5),
        order(id: 'picked-up', status: OrderStatus.collected, quantity: 1),
        order(id: 'cancelled', status: OrderStatus.cancelled, quantity: 3),
      ],
      now: now,
    );

    final progress = summary.activeListings.single;
    expect(progress.left, 14);
    expect(progress.reserved, 5);
    expect(progress.totalPortions, 20);
  });

  test('sold-out and expired listings are not counted as active', () {
    final summary = DashboardSummary.from(
      listings: [
        listing(id: 'on-sale'),
        listing(id: 'sold-out', quantity: 0, status: ListingStatus.soldOut),
        listing(
          id: 'too-late',
          pickupBy: now.subtract(const Duration(minutes: 1)),
        ),
      ],
      orders: const [],
      now: now,
    );

    expect(summary.activeListings.map((item) => item.listing.id), ['on-sale']);
  });

  test('recent orders are the three newest', () {
    final summary = DashboardSummary.from(
      listings: const [],
      orders: [
        order(id: 'newest'),
        order(id: 'second'),
        order(id: 'third'),
        order(id: 'oldest'),
      ],
      now: now,
    );

    expect(summary.recentOrders.map((item) => item.order.id), [
      'newest',
      'second',
      'third',
    ]);
  });
}
