import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const AuthStarted());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(),
    );
  });

  Widget buildScreen() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('shows validation messages and sends nothing when empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());

    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('sends a login event when the form is valid', (tester) async {
    await tester.pumpWidget(buildScreen());

    // The email field is first on the screen and the password field second.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'melyssa@example.com');
    await tester.enterText(fields.at(1), 'password123');

    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthEmailLoginRequested(
          email: 'melyssa@example.com',
          password: 'password123',
        ),
      ),
    ).called(1);
  });
}
