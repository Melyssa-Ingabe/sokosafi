import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

/// How one active listing is selling, for the dashboard's progress bars.
class ListingProgress extends Equatable {
  const ListingProgress({
    required this.listing,
    required this.reserved,
    required this.totalPortions,
  });

  final Listing listing;

  /// Portions in paid orders still waiting for pickup.
  final int reserved;

  /// Portions left plus every portion ordered and not cancelled: how many
  /// the listing started with. Worked out, not stored, so it cannot go stale.
  final int totalPortions;

  int get left => listing.quantity;

  /// Share of the listing already ordered, from 0 to 1, for the bar.
  double get orderedFraction =>
      totalPortions == 0 ? 0 : (totalPortions - left) / totalPortions;

  @override
  List<Object?> get props => [listing, reserved, totalPortions];
}

/// Every number on the Business Dashboard. Recalculated from the live
/// listings and orders whenever either changes; none of it is stored.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.activeListings,
    required this.ordersToday,
    required this.itemsSoldToday,
    required this.revenueToday,
    required this.itemsRescued,
    required this.recentOrders,
  });

  factory DashboardSummary.from({
    required List<Listing> listings,
    required List<BusinessOrder> orders,
    required DateTime now,
  }) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    // Cancelled orders never count: the food went back on sale and the
    // customer was not charged.
    final keptOrders = orders
        .where((item) => item.order.status != OrderStatus.cancelled)
        .toList();
    final todaysOrders = keptOrders
        .where((item) => !item.order.createdAt.isBefore(startOfToday))
        .toList();

    final activeListings = [
      for (final listing in listings)
        if (listing.effectiveStatus(now) == ListingStatus.active)
          ListingProgress(
            listing: listing,
            reserved: _sumQuantity(
              keptOrders.where(
                (item) =>
                    item.order.listingId == listing.id &&
                    item.order.status == OrderStatus.paid,
              ),
            ),
            totalPortions:
                listing.quantity +
                _sumQuantity(
                  keptOrders.where(
                    (item) => item.order.listingId == listing.id,
                  ),
                ),
          ),
    ];

    return DashboardSummary(
      activeListings: activeListings,
      ordersToday: todaysOrders.length,
      itemsSoldToday: _sumQuantity(todaysOrders),
      revenueToday: todaysOrders.fold<num>(
        0,
        (sum, item) => sum + item.order.total,
      ),
      itemsRescued: _sumQuantity(
        keptOrders.where((item) => item.order.status == OrderStatus.collected),
      ),
      // Orders arrive newest first, so the first few are the most recent.
      recentOrders: orders.take(recentOrderLimit).toList(),
    );
  }

  static const int recentOrderLimit = 3;

  final List<ListingProgress> activeListings;
  final int ordersToday;
  final int itemsSoldToday;
  final num revenueToday;

  /// Portions customers actually collected, so food that did not go to waste
  final int itemsRescued;
  final List<BusinessOrder> recentOrders;

  static int _sumQuantity(Iterable<BusinessOrder> orders) {
    return orders.fold<int>(0, (sum, item) => sum + item.order.quantity);
  }

  @override
  List<Object?> get props => [
    activeListings,
    ordersToday,
    itemsSoldToday,
    revenueToday,
    itemsRescued,
    recentOrders,
  ];
}
