import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/staggered_fade_in.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/feed_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/feed_header.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/feed_section_row.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/location_notice.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The customer's home: surplus food on sale now, in rows by category.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const String _defaultArea = 'Kigali';

  @override
  Widget build(BuildContext context) {
    // Saving Food Preferences updates the profile, which the auth stream
    // passes on here, so the rows reorder without reloading the feed.
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => !listEquals(
        previous.user?.foodPreferences,
        current.user?.foodPreferences,
      ),
      listener: (context, state) => context
          .read<FeedCubit>()
          .updateFoodPreferences(state.user?.foodPreferences ?? const []),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<FeedCubit, FeedState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == FeedStatus.failure,
            listener: (context, state) => AppSnackBar.showError(
              context,
              state.errorMessage ?? 'We could not load the food',
            ),
            builder: (context, state) {
              final header = _FeedTop(state: state);
              return switch (state.status) {
                FeedStatus.loading => Column(
                  children: [
                    header,
                    const Expanded(
                      child: LoadingView(
                        message: 'Finding surplus food nearby',
                      ),
                    ),
                  ],
                ),
                FeedStatus.failure => Column(
                  children: [
                    header,
                    Expanded(
                      child: EmptyView(
                        title: 'We could not load the food',
                        message: state.errorMessage,
                        actionLabel: 'Try again',
                        onAction: context.read<FeedCubit>().watch,
                      ),
                    ),
                  ],
                ),
                FeedStatus.ready when state.isEmpty => Column(
                  children: [
                    header,
                    const Expanded(
                      child: EmptyView(
                        title: 'No surplus food right now',
                        message:
                            'Shops post food through the day. New listings '
                            'show up here as soon as they go live.',
                      ),
                    ),
                  ],
                ),
                FeedStatus.ready => _FeedList(state: state, header: header),
              };
            },
          ),
        ),
      ),
    );
  }
}

/// Header plus the location notice, shared by every state of the screen.
class _FeedTop extends StatelessWidget {
  const _FeedTop({required this.state});

  final FeedState state;

  @override
  Widget build(BuildContext context) {
    final area = state.userLocation?.neighborhood ?? '';
    final message = state.locationMessage;
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          FeedHeader(
            locationLabel: area.isEmpty ? FeedScreen._defaultArea : area,
            userName: user?.name ?? '',
            photoUrl: user?.photoUrl ?? '',
            onProfileTap: () => context.go(AppRoutes.profile),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            LocationNotice(
              message: message,
              onRetry: context.read<FeedCubit>().locate,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.state, required this.header});

  final FeedState state;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final sections = state.sections;
    // The header scrolls with the rows so landscape keeps room for food.
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: sections.length + 1,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        if (index == 0) return header;
        final section = sections[index - 1];
        return StaggeredFadeIn(
          index: index - 1,
          child: FeedSectionRow(
            section: section,
            distanceTo: state.distanceTo,
            onOpen: (item, heroTag) => context.push(
              AppRoutes.listingFor(item.listing.id),
              extra: heroTag,
            ),
          ),
        );
      },
    );
  }
}
