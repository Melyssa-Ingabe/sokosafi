import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/business_setup/data/repositories/device_location_repository.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_discovery_repository.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/feed_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/feed_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/product_detail_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/saved_merchants_screen.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/customer_shell.dart';
import 'package:sokosafi/features/orders/presentation/orders_routes.dart';
import 'package:sokosafi/features/profile/presentation/profile_routes.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The customer side: the bottom navigation with its tabs, and the listing
/// detail that opens over it. The redirect only lets signed-in users reach
/// these.
List<RouteBase> buildDiscoveryRoutes({
  DiscoveryRepository Function()? repository,
  LocationRepository Function()? locationRepository,
}) {
  final createRepository = repository ?? FirestoreDiscoveryRepository.new;
  final createLocationRepository =
      locationRepository ?? DeviceLocationRepository.new;

  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          CustomerShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.customerHome,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BlocProvider(
                  create: (context) =>
                      FeedCubit(
                          repository: createRepository(),
                          locationRepository: createLocationRepository(),
                          foodPreferences:
                              context
                                  .read<AuthBloc>()
                                  .state
                                  .user
                                  ?.foodPreferences ??
                              const [],
                        )
                        ..watch()
                        ..locate(),
                  child: const FeedScreen(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(routes: [buildMyOrdersRoute()]),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.savedMerchants,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: SavedMerchantsScreen(
                  discoveryRepository: createRepository(),
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(routes: [buildProfileRoute()]),
      ],
    ),
    GoRoute(
      path: AppRoutes.listingDetail,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) => ProductDetailCubit(
            repository: createRepository(),
            listingId: state.pathParameters['listingId'] ?? '',
          )..watch(),
          child: ProductDetailScreen(heroTag: state.extra),
        ),
      ),
    ),
  ];
}
