import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';

part 'dashboard_state.dart';

/// Follows the business's listings and orders at the same time and
/// recalculates the dashboard whenever either one changes.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this._listingRepository,
    required this._ordersRepository,
    required this._businessId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const DashboardState());

  static const String _loadErrorMessage =
      'We could not load your dashboard. Please try again';

  final ListingRepository _listingRepository;
  final BusinessOrdersRepository _ordersRepository;
  final String _businessId;

  /// Replaced in tests so "today" is a fixed moment.
  final DateTime Function() _clock;

  StreamSubscription<List<Listing>>? _listingsSubscription;
  StreamSubscription<List<BusinessOrder>>? _ordersSubscription;
  Timer? _minuteTicker;

  List<Listing>? _latestListings;
  List<BusinessOrder>? _latestOrders;

  void watch() {
    _stopWatching();
    _latestListings = null;
    _latestOrders = null;
    emit(const DashboardState());

    _listingsSubscription = _listingRepository
        .watchBusinessListings(_businessId)
        .listen((listings) {
          _latestListings = listings;
          _recalculate();
        }, onError: (Object error) => _fail(error));

    _ordersSubscription = _ordersRepository.watchOrders(_businessId).listen((
      orders,
    ) {
      _latestOrders = orders;
      _recalculate();
    }, onError: (Object error) => _fail(error));

    // "Today" and listing expiry change with the clock even when no data
    // changes, so the numbers are also recalculated once a minute.
    _minuteTicker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _recalculate(),
    );
  }

  void _recalculate() {
    final listings = _latestListings;
    final orders = _latestOrders;
    // Wait until both streams have arrived once, so the dashboard never
    // shows half-calculated numbers.
    if (listings == null || orders == null) return;
    emit(
      DashboardState(
        status: DashboardStatus.ready,
        summary: DashboardSummary.from(
          listings: listings,
          orders: orders,
          now: _clock(),
        ),
      ),
    );
  }

  void _fail(Object error) {
    // Stop the other stream too, or its next update would replace the
    // error with numbers missing half their data.
    _stopWatching();
    final String message;
    if (error is BusinessOrdersFailure) {
      message = error.message;
    } else if (error is ListingFailure) {
      message = error.message;
    } else {
      message = _loadErrorMessage;
    }
    emit(
      DashboardState(status: DashboardStatus.failure, errorMessage: message),
    );
  }

  void _stopWatching() {
    _listingsSubscription?.cancel();
    _ordersSubscription?.cancel();
    _minuteTicker?.cancel();
  }

  @override
  Future<void> close() {
    _stopWatching();
    return super.close();
  }
}
