import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('calls onPressed when tapped', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _wrap(PrimaryButton(label: 'Log in', onPressed: () => tapCount++)),
    );

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('shows a spinner and ignores taps while loading', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _wrap(
        PrimaryButton(
          label: 'Log in',
          onPressed: () => tapCount++,
          isLoading: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(tapCount, 0);
  });
}
