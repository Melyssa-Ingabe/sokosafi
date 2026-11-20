import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/feed_cubit.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

import '../discovery_test_data.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockDiscoveryRepository repository;
  late MockLocationRepository locationRepository;

  final bread = buildFeedItem(id: 'bread', category: ListingCategory.bakery);
  final veg = buildFeedItem(id: 'veg', category: ListingCategory.grocery);

  FeedCubit buildCubit({List<String> foodPreferences = const []}) => FeedCubit(
    repository: repository,
    locationRepository: locationRepository,
    foodPreferences: foodPreferences,
    clock: () => feedNow,
  );

  List<String> rowTitles(FeedState state) =>
      state.sections.map((section) => section.title).toList();

  setUp(() {
    repository = MockDiscoveryRepository();
    locationRepository = MockLocationRepository();
  });

  blocTest<FeedCubit, FeedState>(
    'shows the streamed listings as rows, preferences first',
    setUp: () =>
        when(() => repository.watchFeed())
            .thenAnswer((_) => Stream.value([bread, veg])),
    build: () => buildCubit(foodPreferences: const ['grocery']),
    act: (cubit) => cubit.watch(),
    expect: () => [
      const FeedState(),
      isA<FeedState>()
          .having((state) => state.status, 'status', FeedStatus.ready)
          .having(rowTitles, 'rows', ['Grocery', 'Bakery']),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'is empty, not failed, when nothing is on sale',
    setUp: () =>
        when(() => repository.watchFeed())
            .thenAnswer((_) => Stream.value(const [])),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    verify: (cubit) => expect(cubit.state.isEmpty, isTrue),
  );

  blocTest<FeedCubit, FeedState>(
    'shows the polite message when the feed fails to load',
    setUp: () => when(() => repository.watchFeed()).thenAnswer(
      (_) => Stream.error(const DiscoveryFailure('You seem to be offline')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    expect: () => [
      const FeedState(
        status: FeedStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    're-orders the rows when the food preferences change',
    setUp: () =>
        when(() => repository.watchFeed())
            .thenAnswer((_) => Stream.value([bread, veg])),
    build: buildCubit,
    act: (cubit) async {
      cubit.watch();
      await Future<void>.delayed(Duration.zero);
      cubit.updateFoodPreferences(const ['grocery']);
    },
    verify: (cubit) => expect(rowTitles(cubit.state), ['Grocery', 'Bakery']),
  );

  group('locate', () {
    blocTest<FeedCubit, FeedState>(
      'adds distances once the phone shares its location',
      setUp: () => when(() => locationRepository.currentPlace()).thenAnswer(
        (_) async => const Place(latitude: -1.9441, longitude: 30.0619),
      ),
      build: buildCubit,
      act: (cubit) => cubit.locate(),
      verify: (cubit) =>
          expect(cubit.state.distanceTo(buildBusiness()), '0 m away'),
    );

    blocTest<FeedCubit, FeedState>(
      'keeps the feed and explains when location is refused',
      setUp: () => when(() => locationRepository.currentPlace())
          .thenThrow(const BusinessFailure('Location permission was refused')),
      build: buildCubit,
      act: (cubit) => cubit.locate(),
      expect: () => [
        const FeedState(locationMessage: FeedCubit.locationUnavailableMessage),
      ],
      verify: (cubit) => expect(cubit.state.distanceTo(buildBusiness()), null),
    );
  });
}
