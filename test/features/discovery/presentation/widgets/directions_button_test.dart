import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/repositories/directions_launcher.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/directions_button.dart';

import '../../discovery_test_data.dart';

class MockDirectionsLauncher extends Mock implements DirectionsLauncher {}

void main() {
  late MockDirectionsLauncher launcher;

  setUp(() => launcher = MockDirectionsLauncher());

  void opensMaps(bool result) => when(
    () => launcher.openDirections(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
    ),
  ).thenAnswer((_) async => result);

  Future<void> pumpButton(WidgetTester tester, {bool compact = false}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: DirectionsButton(
              business: buildBusiness(latitude: -1.95, longitude: 30.06),
              compact: compact,
              launcher: launcher,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('opens directions to the shop', (tester) async {
    opensMaps(true);

    await pumpButton(tester);
    await tester.tap(find.text('Get directions'));
    await tester.pump();

    verify(() => launcher.openDirections(latitude: -1.95, longitude: 30.06))
        .called(1);
    expect(find.text(DirectionsButton.failureMessage), findsNothing);
  });

  testWidgets('says so when no maps app can open', (tester) async {
    opensMaps(false);

    await pumpButton(tester);
    await tester.tap(find.text('Get directions'));
    await tester.pump();

    expect(find.text(DirectionsButton.failureMessage), findsOneWidget);
  });

  testWidgets('the compact button names the shop for screen readers', (
    tester,
  ) async {
    opensMaps(true);

    await pumpButton(tester, compact: true);

    expect(find.byTooltip('Directions to Boulangerie de Kigali'), findsOne);
  });
}
