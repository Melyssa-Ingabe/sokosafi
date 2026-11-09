import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/address_field.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/location_map.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/neighborhood_tile.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/setup_step_layout.dart';

/// Step 2: address, map pin and detected neighborhood.
class LocationStep extends StatelessWidget {
  const LocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessSetupBloc>();
    final theme = Theme.of(context);
    final hintStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return SetupStepLayout(
      title: "Where's your business?",
      subtitle: 'Nearby customers will discover your food.',
      actions: [
        PrimaryButton(
          label: 'Continue',
          onPressed: () => bloc.add(const SetupContinued()),
        ),
      ],
      children: [
        const AddressField(),
        const SizedBox(height: AppSpacing.lg),
        const SizedBox(height: 220, child: LocationMap()),
        const SizedBox(height: AppSpacing.sm),
        BlocBuilder<BusinessSetupBloc, BusinessSetupState>(
          buildWhen: (previous, current) =>
              previous.locationError != current.locationError,
          builder: (context, state) {
            final locationError = state.locationError;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCursorMove01,
                  size: 16,
                  color: locationError != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    locationError ?? 'Move the map to put the pin on your door',
                    style: locationError != null
                        ? hintStyle?.copyWith(color: theme.colorScheme.error)
                        : hintStyle,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Neighborhood',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        BlocSelector<BusinessSetupBloc, BusinessSetupState, String>(
          selector: (state) => state.neighborhood,
          builder: (context, neighborhood) =>
              NeighborhoodTile(neighborhood: neighborhood),
        ),
      ],
    );
  }
}
