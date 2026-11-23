import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/repositories/directions_launcher.dart';
import 'package:sokosafi/features/discovery/domain/repositories/phone_launcher.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/store_contact_buttons.dart';

class MockDirectionsLauncher extends Mock implements DirectionsLauncher {}

class MockPhoneLauncher extends Mock implements PhoneLauncher {}

void main() {
  late MockDirectionsLauncher directions;
  late MockPhoneLauncher phone;

  setUp(() {
    directions = MockDirectionsLauncher();
    phone = MockPhoneLauncher();
  });

  Future<void> pump(WidgetTester tester, {required String number}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoreContactButtons(
            latitude: -1.95,
            longitude: 30.06,
            phone: number,
            directionsLauncher: directions,
            phoneLauncher: phone,
          ),
        ),
      ),
    );
  }

  testWidgets('hides Call store until the shop saves a number', (tester) async {
    await pump(tester, number: '');

    expect(find.text('Directions'), findsOneWidget);
    expect(find.text('Call store'), findsNothing);
  });

  testWidgets('calls the shop number', (tester) async {
    when(() => phone.call('0788 123 456')).thenAnswer((_) async => true);
    await pump(tester, number: '0788 123 456');

    await tester.tap(find.text('Call store'));
    await tester.pump();

    verify(() => phone.call('0788 123 456')).called(1);
  });

  testWidgets('says so when the phone cannot make calls', (tester) async {
    when(() => phone.call(any())).thenAnswer((_) async => false);
    await pump(tester, number: '0788 123 456');

    await tester.tap(find.text('Call store'));
    await tester.pump();

    expect(find.text(StoreContactButtons.callFailure), findsOneWidget);
  });
}
