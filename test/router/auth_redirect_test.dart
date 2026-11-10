import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/router/app_routes.dart';
import 'package:sokosafi/router/auth_redirect.dart';

AppUser _user({required UserRole role, required bool isEmailVerified}) {
  return AppUser(
    uid: 'user-1',
    email: 'melyssa@example.com',
    name: 'Melyssa',
    phone: '0788123456',
    role: role,
    photoUrl: '',
    foodPreferences: const <String>[],
    isEmailVerified: isEmailVerified,
  );
}

void main() {
  group('authRedirect', () {
    test(
      'keeps everyone on the splash screen while the session is unknown',
      () {
        const state = AuthState();
        expect(
          authRedirect(authState: state, location: AppRoutes.login),
          AppRoutes.splash,
        );
        expect(
          authRedirect(authState: state, location: AppRoutes.splash),
          isNull,
        );
      },
    );

    test('sends a signed-out user to login but allows the register page', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      expect(
        authRedirect(authState: state, location: AppRoutes.customerHome),
        AppRoutes.login,
      );
      expect(
        authRedirect(authState: state, location: AppRoutes.register),
        isNull,
      );
    });

    test('blocks an unverified user on the verify email page', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: _user(role: UserRole.customer, isEmailVerified: false),
      );
      expect(
        authRedirect(authState: state, location: AppRoutes.customerHome),
        AppRoutes.verifyEmail,
      );
      expect(
        authRedirect(authState: state, location: AppRoutes.verifyEmail),
        isNull,
      );
    });

    test('sends a verified customer from the splash screen to the feed', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: _user(role: UserRole.customer, isEmailVerified: true),
      );
      expect(
        authRedirect(authState: state, location: AppRoutes.splash),
        AppRoutes.customerHome,
      );
    });

    test('sends a verified business from login to the dashboard', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: _user(role: UserRole.business, isEmailVerified: true),
      );
      expect(
        authRedirect(authState: state, location: AppRoutes.login),
        AppRoutes.businessHome,
      );
    });

    test('leaves a verified user alone on any other page', () {
      final state = AuthState(
        status: AuthStatus.authenticated,
        user: _user(role: UserRole.customer, isEmailVerified: true),
      );
      expect(authRedirect(authState: state, location: '/listing/42'), isNull);
    });
  });
}
