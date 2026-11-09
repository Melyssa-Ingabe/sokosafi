import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/menu_group.dart';
import 'package:sokosafi/core/widgets/menu_tile.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/core/widgets/start_selling_card.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:sokosafi/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:sokosafi/router/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null ? const LoadingView() : _ProfileContent(user: user),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <Widget>[
      Column(
        children: [
          ProfileAvatar(name: user.name, photoUrl: user.photoUrl),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.name.isEmpty ? 'Your name' : user.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const ProfileStatsRow(),
      if (user.role == UserRole.customer)
        StartSellingCard(onTap: () => context.push(AppRoutes.businessSetup)),
      MenuGroup(
        children: [
          MenuTile(
            icon: HugeIcons.strokeRoundedShoppingBag01,
            title: 'My orders',
            onTap: () => context.push(AppRoutes.myOrders),
          ),
          MenuTile(
            icon: HugeIcons.strokeRoundedUserEdit01,
            title: 'Edit profile',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          MenuTile(
            icon: HugeIcons.strokeRoundedSettings02,
            title: 'Settings',
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: sections.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
      itemBuilder: (context, index) =>
          StaggeredEntrance(index: index, child: sections[index]),
    );
  }
}
