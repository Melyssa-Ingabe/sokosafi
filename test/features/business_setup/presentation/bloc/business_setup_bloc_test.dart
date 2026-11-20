import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/storage/image_upload_failure.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

class MockImageStorage extends Mock implements ImageStorage {}

void main() {
  const ownerId = 'owner-1';
  const kacyiru = Place(
    latitude: -1.9441,
    longitude: 30.0619,
    street: 'KG 5 Ave',
    neighborhood: 'Kacyiru, Kigali',
  );

  late MockBusinessRepository businessRepository;
  late MockLocationRepository locationRepository;
  late MockPhotoPicker photoPicker;

  setUpAll(() {
    registerFallbackValue(
      const BusinessSetupInput(
        name: 'fallback',
        type: BusinessType.bakery,
        address: 'fallback',
        latitude: 0,
        longitude: 0,
      ),
    );
  });

  setUp(() {
    businessRepository = MockBusinessRepository();
    locationRepository = MockLocationRepository();
    photoPicker = MockPhotoPicker();
  });

  BusinessSetupBloc buildBloc({ImageStorage? imageStorage}) {
    return BusinessSetupBloc(
      ownerId: ownerId,
      businessRepository: businessRepository,
      locationRepository: locationRepository,
      photoPicker: photoPicker,
      imageStorage: imageStorage ?? const UnavailableImageStorage(),
    );
  }

  /// A form that has passed steps 1 and 2.
  const readyForPhoto = BusinessSetupState(
    step: BusinessSetupStep.photo,
    name: 'Boulangerie de Kigali',
    type: BusinessType.bakery,
    address: 'KG 5 Ave',
    neighborhood: 'Kacyiru, Kigali',
    latitude: -1.9441,
    longitude: 30.0619,
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'stays on step 1 and shows errors when the name is blank',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const BusinessTypeSelected(BusinessType.bakery))
      ..add(const SetupContinued()),
    skip: 1,
    expect: () => [
      isA<BusinessSetupState>()
          .having((state) => state.step, 'step', BusinessSetupStep.details)
          .having(
            (state) => state.nameError,
            'nameError',
            'Enter your business name',
          ),
    ],
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'moves to the location step when name and type are valid',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const BusinessNameChanged('Boulangerie de Kigali'))
      ..add(const BusinessTypeSelected(BusinessType.bakery))
      ..add(const SetupContinued()),
    verify: (bloc) => expect(bloc.state.step, BusinessSetupStep.location),
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'current location fills the pin, street and neighborhood',
    build: () {
      when(() => locationRepository.currentPlace())
          .thenAnswer((_) async => kacyiru);
      return buildBloc();
    },
    act: (bloc) => bloc.add(const CurrentLocationRequested()),
    verify: (bloc) {
      expect(bloc.state.latitude, -1.9441);
      expect(bloc.state.address, 'KG 5 Ave');
      expect(bloc.state.neighborhood, 'Kacyiru, Kigali');
      expect(bloc.state.mapFocusRevision, 1);
      expect(bloc.state.isLocating, isFalse);
    },
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'shows a polite message when location permission is refused',
    build: () {
      when(() => locationRepository.currentPlace())
          .thenThrow(const BusinessFailure('Location permission was refused'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const CurrentLocationRequested()),
    skip: 1,
    expect: () => [
      isA<BusinessSetupState>()
          .having((state) => state.isLocating, 'isLocating', false)
          .having(
            (state) => state.feedback?.message,
            'message',
            'Location permission was refused',
          ),
    ],
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'cannot leave the location step before the pin is placed',
    build: buildBloc,
    seed: () => const BusinessSetupState(
      step: BusinessSetupStep.location,
      name: 'Boulangerie de Kigali',
      type: BusinessType.bakery,
      address: 'KG 5 Ave',
    ),
    act: (bloc) => bloc.add(const SetupContinued()),
    verify: (bloc) {
      expect(bloc.state.step, BusinessSetupStep.location);
      expect(bloc.state.locationError, isNotNull);
    },
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'skipping the photo creates the business with the full address',
    build: () {
      when(
        () => businessRepository.createBusiness(
          ownerId: any(named: 'ownerId'),
          input: any(named: 'input'),
        ),
      ).thenAnswer((_) async => 'business-1');
      return buildBloc();
    },
    seed: () => readyForPhoto,
    act: (bloc) => bloc.add(const SetupPhotoSkipped()),
    expect: () => [
      isA<BusinessSetupState>().having(
        (state) => state.status,
        'status',
        BusinessSetupStatus.submitting,
      ),
      isA<BusinessSetupState>()
          .having(
            (state) => state.status,
            'status',
            BusinessSetupStatus.success,
          )
          .having((state) => state.businessId, 'businessId', 'business-1'),
    ],
    verify: (_) {
      final saved =
          verify(
                () => businessRepository.createBusiness(
                  ownerId: ownerId,
                  input: captureAny(named: 'input'),
                ),
              ).captured.single
              as BusinessSetupInput;
      expect(saved.address, 'KG 5 Ave, Kacyiru, Kigali');
      expect(saved.photoUrl, isEmpty);
    },
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'asks for a photo when "Complete setup" is tapped without one',
    build: buildBloc,
    seed: () => readyForPhoto,
    act: (bloc) => bloc.add(const SetupContinued()),
    expect: () => [
      isA<BusinessSetupState>().having(
        (state) => state.feedback?.message,
        'message',
        'Add a photo, or tap "Skip for now"',
      ),
    ],
    verify: (_) => verifyNever(
      () => businessRepository.createBusiness(
        ownerId: any(named: 'ownerId'),
        input: any(named: 'input'),
      ),
    ),
  );

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'goes back to editing with a polite message when saving fails',
    build: () {
      when(
        () => businessRepository.createBusiness(
          ownerId: any(named: 'ownerId'),
          input: any(named: 'input'),
        ),
      ).thenThrow(const BusinessFailure('You seem to be offline'));
      return buildBloc();
    },
    seed: () => readyForPhoto,
    act: (bloc) => bloc.add(const SetupPhotoSkipped()),
    skip: 1,
    expect: () => [
      isA<BusinessSetupState>()
          .having(
            (state) => state.status,
            'status',
            BusinessSetupStatus.editing,
          )
          .having(
            (state) => state.feedback?.message,
            'message',
            'You seem to be offline',
          ),
    ],
  );

  group('address search', () {
    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'places the pin and keeps the address the owner typed',
      build: () {
        when(() => locationRepository.search('Near the Kacyiru bus stop'))
            .thenAnswer((_) async => kacyiru);
        return buildBloc();
      },
      act: (bloc) => bloc
        ..add(const BusinessAddressChanged('Near the Kacyiru bus stop'))
        ..add(const BusinessAddressSearched()),
      verify: (bloc) {
        expect(bloc.state.latitude, -1.9441);
        expect(bloc.state.neighborhood, 'Kacyiru, Kigali');
        expect(bloc.state.address, 'Near the Kacyiru bus stop');
        expect(bloc.state.isLocating, isFalse);
      },
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'asks to move the map when the address is not found',
      build: () {
        when(() => locationRepository.search(any()))
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      seed: () => const BusinessSetupState(address: 'Nowhere street'),
      act: (bloc) => bloc.add(const BusinessAddressSearched()),
      skip: 1,
      expect: () => [
        isA<BusinessSetupState>()
            .having((state) => state.isLocating, 'isLocating', false)
            .having(
              (state) => state.feedback?.message,
              'message',
              'We could not find that address. Move the map to place the pin',
            ),
      ],
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'does not search a blank address',
      build: buildBloc,
      act: (bloc) => bloc.add(const BusinessAddressSearched()),
      expect: () => <BusinessSetupState>[],
      verify: (_) => verifyNever(() => locationRepository.search(any())),
    );
  });

  group('moving the map pin', () {
    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'fills the neighborhood and an empty address from the new spot',
      build: () {
        when(
          () => locationRepository.describe(
            latitude: -1.9441,
            longitude: 30.0619,
          ),
        ).thenAnswer((_) async => kacyiru);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const MapPinMoved(latitude: -1.9441, longitude: 30.0619)),
      verify: (bloc) {
        expect(bloc.state.latitude, -1.9441);
        expect(bloc.state.neighborhood, 'Kacyiru, Kigali');
        expect(bloc.state.address, 'KG 5 Ave');
      },
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'an older lookup does not overwrite a newer pin',
      build: () {
        when(
          () => locationRepository.describe(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((invocation) async {
          final latitude = invocation.namedArguments[#latitude] as double;
          // The first lookup answers after the second one.
          if (latitude == -1.0) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return const Place(
              latitude: -1.0,
              longitude: 30.0,
              street: '',
              neighborhood: 'Old spot',
            );
          }
          return kacyiru;
        });
        return buildBloc();
      },
      act: (bloc) => bloc
        ..add(const MapPinMoved(latitude: -1.0, longitude: 30.0))
        ..add(const MapPinMoved(latitude: -1.9441, longitude: 30.0619)),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.latitude, -1.9441);
        expect(bloc.state.neighborhood, 'Kacyiru, Kigali');
      },
    );
  });

  group('business photo', () {
    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'keeps the picked photo',
      build: () {
        when(() => photoPicker.pick(PhotoSource.gallery))
            .thenAnswer((_) async => '/tmp/shop.jpg');
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const BusinessPhotoRequested(PhotoSource.gallery)),
      verify: (bloc) => expect(bloc.state.photoPath, '/tmp/shop.jpg'),
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'explains when the camera cannot open',
      build: () {
        when(() => photoPicker.pick(PhotoSource.camera))
            .thenThrow(Exception('camera denied'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const BusinessPhotoRequested(PhotoSource.camera)),
      expect: () => [
        isA<BusinessSetupState>().having(
          (state) => state.feedback?.message,
          'message',
          'We could not open the camera. Check that SokoSafi may use it',
        ),
      ],
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'uploads the photo to the owner folder and saves its url',
      build: () {
        final storage = MockImageStorage();
        when(() => storage.isAvailable).thenReturn(true);
        when(
          () => storage.upload(
            localPath: '/tmp/shop.jpg',
            folder: 'businesses/$ownerId',
          ),
        ).thenAnswer((_) async => 'https://pub.r2.dev/shop.jpg');
        when(
          () => businessRepository.createBusiness(
            ownerId: ownerId,
            input: any(named: 'input'),
          ),
        ).thenAnswer((_) async => 'business-1');
        return buildBloc(imageStorage: storage);
      },
      seed: () => readyForPhoto.copyWith(photoPath: '/tmp/shop.jpg'),
      act: (bloc) => bloc.add(const SetupContinued()),
      verify: (bloc) {
        expect(bloc.state.status, BusinessSetupStatus.success);
        expect(bloc.state.feedback?.message, 'Your business is ready');
        final saved =
            verify(
                  () => businessRepository.createBusiness(
                    ownerId: ownerId,
                    input: captureAny(named: 'input'),
                  ),
                ).captured.single
                as BusinessSetupInput;
        expect(saved.photoUrl, 'https://pub.r2.dev/shop.jpg');
      },
    );

    blocTest<BusinessSetupBloc, BusinessSetupState>(
      'shows the upload message and saves nothing when the upload fails',
      build: () {
        final storage = MockImageStorage();
        when(() => storage.isAvailable).thenReturn(true);
        when(
          () => storage.upload(
            localPath: any(named: 'localPath'),
            folder: any(named: 'folder'),
          ),
        ).thenThrow(const ImageUploadFailure('Please sign in again'));
        return buildBloc(imageStorage: storage);
      },
      seed: () => readyForPhoto.copyWith(photoPath: '/tmp/shop.jpg'),
      act: (bloc) => bloc.add(const SetupContinued()),
      verify: (bloc) {
        expect(bloc.state.status, BusinessSetupStatus.editing);
        expect(bloc.state.feedback?.message, 'Please sign in again');
        verifyNever(
          () => businessRepository.createBusiness(
            ownerId: any(named: 'ownerId'),
            input: any(named: 'input'),
          ),
        );
      },
    );
  });

  blocTest<BusinessSetupBloc, BusinessSetupState>(
    'back goes to the previous step',
    build: buildBloc,
    seed: () => readyForPhoto,
    act: (bloc) => bloc.add(const SetupStepBack()),
    verify: (bloc) => expect(bloc.state.step, BusinessSetupStep.location),
  );
}
