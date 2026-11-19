import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/shop_listings_cubit.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

import '../discovery_test_data.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

void main() {
  late MockDiscoveryRepository repository;
  final bakery = buildBusiness();

  ShopListingsCubit buildCubit() => ShopListingsCubit(
    repository: repository,
    business: bakery,
    clock: () => feedNow,
  );

  setUp(() => repository = MockDiscoveryRepository());

  blocTest<ShopListingsCubit, ShopListingsState>(
    'shows only food that can still be reserved, soonest first',
    setUp: () => when(() => repository.watchShopItems(bakery)).thenAnswer(
      (_) => Stream.value([
        buildFeedItem(id: 'later', pickupIn: const Duration(hours: 5)),
        buildFeedItem(id: 'sold', status: ListingStatus.soldOut),
        buildFeedItem(id: 'past', pickupIn: const Duration(hours: -1)),
        buildFeedItem(id: 'soon', pickupIn: const Duration(hours: 1)),
      ]),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    verify: (cubit) => expect(
      cubit.state.items.map((item) => item.listing.id),
      ['soon', 'later'],
    ),
  );

  blocTest<ShopListingsCubit, ShopListingsState>(
    'shows a polite error when the shop cannot load',
    setUp: () => when(() => repository.watchShopItems(bakery)).thenAnswer(
      (_) => Stream.error(const DiscoveryFailure('You seem to be offline')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    expect: () => [
      const ShopListingsState(
        status: ShopListingsStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );
}
