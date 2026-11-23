import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/floating_nav_bar.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The business side's bottom navigation, drawn like the customer's:
/// Dashboard, Analytics, a "+ List" pill, Orders and Settings. Each tab
/// keeps its own screen alive when switching.
class BusinessShell extends StatelessWidget {
  const BusinessShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<FloatingNavItem> _items = [
    FloatingNavItem(label: 'Dashboard', icon: HugeIcons.strokeRoundedStore01),
    FloatingNavItem(
      label: 'Analytics',
      icon: HugeIcons.strokeRoundedAnalytics01,
    ),
    FloatingNavItem(
      label: 'List',
      icon: HugeIcons.strokeRoundedAdd01,
      showsLabel: true,
    ),
    FloatingNavItem(label: 'Orders', icon: HugeIcons.strokeRoundedInvoice01),
    FloatingNavItem(label: 'Settings', icon: HugeIcons.strokeRoundedUserCircle),
  ];

  /// Nav button to shell branch. The "+ List" pill (null) opens the
  /// listing form instead of a tab.
  static const List<int?> _branchForItem = [0, 2, null, 1, 3];

  void _onTap(BuildContext context, int itemIndex) {
    final branch = _branchForItem[itemIndex];
    if (branch == null) {
      context.push(AppRoutes.createListing);
      return;
    }
    // Tapping the open tab again returns it to its first screen.
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.md,
          ),
          child: FloatingNavBar(
            items: _items,
            selectedIndex: _branchForItem.indexOf(navigationShell.currentIndex),
            onTap: (index) => _onTap(context, index),
          ),
        ),
      ),
    );
  }
}
