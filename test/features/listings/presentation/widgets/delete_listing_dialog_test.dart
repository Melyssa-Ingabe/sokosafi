import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/listings/presentation/widgets/delete_listing_dialog.dart';

void main() {
  /// Opens the dialog from a button and records what it returns.
  Future<List<bool>> pumpOpener(WidgetTester tester) async {
    final results = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(
                await DeleteListingDialog.show(context, title: 'Fresh breads'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('names the listing and confirms on Delete', (tester) async {
    final results = await pumpOpener(tester);

    expect(find.textContaining('"Fresh breads"'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(results, [true]);
  });

  testWidgets('does not confirm on Cancel', (tester) async {
    final results = await pumpOpener(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });
}
