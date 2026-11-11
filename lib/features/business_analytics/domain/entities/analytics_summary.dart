import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/reviews/domain/entities/review.dart';

/// Revenue earned in one slot of the chart (a 3-hour block, a day or a
/// month, depending on the range).
class RevenuePoint extends Equatable {
  const RevenuePoint({required this.start, required this.amount});

  final DateTime start;
  final num amount;

  @override
  List<Object?> get props => [start, amount];
}

class TopItem extends Equatable {
  const TopItem({required this.title, required this.sold});

  final String title;
  final int sold;

  @override
  List<Object?> get props => [title, sold];
}

/// Every number on the Analytics screen for one range. Worked out from
/// orders and reviews each time; none of it is stored.
class AnalyticsSummary extends Equatable {
  const AnalyticsSummary({
    required this.range,
    required this.revenue,
    required this.itemsSold,
    required this.orderCount,
    required this.averageRating,
    required this.ratingCount,
    required this.revenuePoints,
    required this.topItems,
  });

  factory AnalyticsSummary.from({
    required List<BusinessOrder> orders,
    required List<Review> reviews,
    required AnalyticsRange range,
    required DateTime now,
  }) {
    final slotStarts = _slotStarts(range, now);
    // All time counts everything; the chart still shows the last 12 months.
    final rangeStart = range == AnalyticsRange.allTime
        ? null
        : slotStarts.first;
    bool inRange(DateTime moment) =>
        rangeStart == null || !moment.isBefore(rangeStart);

    // Cancelled orders are left out: the customer was not charged.
    final ordersInRange = orders
        .where(
          (item) =>
              item.order.status != OrderStatus.cancelled &&
              inRange(item.order.createdAt),
        )
        .toList();
    final reviewsInRange = reviews
        .where((review) => inRange(review.createdAt))
        .toList();

    final slotAmounts = List<num>.filled(slotStarts.length, 0);
    for (final item in ordersInRange) {
      final slot = _slotIndex(slotStarts, item.order.createdAt);
      if (slot != null) slotAmounts[slot] += item.order.total;
    }

    final soldByListing = <String, int>{};
    final titleByListing = <String, String>{};
    for (final item in ordersInRange) {
      final listingId = item.order.listingId;
      soldByListing[listingId] =
          (soldByListing[listingId] ?? 0) + item.order.quantity;
      titleByListing[listingId] = item.listingTitle.isEmpty
          ? 'Removed listing'
          : item.listingTitle;
    }
    final topItems = [
      for (final entry in soldByListing.entries)
        TopItem(title: titleByListing[entry.key]!, sold: entry.value),
    ]..sort((first, second) => second.sold.compareTo(first.sold));

    final ratingTotal = reviewsInRange.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return AnalyticsSummary(
      range: range,
      revenue: ordersInRange.fold<num>(
        0,
        (sum, item) => sum + item.order.total,
      ),
      itemsSold: ordersInRange.fold<int>(
        0,
        (sum, item) => sum + item.order.quantity,
      ),
      orderCount: ordersInRange.length,
      averageRating: reviewsInRange.isEmpty
          ? null
          : ratingTotal / reviewsInRange.length,
      ratingCount: reviewsInRange.length,
      revenuePoints: [
        for (var slot = 0; slot < slotStarts.length; slot++)
          RevenuePoint(start: slotStarts[slot], amount: slotAmounts[slot]),
      ],
      topItems: topItems.take(topItemLimit).toList(),
    );
  }

  static const int topItemLimit = 3;

  final AnalyticsRange range;
  final num revenue;
  final int itemsSold;
  final int orderCount;

  /// Null when there are no reviews in the range yet.
  final double? averageRating;
  final int ratingCount;
  final List<RevenuePoint> revenuePoints;
  final List<TopItem> topItems;

  /// Where each chart slot starts, oldest first: eight 3-hour blocks for
  /// today, 7 days for a week, 30 days for a month, 12 months for all time.
  static List<DateTime> _slotStarts(AnalyticsRange range, DateTime now) {
    return switch (range) {
      AnalyticsRange.today => [
        for (var block = 0; block < 8; block++)
          DateTime(now.year, now.month, now.day, block * 3),
      ],
      AnalyticsRange.week => [
        for (var daysAgo = 6; daysAgo >= 0; daysAgo--)
          DateTime(now.year, now.month, now.day - daysAgo),
      ],
      AnalyticsRange.month => [
        for (var daysAgo = 29; daysAgo >= 0; daysAgo--)
          DateTime(now.year, now.month, now.day - daysAgo),
      ],
      AnalyticsRange.allTime => [
        for (var monthsAgo = 11; monthsAgo >= 0; monthsAgo--)
          DateTime(now.year, now.month - monthsAgo),
      ],
    };
  }

  /// The last slot that starts at or before [moment], or null if the
  /// moment is before the chart begins.
  static int? _slotIndex(List<DateTime> slotStarts, DateTime moment) {
    for (var slot = slotStarts.length - 1; slot >= 0; slot--) {
      if (!moment.isBefore(slotStarts[slot])) return slot;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    range,
    revenue,
    itemsSold,
    orderCount,
    averageRating,
    ratingCount,
    revenuePoints,
    topItems,
  ];
}
