import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

/// The business side's bottom navigation: Dashboard, Orders, Analytics and
/// Settings. Each tab keeps its own screen alive when switching.
class BusinessShell extends StatelessWidget {
  const BusinessShell({super.key, required this.navigationShell});

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
            icon: HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedInvoice01),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
