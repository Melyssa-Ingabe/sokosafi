import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/reviews/presentation/screens/rate_experience_screen.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Rate Experience, opened with AppRoutes.rateOrderFor(orderId).
List<GoRoute> buildReviewRoutes(AuthBloc authBloc) {
  return [
    GoRoute(
      path: AppRoutes.rateOrder,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: RateExperienceScreen(
          orderId: state.pathParameters['orderId'] ?? '',
          customerId: authBloc.state.user!.uid,
        ),
      ),
    ),
  ];
}
