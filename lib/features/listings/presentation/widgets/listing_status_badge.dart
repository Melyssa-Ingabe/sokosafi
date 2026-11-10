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
      ListingStatus.active => const AppBadge(
        label: 'Active',
        backgroundColor: AppColors.brandSubtle,
        foregroundColor: AppColors.primary,
      ),
      ListingStatus.soldOut => const AppBadge(
        label: 'Sold out',
        backgroundColor: AppColors.surfaceSubtle,
        foregroundColor: AppColors.textSecondary,
      ),
      ListingStatus.expired => const AppBadge(
        label: 'Expired',
        backgroundColor: AppColors.surfaceSubtle,
        foregroundColor: AppColors.error,
      ),
    };
  }
}
