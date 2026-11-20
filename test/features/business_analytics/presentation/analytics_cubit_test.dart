import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';
import 'package:sokosafi/features/business_analytics/presentation/bloc/analytics_cubit.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/reviews/domain/entities/review.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';
import 'package:sokosafi/features/reviews/domain/repositories/review_repository.dart';

class MockBusinessOrdersRepository extends Mock
    implements BusinessOrdersRepository {}

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  final now = DateTime(2026, 11, 11, 15);
  late MockBusinessOrdersRepository ordersRepository;
  late MockReviewRepository reviewRepository;
  late StreamController<List<BusinessOrder>> ordersStream;
  late StreamController<List<Review>> reviewsStream;

  // Placed on Monday: inside the week, but not today.
  final mondayOrder = BusinessOrder(
    order: CustomerOrder(
      id: 'monday',
      customerId: 'customer-1',
      businessId: 'bakery',
      listingId: 'bread',
      quantity: 1,
      total: 600,
      pickupCode: 'SKS-4A7F2B',
      paymentMethod: PaymentMethod.mtnMomo,
      status: OrderStatus.paid,
      createdAt: DateTime(2026, 11, 9, 10),
    ),
    listingTitle: 'Fresh breads',
  );

  Future<void> letStreamsDeliver() => Future<void>.delayed(Duration.zero);

  AnalyticsCubit buildCubit() => AnalyticsCubit(
    ordersRepository: ordersRepository,
    reviewRepository: reviewRepository,
    businessId: 'bakery',
    clock: () => now,
  );

  setUp(() {
    ordersRepository = MockBusinessOrdersRepository();
    reviewRepository = MockReviewRepository();
    ordersStream = StreamController<List<BusinessOrder>>();
    reviewsStream = StreamController<List<Review>>();
    when(() => ordersRepository.watchOrders('bakery'))
        .thenAnswer((_) => ordersStream.stream);
    when(() => reviewRepository.watchBusinessReviews('bakery'))
        .thenAnswer((_) => reviewsStream.stream);
  });

  tearDown(() async {
    await ordersStream.close();
    await reviewsStream.close();
  });

  blocTest<AnalyticsCubit, AnalyticsState>(
    'switching from today to week recalculates the revenue',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      ordersStream.add([mondayOrder]);
      reviewsStream.add(const []);
      await letStreamsDeliver();
      cubit.selectRange(AnalyticsRange.week);
    },
    verify: (cubit) {
      expect(cubit.state.range, AnalyticsRange.week);
      expect(cubit.state.summary?.revenue, 600);
    },
  );

  blocTest<AnalyticsCubit, AnalyticsState>(
    'today does not count an order from Monday',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      ordersStream.add([mondayOrder]);
      reviewsStream.add(const []);
      await letStreamsDeliver();
    },
    verify: (cubit) {
      expect(cubit.state.status, AnalyticsStatus.ready);
      expect(cubit.state.summary?.revenue, 0);
    },
  );

  blocTest<AnalyticsCubit, AnalyticsState>(
    'shows a polite message when reviews cannot load',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      reviewsStream.addError(const ReviewFailure('You seem to be offline'));
      await letStreamsDeliver();
    },
    expect: () => [
      const AnalyticsState(),
      const AnalyticsState(
        status: AnalyticsStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );
}
