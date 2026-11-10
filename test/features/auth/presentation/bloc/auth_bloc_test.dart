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

  blocTest<AuthBloc, AuthState>(
    'becomes authenticated when a signed-in user is streamed',
    build: () {
      when(() => repository.watchUser())
          .thenAnswer((_) => Stream<AppUser?>.value(customer));
      return AuthBloc(authRepository: repository);
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
      return AuthBloc(authRepository: repository);
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );

  blocTest<AuthBloc, AuthState>(
    'shows loading and then stops when login succeeds',
    build: () {
      when(
        () => repository.signInWithEmail(
          email: 'melyssa@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async {});
      return AuthBloc(authRepository: repository);
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
      return AuthBloc(authRepository: repository);
    },
    act: (bloc) => bloc.add(
      const AuthEmailLoginRequested(
        email: 'melyssa@example.com',
        password: 'wrong-password',
      ),
    ),
    expect: () => [
      const AuthState(isLoading: true),
      isA<AuthState>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having(
            (state) => state.feedback?.message,
            'message',
            'Wrong email or password, try again',
          ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'signs out through the repository on logout',
    build: () {
      when(() => repository.signOut()).thenAnswer((_) async {});
      return AuthBloc(authRepository: repository);
    },
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    verify: (_) => verify(() => repository.signOut()).called(1),
  );
}
