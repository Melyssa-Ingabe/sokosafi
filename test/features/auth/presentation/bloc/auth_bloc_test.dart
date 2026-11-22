import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/domain/failures/auth_failure.dart';
import 'package:sokosafi/features/auth/domain/repositories/auth_repository.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const customer = AppUser(
    uid: 'user-1',
    email: 'melyssa@example.com',
    name: 'Melyssa',
    phone: '0788123456',
    role: UserRole.customer,
    photoUrl: '',
    foodPreferences: <String>[],
    isEmailVerified: true,
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  AuthBloc buildBloc() => AuthBloc(authRepository: repository);

  /// Loading has stopped and a polite error message is showing.
  Matcher errorState(String message) => isA<AuthState>()
      .having((state) => state.isLoading, 'isLoading', false)
      .having((state) => state.feedback?.isError, 'isError', true)
      .having((state) => state.feedback?.message, 'message', message);

  /// Loading has stopped and a success message containing [fragment] is showing.
  Matcher successState(String fragment) => isA<AuthState>()
      .having((state) => state.isLoading, 'isLoading', false)
      .having((state) => state.feedback?.isError, 'isError', false)
      .having(
        (state) => state.feedback?.message,
        'message',
        contains(fragment),
      );

  group('session stream', () {
    blocTest<AuthBloc, AuthState>(
      'becomes authenticated when a signed-in user is streamed',
      build: () {
        when(() => repository.watchUser())
            .thenAnswer((_) => Stream<AppUser?>.value(customer));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated, user: customer),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'becomes unauthenticated when no user is streamed',
      build: () {
        when(() => repository.watchUser())
            .thenAnswer((_) => Stream<AppUser?>.value(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );

    blocTest<AuthBloc, AuthState>(
      'becomes unauthenticated with a polite message when the stream fails',
      build: () {
        when(
          () => repository.watchUser(),
        ).thenAnswer((_) => Stream<AppUser?>.error(Exception('stream failed')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        isA<AuthState>()
            .having(
              (state) => state.status,
              'status',
              AuthStatus.unauthenticated,
            )
            .having(
              (state) => state.feedback?.message,
              'message',
              AuthFailure.genericMessage,
            ),
      ],
    );
  });

  group('email login', () {
    blocTest<AuthBloc, AuthState>(
      'shows loading and then stops when login succeeds',
      build: () {
        when(
          () => repository.signInWithEmail(
            email: 'melyssa@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthEmailLoginRequested(
          email: 'melyssa@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [const AuthState(isLoading: true), const AuthState()],
    );

    blocTest<AuthBloc, AuthState>(
      'shows a polite error when login fails',
      build: () {
        when(
          () => repository.signInWithEmail(
            email: 'melyssa@example.com',
            password: 'wrong-password',
          ),
        ).thenThrow(const AuthFailure('Wrong email or password, try again'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthEmailLoginRequested(
          email: 'melyssa@example.com',
          password: 'wrong-password',
        ),
      ),
      expect: () => [
        const AuthState(isLoading: true),
        errorState('Wrong email or password, try again'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'shows a generic message when something unexpected goes wrong',
      build: () {
        when(
          () => repository.signInWithEmail(
            email: 'melyssa@example.com',
            password: 'password123',
          ),
        ).thenThrow(Exception('unexpected'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthEmailLoginRequested(
          email: 'melyssa@example.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthState(isLoading: true),
        errorState(AuthFailure.genericMessage),
      ],
      errors: () => [isA<Exception>()],
    );
  });

  group('registration', () {
    blocTest<AuthBloc, AuthState>(
      'registers the user and stops loading',
      build: () {
        when(
          () => repository.register(
            name: 'Melyssa',
            email: 'melyssa@example.com',
            phone: '0788123456',
            password: 'password123',
          ),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          name: 'Melyssa',
          email: 'melyssa@example.com',
          phone: '0788123456',
          password: 'password123',
        ),
      ),
      expect: () => [const AuthState(isLoading: true), const AuthState()],
    );

    blocTest<AuthBloc, AuthState>(
      'shows a polite error when the email is already registered',
      build: () {
        when(
          () => repository.register(
            name: 'Melyssa',
            email: 'melyssa@example.com',
            phone: '0788123456',
            password: 'password123',
          ),
        ).thenThrow(const AuthFailure('This email is already registered'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AuthRegisterRequested(
          name: 'Melyssa',
          email: 'melyssa@example.com',
          phone: '0788123456',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthState(isLoading: true),
        errorState('This email is already registered'),
      ],
    );
  });

  group('google login', () {
    blocTest<AuthBloc, AuthState>(
      'shows loading and then stops when google login succeeds',
      build: () {
        when(() => repository.signInWithGoogle()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleLoginRequested()),
      expect: () => [const AuthState(isLoading: true), const AuthState()],
    );

    blocTest<AuthBloc, AuthState>(
      'shows a polite error when google login fails',
      build: () {
        when(() => repository.signInWithGoogle()).thenThrow(
          const AuthFailure('Google sign-in did not work. Try again'),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthGoogleLoginRequested()),
      expect: () => [
        const AuthState(isLoading: true),
        errorState('Google sign-in did not work. Try again'),
      ],
    );
  });

  group('password reset', () {
    blocTest<AuthBloc, AuthState>(
      'confirms the reset link without revealing whether the account exists',
      build: () {
        when(() => repository.sendPasswordReset('melyssa@example.com'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AuthPasswordResetRequested('melyssa@example.com')),
      expect: () => [
        const AuthState(isLoading: true),
        successState('reset link'),
      ],
    );
  });

  group('email verification', () {
    blocTest<AuthBloc, AuthState>(
      'confirms that the verification email was sent again',
      build: () {
        when(() => repository.resendVerificationEmail())
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthVerificationEmailResendRequested()),
      expect: () => [
        const AuthState(isLoading: true),
        successState('Verification email sent'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'shows no message when the email is now verified',
      build: () {
        when(() => repository.reloadUser()).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthVerificationChecked()),
      expect: () => [const AuthState(isLoading: true), const AuthState()],
    );

    blocTest<AuthBloc, AuthState>(
      'asks the user to open the link when the email is still not verified',
      build: () {
        when(() => repository.reloadUser()).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthVerificationChecked()),
      expect: () => [
        const AuthState(isLoading: true),
        isA<AuthState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.feedback?.isError, 'isError', true)
            .having(
              (state) => state.feedback?.message,
              'message',
              contains('not verified yet'),
            ),
      ],
    );
  });

  group('logout', () {
    blocTest<AuthBloc, AuthState>(
      'signs out through the repository',
      build: () {
        when(() => repository.signOut()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthState(isLoading: true), const AuthState()],
      verify: (_) => verify(() => repository.signOut()).called(1),
    );
  });
}
