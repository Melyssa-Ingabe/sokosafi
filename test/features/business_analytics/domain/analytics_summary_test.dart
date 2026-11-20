import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_summary.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/reviews/domain/entities/review.dart';

void main() {
  // A Wednesday afternoon.
  final now = DateTime(2026, 11, 11, 15);

  BusinessOrder order({
    required String id,
    required DateTime createdAt,
    OrderStatus status = OrderStatus.paid,
    int quantity = 1,
    num total = 600,
    String listingId = 'bread',
    String title = 'Fresh breads',
  }) {
    return BusinessOrder(
      order: CustomerOrder(
        id: id,
        customerId: 'customer-1',
        businessId: 'bakery',
        listingId: listingId,
        quantity: quantity,
        total: total,
        pickupCode: 'SKS-4A7F2B',
        paymentMethod: PaymentMethod.mtnMomo,
        status: status,
        createdAt: createdAt,
      ),
      listingTitle: title,
    );
  }

  Review review(int rating, DateTime createdAt) {
    return Review(
      id: 'review-$rating-${createdAt.day}',
      orderId: 'order',
      customerId: 'customer-1',
      businessId: 'bakery',
      rating: rating,
      comment: '',
      createdAt: createdAt,
    );
  }

  test('week totals leave out cancelled and older orders', () {
    final summary = AnalyticsSummary.from(
      orders: [
        order(id: 'today', createdAt: now, quantity: 2, total: 1200),
        order(
          id: 'monday',
          createdAt: DateTime(2026, 11, 9, 10),
          status: OrderStatus.collected,
          quantity: 3,
          total: 1800,
        ),
        order(
          id: 'cancelled',
          createdAt: now,
          status: OrderStatus.cancelled,
          total: 5000,
        ),
        order(id: 'last-month', createdAt: DateTime(2026, 10, 1), total: 9000),
      ],
      reviews: const [],
      range: AnalyticsRange.week,
      now: now,
    );

    expect(summary.revenue, 3000);
    expect(summary.itemsSold, 5);
    expect(summary.orderCount, 2);
  });

  test('the week chart has one point per day, ending today', () {
    final summary = AnalyticsSummary.from(
      orders: [
        order(id: 'a', createdAt: DateTime(2026, 11, 9, 9), total: 1000),
        order(id: 'b', createdAt: DateTime(2026, 11, 9, 18), total: 500),
        order(id: 'c', createdAt: now, total: 700),
      ],
      reviews: const [],
      range: AnalyticsRange.week,
      now: now,
    );

    final amounts = summary.revenuePoints.map((point) => point.amount);
    expect(summary.revenuePoints, hasLength(7));
    expect(summary.revenuePoints.last.start, DateTime(2026, 11, 11));
    expect(amounts, [0, 0, 0, 0, 1500, 0, 700]);
  });

  test('average rating uses only reviews in the range', () {
    final summary = AnalyticsSummary.from(
      orders: const [],
      reviews: [
        review(5, now),
        review(4, DateTime(2026, 11, 10)),
        review(1, DateTime(2026, 9, 1)),
      ],
      range: AnalyticsRange.week,
      now: now,
    );

    expect(summary.averageRating, 4.5);
    expect(summary.ratingCount, 2);
  });

  test('no reviews gives no average instead of zero', () {
    final summary = AnalyticsSummary.from(
      orders: const [],
      reviews: const [],
      range: AnalyticsRange.today,
      now: now,
    );

    expect(summary.averageRating, isNull);
  });

  test('top items are ranked by portions sold', () {
    final summary = AnalyticsSummary.from(
      orders: [
        order(
          id: 'a',
          createdAt: now,
          listingId: 'samosa',
          title: 'Samosas',
          quantity: 2,
        ),
        order(id: 'b', createdAt: now, listingId: 'bread', quantity: 5),
        order(
          id: 'c',
          createdAt: now,
          listingId: 'samosa',
          title: 'Samosas',
          quantity: 1,
        ),
      ],
      reviews: const [],
      range: AnalyticsRange.allTime,
      now: now,
    );

    expect(summary.topItems, const [
      TopItem(title: 'Fresh breads', sold: 5),
      TopItem(title: 'Samosas', sold: 3),
    ]);
  });
}
