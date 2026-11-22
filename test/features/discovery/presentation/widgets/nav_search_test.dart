import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/nav_search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_field.dart';

void main() {
  test('nav search remembers the tab to return to', () {
    final cubit = NavSearchCubit()..open(returnIndex: 3);
    expect(
      cubit.state,
      const NavSearchState(isSearching: true, returnIndex: 3),
    );

    cubit.dismiss();
    expect(cubit.state, const NavSearchState(returnIndex: 3));
  });

  testWidgets('search box sends typing and offers a back button', (
    tester,
  ) async {
    final typed = <String>[];
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(onChanged: typed.add, onBack: () => closed = true),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'bread');
    await tester.tap(find.byTooltip('Close search'));

    expect(typed, ['bread']);
    expect(closed, isTrue);
  });
}
