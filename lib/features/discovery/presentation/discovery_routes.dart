import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/business_setup/data/repositories/device_location_repository.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_discovery_repository.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_food_preferences_repository.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/domain/repositories/food_preferences_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/feed_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/food_preferences_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/feed_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/food_preferences_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/product_detail_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/saved_merchants_screen.dart';
import 'package:sokosafi/features/discovery/presentation/screens/search_screen.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/customer_shell.dart';
import 'package:sokosafi/features/orders/presentation/orders_routes.dart';
import 'package:sokosafi/features/profile/presentation/profile_routes.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The customer side: the bottom navigation with its tabs, and the listing
/// detail and food preferences that open over it. The redirect only lets signed-in users reach
/// these.
List<RouteBase> buildDiscoveryRoutes({
  DiscoveryRepository Function()? repository,
  LocationRepository Function()? locationRepository,
  FoodPreferencesRepository Function()? foodPreferencesRepository,
}) {
  final createRepository = repository ?? FirestoreDiscoveryRepository.new;
  final createFoodPreferencesRepository =
      foodPreferencesRepository ?? FirestoreFoodPreferencesRepository.new;
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
              path: AppRoutes.search,
              pageBuilder: (context, state) => buildAppPage(
                state: state,
                child: BlocProvider(
                  create: (context) =>
                      SearchCubit(
                          repository: createRepository(),
                          locationRepository: createLocationRepository(),
                          // The default distance comes from Prince's settings.
                          defaultRadiusKm: context
                              .read<SettingsCubit>()
                              .state
                              .searchRadiusKm,
                        )
                        ..watch()
                        ..locate(),
                  child: const SearchScreen(),
                ),
              ),
            ),
          ],
        ),
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
    GoRoute(
      path: AppRoutes.foodPreferences,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) {
            final user = context.read<AuthBloc>().state.user;
            return FoodPreferencesCubit(
              repository: createFoodPreferencesRepository(),
              uid: user?.uid ?? '',
              current: user?.foodPreferences ?? const [],
            );
          },
          child: const FoodPreferencesScreen(),
        ),
      ),
    ),
  ];
}
