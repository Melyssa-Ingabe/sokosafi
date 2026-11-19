import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

import '../discovery_test_data.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockDiscoveryRepository repository;
  late MockLocationRepository locationRepository;

  final bread = buildFeedItem(id: 'bread');
  final coffee = buildFeedItem(id: 'coffee', category: ListingCategory.cafe);

  SearchCubit buildCubit({int? defaultRadiusKm}) => SearchCubit(
    repository: repository,
    locationRepository: locationRepository,
    defaultRadiusKm: defaultRadiusKm,
    clock: () => feedNow,
  );

  List<String> resultIds(SearchCubit cubit) =>
      cubit.state.results.map((result) => result.item.listing.id).toList();

  setUp(() {
    repository = MockDiscoveryRepository();
    locationRepository = MockLocationRepository();
    when(() => repository.watchFeed())
        .thenAnswer((_) => Stream.value([bread, coffee]));
  });

  test('starts with the search distance from settings, not as a filter', () {
    final state = buildCubit(defaultRadiusKm: 5).state;

    expect(state.filter.radiusKm, 5);
    expect(state.hasCustomLimits, isFalse);
  });

  blocTest<SearchCubit, SearchState>(
    'counts what is on sale separately from what matches',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit.updateQuery('nothing like this');
    },
    verify: (cubit) {
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.availableCount, 2);
    },
  );

  blocTest<SearchCubit, SearchState>(
    'shows everything on sale before the customer types',
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    verify: (cubit) => expect(resultIds(cubit), ['bread', 'coffee']),
  );

  blocTest<SearchCubit, SearchState>(
    'narrows the results as the customer types',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit.updateQuery('coffee');
    },
    verify: (cubit) => expect(resultIds(cubit), ['coffee']),
  );

  blocTest<SearchCubit, SearchState>(
    'filters by the chosen category',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit.selectCategory(ListingCategory.bakery);
    },
    verify: (cubit) => expect(resultIds(cubit), ['bread']),
  );

  blocTest<SearchCubit, SearchState>(
    'choosing All shows every category again',
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit
        ..selectCategory(ListingCategory.bakery)
        ..selectCategory(null);
    },
    verify: (cubit) => expect(resultIds(cubit), ['bread', 'coffee']),
  );

  blocTest<SearchCubit, SearchState>(
    'clearing the filters keeps what was typed',
    build: () => buildCubit(defaultRadiusKm: 5),
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit
        ..updateQuery('listing')
        ..applyLimits(maxPriceRwf: 500, radiusKm: 3)
        ..clearFilters();
    },
    verify: (cubit) {
      expect(cubit.state.filter.query, 'listing');
      expect(cubit.state.filter.maxPriceRwf, isNull);
      // Back to the distance from settings, not to "any distance".
      expect(cubit.state.filter.radiusKm, 5);
      expect(cubit.state.hasCustomLimits, isFalse);
    },
  );

  blocTest<SearchCubit, SearchState>(
    'explains when location is refused and keeps searching',
    setUp: () => when(() => locationRepository.currentPlace())
        .thenThrow(const BusinessFailure('Location permission was refused')),
    build: buildCubit,
    act: (cubit) => cubit.locate(),
    verify: (cubit) => expect(
      cubit.state.locationMessage,
      SearchCubit.locationUnavailableMessage,
    ),
  );

  blocTest<SearchCubit, SearchState>(
    'adds distances once the phone shares its location',
    setUp: () => when(() => locationRepository.currentPlace()).thenAnswer(
      (_) async => const Place(latitude: -1.9441, longitude: 30.0619),
    ),
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      await cubit.locate();
    },
    verify: (cubit) =>
        expect(cubit.state.results.first.distanceKm, closeTo(0, 0.01)),
  );

  blocTest<SearchCubit, SearchState>(
    'shows a polite error when the food cannot load',
    setUp: () => when(() => repository.watchFeed()).thenAnswer(
      (_) => Stream.error(const DiscoveryFailure('You seem to be offline')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    verify: (cubit) {
      expect(cubit.state.status, SearchStatus.failure);
      expect(cubit.state.errorMessage, 'You seem to be offline');
    },
  );
}
