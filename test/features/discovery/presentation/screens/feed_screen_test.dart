import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_section.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/feed_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/feed_screen.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

import '../../discovery_test_data.dart';

class MockFeedCubit extends MockCubit<FeedState> implements FeedCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const AppUser _customer = AppUser(
  uid: 'customer-1',
  email: 'nelly@example.com',
  name: 'Nelly',
  phone: '0788000000',
  role: UserRole.customer,
  photoUrl: '',
  foodPreferences: [],
  isEmailVerified: true,
);

void main() {
  late MockFeedCubit feedCubit;
  late MockAuthBloc authBloc;

  final readyState = FeedState(
    status: FeedStatus.ready,
    sections: [
      FeedSection(
        title: 'Bakery',
        category: ListingCategory.bakery,
        items: [
          buildFeedItem(id: 'bread'),
          buildFeedItem(id: 'croissant'),
          buildFeedItem(id: 'cake'),
        ],
      ),
    ],
  );

  setUp(() {
    feedCubit = MockFeedCubit();
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(
      const AuthState(status: AuthStatus.authenticated, user: _customer),
    );
  });

  Future<void> pumpFeed(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<FeedCubit>.value(value: feedCubit),
          ],
          child: const FeedScreen(),
        ),
      ),
    );
  }

  testWidgets('shows each row with its listings', (tester) async {
    when(() => feedCubit.state).thenReturn(readyState);

    await pumpFeed(tester);
    await tester.pumpAndSettle();

    expect(find.text('Bakery'), findsOneWidget);
    expect(find.text('Listing bread'), findsOneWidget);
    expect(find.text('Boulangerie de Kigali'), findsWidgets);
  });

  testWidgets('says so when nothing is on sale', (tester) async {
    when(() => feedCubit.state)
        .thenReturn(const FeedState(status: FeedStatus.ready));

    await pumpFeed(tester);

    expect(find.text('No surplus food right now'), findsOneWidget);
  });

  testWidgets('offers to try again when the feed fails', (tester) async {
    when(() => feedCubit.state).thenReturn(
      const FeedState(
        status: FeedStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    );

    await pumpFeed(tester);
    await tester.tap(find.text('Try again'));

    expect(find.text('You seem to be offline'), findsOneWidget);
    verify(() => feedCubit.watch()).called(1);
  });

  testWidgets('explains missing distances and retries location', (
    tester,
  ) async {
    when(() => feedCubit.state).thenReturn(
      FeedState(
        status: FeedStatus.ready,
        sections: readyState.sections,
        locationMessage: FeedCubit.locationUnavailableMessage,
      ),
    );
    when(() => feedCubit.locate()).thenAnswer((_) async {});

    await pumpFeed(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));

    expect(find.text(FeedCubit.locationUnavailableMessage), findsOneWidget);
    verify(() => feedCubit.locate()).called(1);
  });

  // The team plan asks for no overflow on a small phone or in landscape.
  for (final (name, size) in [
    ('a small phone', const Size(320, 568)),
    ('landscape', const Size(800, 360)),
  ]) {
    testWidgets('lays out without overflow on $name', (tester) async {
      when(() => feedCubit.state).thenReturn(readyState);

      await pumpFeed(tester, screenSize: size);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
