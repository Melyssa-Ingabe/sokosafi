import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

/// The customer side's bottom navigation: Discover, Orders and Profile.
/// Each tab keeps its own screen alive when switching, like BusinessShell.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Tapping the open tab again returns it to its first screen.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedStore01),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUserEdit01),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
