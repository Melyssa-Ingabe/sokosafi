import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The customer side's bottom navigation, drawn like
/// "Navigation/Customer alternate" in Figma: a row of floating white
/// circles. Each tab keeps its own screen alive when switching, like
/// BusinessShell.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// In the same order as the shell's branches.
  static const List<_Destination> _destinations = [
    _Destination(label: 'Discover', icon: HugeIcons.strokeRoundedStore01),
    _Destination(label: 'Orders', icon: HugeIcons.strokeRoundedShoppingBag01),
    _Destination(label: 'Saved', icon: HugeIcons.strokeRoundedFavourite),
    _Destination(label: 'Profile', icon: HugeIcons.strokeRoundedUser),
  ];

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (index, destination) in _destinations.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.md),
                _NavCircle(
                  destination: destination,
                  isSelected: index == navigationShell.currentIndex,
                  // Tapping the open tab again returns it to its first
                  // screen.
                  onTap: () => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({required this.label, required this.icon});

  final String label;
  final List<List<dynamic>> icon;
}

class _NavCircle extends StatelessWidget {
  const _NavCircle({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      excludeSemantics: true,
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: isSelected ? AppColors.brandSubtle : AppColors.surface,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: AppSpacing.minTapTarget,
              child: Center(
                child: HugeIcon(
                  icon: destination.icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
