import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/router/app_routes.dart';

const Set<String> _authPages = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

/// Decides where the user must be, based on login state. Returns null when
/// the current location is already fine.
String? authRedirect({required AuthState authState, required String location}) {
  if (authState.status == AuthStatus.unknown) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = authState.user;
  final isAuthPage = _authPages.contains(location);

  if (user == null) {
    return isAuthPage ? null : AppRoutes.login;
  }

  // The app stays blocked until the email address is verified.
  if (!user.isEmailVerified) {
    return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
  }

  final isEntryPage =
      isAuthPage ||
      location == AppRoutes.splash ||
      location == AppRoutes.verifyEmail;
  if (!isEntryPage) return null;

  return user.role == UserRole.business
      ? AppRoutes.businessHome
      : AppRoutes.customerHome;
}
