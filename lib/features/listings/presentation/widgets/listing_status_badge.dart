import 'package:flutter/material.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// "Active", "Sold out" or "Expired", each with its own colors.
class ListingStatusBadge extends StatelessWidget {
  const ListingStatusBadge({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ListingStatus.active => AppBadge(
        label: 'Active',
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: AppColors.primary,
      ),
      ListingStatus.soldOut => AppBadge(
        label: 'Sold out',
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      ListingStatus.expired => AppBadge(
        label: 'Expired',
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: AppColors.error,
      ),
    };
  }
}
