import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';

import '../discovery_test_data.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

void main() {
  late MockDiscoveryRepository repository;

  ProductDetailCubit buildCubit() =>
      ProductDetailCubit(repository: repository, listingId: 'listing-1');

  setUp(() => repository = MockDiscoveryRepository());

  blocTest<ProductDetailCubit, ProductDetailState>(
    'never lets the quantity go above what is left',
    setUp: () =>
        when(() => repository.watchItem('listing-1'))
            .thenAnswer((_) => Stream.value(buildFeedItem(quantity: 2))),
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit
        ..increaseQuantity()
        ..increaseQuantity()
        ..increaseQuantity();
    },
    verify: (cubit) {
      expect(cubit.state.quantity, 2);
      expect(cubit.state.total, 3000);
    },
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'never lets the quantity drop below one',
    setUp: () =>
        when(() => repository.watchItem('listing-1'))
            .thenAnswer((_) => Stream.value(buildFeedItem())),
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit.decreaseQuantity();
    },
    verify: (cubit) => expect(cubit.state.quantity, 1),
  );

  group('when someone else buys items', () {
    late StreamController<FeedItem> updates;

    blocTest<ProductDetailCubit, ProductDetailState>(
      'lowers the picked quantity to what is left',
      setUp: () {
        updates = StreamController<FeedItem>();
        when(() => repository.watchItem('listing-1'))
            .thenAnswer((_) => updates.stream);
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.watch();
        updates.add(buildFeedItem(quantity: 5));
        await Future<void>.delayed(Duration.zero);
        cubit
          ..increaseQuantity()
          ..increaseQuantity();
        updates.add(buildFeedItem(quantity: 1));
        await Future<void>.delayed(Duration.zero);
      },
      tearDown: () => updates.close(),
      verify: (cubit) => expect(cubit.state.quantity, 1),
    );
  });

  blocTest<ProductDetailCubit, ProductDetailState>(
    'shows why the listing could not load',
    setUp: () => when(() => repository.watchItem('listing-1')).thenAnswer(
      (_) =>
          Stream.error(const DiscoveryFailure('This food is no longer listed')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    expect: () => [
      const ProductDetailState(
        status: ProductDetailStatus.failure,
        errorMessage: 'This food is no longer listed',
      ),
    ],
  );

  test('cannot reserve food from a shop that stopped taking orders', () {
    final state = ProductDetailState(
      status: ProductDetailStatus.ready,
      item: buildFeedItem(business: buildBusiness(acceptingOrders: false)),
    );

    expect(state.canReserveAt(feedNow), isFalse);
  });
}
