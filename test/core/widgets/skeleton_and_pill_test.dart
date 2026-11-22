import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/core/theme/app_theme.dart';
import 'package:sokosafi/core/widgets/pill_segmented_control.dart';
import 'package:sokosafi/core/widgets/skeleton_empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_row.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('skeleton empty view shows placeholder rows and its text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SkeletonEmptyView(
          title: 'No active orders',
          message: 'Orders show up here',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SkeletonRow), findsNWidgets(3));
    expect(find.text('No active orders'), findsOneWidget);
    expect(find.text('Orders show up here'), findsOneWidget);
  });

  testWidgets('skeleton empty view fits a short landscape screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(812, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const SkeletonEmptyView(title: 'Empty')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('pill control reports the tapped option', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _host(
        Center(
          child: PillSegmentedControl(
            width: 240,
            labels: const ['Active (1)', 'Past (2)'],
            selectedIndex: 0,
            onSelected: (index) => tapped = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Past (2)'));
    expect(tapped, 1);
  });
}
