import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_summary.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/reviews/domain/entities/review.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';
import 'package:sokosafi/features/reviews/domain/repositories/review_repository.dart';

part 'analytics_state.dart';

/// Follows the business's orders and reviews and recalculates the
/// analytics for the chosen range whenever either changes.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({
    required this._ordersRepository,
    required this._reviewRepository,
    required this._businessId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const AnalyticsState());

  final BusinessOrdersRepository _ordersRepository;
  final ReviewRepository _reviewRepository;
  final String _businessId;

  /// Replaced in tests so "now" is a fixed moment.
  final DateTime Function() _clock;

  StreamSubscription<List<BusinessOrder>>? _ordersSubscription;
  StreamSubscription<List<Review>>? _reviewsSubscription;
  List<BusinessOrder>? _latestOrders;
  List<Review>? _latestReviews;

  void watch() {
    _stopWatching();
    _latestOrders = null;
    _latestReviews = null;
    emit(AnalyticsState(range: state.range));

    _ordersSubscription = _ordersRepository.watchOrders(_businessId).listen((
      orders,
    ) {
      _latestOrders = orders;
      _recalculate();
    }, onError: (Object error) => _fail(error));

    _reviewsSubscription = _reviewRepository
        .watchBusinessReviews(_businessId)
        .listen((reviews) {
          _latestReviews = reviews;
          _recalculate();
        }, onError: (Object error) => _fail(error));
  }

  void selectRange(AnalyticsRange range) {
    if (range == state.range) return;
    emit(
      AnalyticsState(
        status: state.status,
        range: range,
        summary: state.summary,
        errorMessage: state.errorMessage,
      ),
    );
    _recalculate();
  }

  void _recalculate() {
    final orders = _latestOrders;
    final reviews = _latestReviews;
    // Wait for both streams so the numbers are never half calculated.
    if (orders == null || reviews == null) return;
    emit(
      AnalyticsState(
        status: AnalyticsStatus.ready,
        range: state.range,
        summary: AnalyticsSummary.from(
          orders: orders,
          reviews: reviews,
          range: state.range,
          now: _clock(),
        ),
      ),
    );
  }

  void _fail(Object error) {
    _stopWatching();
    final String message;
    if (error is BusinessOrdersFailure) {
      message = error.message;
    } else if (error is ReviewFailure) {
      message = error.message;
    } else {
      message = 'We could not load your analytics. Please try again';
    }
    emit(
      AnalyticsState(
        status: AnalyticsStatus.failure,
        range: state.range,
        errorMessage: message,
      ),
    );
  }

  void _stopWatching() {
    _ordersSubscription?.cancel();
    _reviewsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _stopWatching();
    return super.close();
  }
}
