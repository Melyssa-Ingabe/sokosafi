import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/floating_nav_bar.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/nav_search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_field.dart';

/// The customer side's bottom navigation. Tapping search turns the whole
/// bar into a search box; closing it brings the buttons back. Each tab
/// keeps its own screen alive when switching.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int searchIndex = 2;

  /// In the same order as the shell's branches.
  static const List<FloatingNavItem> _items = [
    FloatingNavItem(label: 'Discover', icon: HugeIcons.strokeRoundedStore01),
    FloatingNavItem(
      label: 'Orders',
      icon: HugeIcons.strokeRoundedShoppingBag01,
    ),
    FloatingNavItem(
      label: 'search',
      icon: HugeIcons.strokeRoundedSearch01,
      showsLabel: true,
    ),
    FloatingNavItem(label: 'Saved', icon: HugeIcons.strokeRoundedFavourite),
    FloatingNavItem(label: 'Profile', icon: HugeIcons.strokeRoundedUser),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == searchIndex) {
      context.read<NavSearchCubit>().open(
        returnIndex: navigationShell.currentIndex == searchIndex
            ? 0
            : navigationShell.currentIndex,
      );
      navigationShell.goBranch(searchIndex);
      return;
    }
    // Tapping the open tab again returns it to its first screen.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _closeSearch(BuildContext context) {
    final navSearch = context.read<NavSearchCubit>();
    context.read<SearchCubit>().updateQuery('');
    FocusScope.of(context).unfocus();
    navSearch.dismiss();
    navigationShell.goBranch(navSearch.state.returnIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavSearchCubit, NavSearchState>(
      builder: (context, navSearch) {
        return PopScope(
          canPop: !navSearch.isSearching,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeSearch(context);
          },
          child: Scaffold(
            body: navigationShell,
            bottomNavigationBar: Padding(
              // Keeps the search box above the keyboard.
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: AnimatedSwitcher(
                    duration: AnimationConstants.pageTransition,
                    switchInCurve: AnimationConstants.pageCurve,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: navSearch.isSearching
                        ? SizedBox(
                            key: const ValueKey('search'),
                            height: AppSpacing.minTapTarget + AppSpacing.sm,
                            child: SearchField(
                              autofocus: true,
                              onChanged: context
                                  .read<SearchCubit>()
                                  .updateQuery,
                              onBack: () => _closeSearch(context),
                            ),
                          )
                        : FloatingNavBar(
                            key: const ValueKey('nav'),
                            items: _items,
                            selectedIndex: navigationShell.currentIndex,
                            onTap: (index) => _onTap(context, index),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
