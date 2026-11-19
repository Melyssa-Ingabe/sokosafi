import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The customer side's bottom navigation, drawn like
/// "Navigation/Customer alternate" in Figma: a row of floating white
/// circles with a wider "search" pill in the middle. Each tab keeps its own
/// screen alive when switching, like BusinessShell.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// In the same order as the shell's branches.
  static const List<_Destination> _destinations = [
    _Destination(label: 'Discover', icon: HugeIcons.strokeRoundedStore01),
    _Destination(label: 'Orders', icon: HugeIcons.strokeRoundedShoppingBag01),
    _Destination(
      label: 'Search',
      icon: HugeIcons.strokeRoundedSearch01,
      showsLabel: true,
    ),
    _Destination(label: 'Saved', icon: HugeIcons.strokeRoundedFavourite),
    _Destination(label: 'Profile', icon: HugeIcons.strokeRoundedUser),
  ];

  static const double _gap = AppSpacing.md;
  static const double _pillWidth = 108;

  /// Room the bar needs with the search pill at full width.
  static double get _fullWidth =>
      AppSpacing.minTapTarget * (_destinations.length - 1) +
      _pillWidth +
      _gap * (_destinations.length - 1);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // On narrow phones the search pill becomes a circle like the
              // others, so the bar never overflows.
              final roomForPill = constraints.maxWidth >= _fullWidth;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final (index, destination) in _destinations.indexed) ...[
                    if (index > 0) const SizedBox(width: _gap),
                    _NavButton(
                      destination: destination,
                      showLabel: destination.showsLabel && roomForPill,
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    this.showsLabel = false,
  });

  final String label;
  final List<List<dynamic>> icon;

  /// Drawn as a pill with its label, like "search" in Figma.
  final bool showsLabel;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.showLabel,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool showLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textPrimary;
    final icon = HugeIcon(icon: destination.icon, size: 24, color: color);
    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      excludeSemantics: true,
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: isSelected ? AppColors.brandSubtle : AppColors.surface,
          shape: const StadiumBorder(),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: SizedBox(
              height: AppSpacing.minTapTarget,
              width: showLabel
                  ? CustomerShell._pillWidth
                  : AppSpacing.minTapTarget,
              child: showLabel
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon,
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          destination.label.toLowerCase(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: color),
                        ),
                      ],
                    )
                  : Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}
