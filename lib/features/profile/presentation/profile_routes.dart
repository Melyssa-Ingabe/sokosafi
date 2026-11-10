import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/orders/data/repositories/firestore_orders_repository.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:sokosafi/features/profile/data/repositories/firestore_profile_repository.dart';
import 'package:sokosafi/features/profile/domain/repositories/profile_repository.dart';
import 'package:sokosafi/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:sokosafi/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:sokosafi/features/profile/presentation/screens/profile_screen.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

List<GoRoute> buildProfileRoutes({
  OrdersRepository Function()? ordersRepository,
  ProfileRepository Function()? profileRepository,
}) {
  final createOrdersRepository =
      ordersRepository ?? FirestoreOrdersRepository.new;
  final createProfileRepository =
      profileRepository ?? FirestoreProfileRepository.new;
  return [
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) => MyOrdersCubit(
            repository: createOrdersRepository(),
            customerId: context.read<AuthBloc>().state.user?.uid ?? '',
          )..watch(),
          child: const ProfileScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) => EditProfileCubit(
            repository: createProfileRepository(),
            uid: context.read<AuthBloc>().state.user?.uid ?? '',
          ),
          child: const EditProfileScreen(),
        ),
      ),
    ),
  ];
}
