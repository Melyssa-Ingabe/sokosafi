import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/details_step.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

void main() {
  /// Builds the BLoC inside the test, so its events run on the test's fake
  /// clock and reach the widget when the test pumps.
  Future<BusinessSetupBloc> pumpStep(WidgetTester tester) async {
    final bloc = BusinessSetupBloc(
      ownerId: 'owner-1',
      businessRepository: MockBusinessRepository(),
      locationRepository: MockLocationRepository(),
      photoPicker: MockPhotoPicker(),
      imageStorage: const UnavailableImageStorage(),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: bloc, child: const DetailsStep()),
        ),
      ),
    );
    return bloc;
  }

  testWidgets('shows errors and stays on step 1 when submitted empty', (
    tester,
  ) async {
    final bloc = await pumpStep(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your business name'), findsOneWidget);
    expect(find.text('Choose what kind of business you run'), findsOneWidget);
    expect(bloc.state.step, BusinessSetupStep.details);
  });

  testWidgets('moves to the location step once name and type are given', (
    tester,
  ) async {
    final bloc = await pumpStep(tester);

    await tester.enterText(find.byType(TextFormField), 'Boulangerie');
    await tester.tap(find.text('Bakery'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(bloc.state.step, BusinessSetupStep.location);
  });
}
