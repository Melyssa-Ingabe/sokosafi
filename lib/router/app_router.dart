import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/widgets/placeholder_screen.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/auth/presentation/screens/splash_screen.dart';
import 'package:sokosafi/features/orders/presentation/orders_routes.dart';
import 'package:sokosafi/features/profile/presentation/profile_routes.dart';
import 'package:sokosafi/features/settings/presentation/screens/settings_screen.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';
import 'package:sokosafi/router/auth_redirect.dart';
import 'package:sokosafi/router/go_router_refresh_stream.dart';

/// Builds the app router. To add a screen: add its path to [AppRoutes], then
/// add a GoRoute below that uses [buildAppPage]. Replace a PlaceholderScreen
/// route with your real screen rather than adding a second route.
GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // Only re-check redirects when the session changes, not on every
    // loading or message update.
    refreshListenable: GoRouterRefreshStream(
      authBloc.stream.distinct(
        (previous, current) =>
            previous.status == current.status && previous.user == current.user,
      ),
    ),
    redirect: (context, state) => authRedirect(
      authState: authBloc.state,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            buildAppPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: const PlaceholderScreen(title: 'Login'),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: const PlaceholderScreen(title: 'Register'),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: const PlaceholderScreen(title: 'Forgot password'),
        ),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: PlaceholderScreen(
            title: 'Verify email',
            onLogout: () => authBloc.add(const AuthLogoutRequested()),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: PlaceholderScreen(
            title: 'Customer feed',
            onLogout: () => authBloc.add(const AuthLogoutRequested()),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.businessHome,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: PlaceholderScreen(
            title: 'Business dashboard',
            onLogout: () => authBloc.add(const AuthLogoutRequested()),
          ),
        ),
      ),
      ...buildOrdersRoutes(),
      ...buildProfileRoutes(),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) =>
            buildAppPage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.businessSetup,
        pageBuilder: (context, state) => buildAppPage(
          state: state,
          child: const PlaceholderScreen(title: 'Business setup'),
        ),
      ),
    ],
  );
}
