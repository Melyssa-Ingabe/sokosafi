import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockBusinessOrdersRepository extends Mock
    implements BusinessOrdersRepository {}

void main() {
  final now = DateTime(2026, 11, 11, 15);
  late MockListingRepository listingRepository;
  late MockBusinessOrdersRepository ordersRepository;
  late StreamController<List<Listing>> listingsStream;
  late StreamController<List<BusinessOrder>> ordersStream;

  BusinessOrder paidOrder(String id, num total) {
    return BusinessOrder(
      order: CustomerOrder(
        id: id,
        customerId: 'customer-1',
        businessId: 'bakery',
        listingId: 'bread',
        quantity: 1,
        total: total,
        pickupCode: 'SKS-4A7F2B',
        paymentMethod: PaymentMethod.mtnMomo,
        status: OrderStatus.paid,
        createdAt: now,
      ),
      listingTitle: 'Fresh breads',
    );
  }

  Matcher readyWithRevenue(num revenue) {
    return isA<DashboardState>()
        .having((state) => state.status, 'status', DashboardStatus.ready)
        .having(
          (state) => state.summary?.revenueToday,
          'revenueToday',
          revenue,
        );
  }

  // Lets queued stream events reach the cubit before the next step.
  Future<void> letStreamsDeliver() => Future<void>.delayed(Duration.zero);

  DashboardCubit buildCubit() => DashboardCubit(
    listingRepository: listingRepository,
    ordersRepository: ordersRepository,
    businessId: 'bakery',
    clock: () => now,
  );

  setUp(() {
    listingRepository = MockListingRepository();
    ordersRepository = MockBusinessOrdersRepository();
    listingsStream = StreamController<List<Listing>>();
    ordersStream = StreamController<List<BusinessOrder>>();
    when(() => listingRepository.watchBusinessListings('bakery'))
        .thenAnswer((_) => listingsStream.stream);
    when(() => ordersRepository.watchOrders('bakery'))
        .thenAnswer((_) => ordersStream.stream);
  });

  tearDown(() async {
    await listingsStream.close();
    await ordersStream.close();
  });

  blocTest<DashboardCubit, DashboardState>(
    'waits for both listings and orders before showing numbers',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      listingsStream.add(const []);
      await letStreamsDeliver();
      ordersStream.add([paidOrder('first', 1200)]);
      await letStreamsDeliver();
    },
    expect: () => [const DashboardState(), readyWithRevenue(1200)],
  );

  blocTest<DashboardCubit, DashboardState>(
    'recalculates when a new order arrives',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      listingsStream.add(const []);
      ordersStream.add(const []);
      await letStreamsDeliver();
      ordersStream.add([paidOrder('new', 600)]);
      await letStreamsDeliver();
    },
    expect: () => [
      const DashboardState(),
      readyWithRevenue(0),
      readyWithRevenue(600),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'shows a polite message when orders cannot load',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      ordersStream.addError(
        const BusinessOrdersFailure('You seem to be offline'),
      );
      await letStreamsDeliver();
    },
    expect: () => [
      const DashboardState(),
      const DashboardState(
        status: DashboardStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );
}
