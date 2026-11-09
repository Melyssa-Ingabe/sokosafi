import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';
import 'package:sokosafi/features/listings/presentation/widgets/managed_listing_card.dart';

import '../../listing_test_data.dart';

void main() {
  // A sold-out listing is used so the live countdown (which runs a timer)
  // is not on screen.
  final soldOut = buildTestListing(quantity: 0, status: ListingStatus.soldOut);

  Future<void> pumpCard(
    WidgetTester tester, {
    bool isDeleting = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManagedListingCard(
            listing: soldOut,
            status: ListingStatus.soldOut,
            isDeleting: isDeleting,
            onEdit: onEdit ?? () {},
            onDelete: onDelete ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows the title, quantity, prices and sold-out badge', (
    tester,
  ) async {
    await pumpCard(tester);

    expect(find.text('Fresh artisan breads'), findsOneWidget);
    expect(find.text('0 left'), findsOneWidget);
    expect(find.text('600 RWF'), findsOneWidget);
    expect(find.text('Sold out'), findsOneWidget);
  });

  testWidgets('edit and delete buttons call back', (tester) async {
    var edits = 0;
    var deletes = 0;
    await pumpCard(tester, onEdit: () => edits++, onDelete: () => deletes++);

    await tester.tap(find.text('Edit'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(edits, 1);
    expect(deletes, 1);
  });

  testWidgets('shows progress instead of Delete while deleting', (
    tester,
  ) async {
    await pumpCard(tester, isDeleting: true);

    expect(find.text('Delete'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
