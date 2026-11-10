import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/owned_business_cubit.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

void main() {
  const ownerId = 'owner-1';
  final business = Business(
    id: 'business-1',
    ownerId: ownerId,
    name: 'Boulangerie de Kigali',
    type: BusinessType.bakery,
    address: 'KG 5 Ave, Kacyiru',
    latitude: -1.9441,
    longitude: 30.0619,
    photoUrl: '',
    acceptingOrders: true,
    pickupStart: '08:00',
    pickupEnd: '20:00',
    autoClose: false,
    createdAt: DateTime(2026, 11, 9),
  );

  late MockBusinessRepository repository;

  setUp(() {
    repository = MockBusinessRepository();
  });

  blocTest<OwnedBusinessCubit, OwnedBusinessState>(
    'needs setup when the user has no business',
    build: () {
      when(() => repository.watchOwnedBusiness(ownerId))
          .thenAnswer((_) => Stream<Business?>.value(null));
      return OwnedBusinessCubit(
        businessRepository: repository,
        ownerId: ownerId,
      );
    },
    act: (cubit) => cubit.start(),
    verify: (cubit) => expect(cubit.state.needsSetup, isTrue),
  );

  blocTest<OwnedBusinessCubit, OwnedBusinessState>(
    'loads the business when the user already has one',
    build: () {
      when(() => repository.watchOwnedBusiness(ownerId))
          .thenAnswer((_) => Stream<Business?>.value(business));
      return OwnedBusinessCubit(
        businessRepository: repository,
        ownerId: ownerId,
      );
    },
    act: (cubit) => cubit.start(),
    verify: (cubit) {
      expect(cubit.state.business, business);
      expect(cubit.state.needsSetup, isFalse);
    },
  );

  blocTest<OwnedBusinessCubit, OwnedBusinessState>(
    'shows a polite message when the business cannot be loaded',
    build: () {
      when(() => repository.watchOwnedBusiness(ownerId)).thenAnswer(
        (_) => Stream<Business?>.error(
          const BusinessFailure('You seem to be offline'),
        ),
      );
      return OwnedBusinessCubit(
        businessRepository: repository,
        ownerId: ownerId,
      );
    },
    act: (cubit) => cubit.start(),
    verify: (cubit) {
      expect(cubit.state.status, OwnedBusinessStatus.failure);
      expect(cubit.state.errorMessage, 'You seem to be offline');
    },
  );
}
