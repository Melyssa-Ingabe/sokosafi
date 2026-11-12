import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/business_analytics/presentation/screens/business_analytics_screen.dart';
import 'package:sokosafi/features/business_dashboard/presentation/screens/business_dashboard_screen.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/business_shell.dart';
import 'package:sokosafi/features/business_orders/presentation/screens/business_orders_screen.dart';
import 'package:sokosafi/features/business_orders/presentation/screens/confirm_pickup_screen.dart';
import 'package:sokosafi/features/business_settings/presentation/screens/business_settings_screen.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The business side of the app. The redirect only lets signed-in users
/// reach these, so the user is never null here.
List<RouteBase> buildBusinessRoutes(AuthBloc authBloc) {
  String ownerId() => authBloc.state.user!.uid;

  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          BusinessShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.businessHome,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BusinessDashboardScreen(ownerId: ownerId()),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.businessOrders,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BusinessOrdersScreen(ownerId: ownerId()),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.businessAnalytics,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BusinessAnalyticsScreen(ownerId: ownerId()),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.businessSettings,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BusinessSettingsScreen(ownerId: ownerId()),
              ),
            ),
          ],
        ),
      ],
    ),
    // Outside the shell so the scanner covers the bottom navigation.
    GoRoute(
      path: AppRoutes.confirmPickup,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: ConfirmPickupScreen(ownerId: ownerId()),
      ),
    ),
  ];
}
