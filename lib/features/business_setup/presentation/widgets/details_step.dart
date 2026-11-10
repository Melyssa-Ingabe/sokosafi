import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/business_type_grid.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/setup_step_layout.dart';

/// Step 1: business name and type.
class DetailsStep extends StatelessWidget {
  const DetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessSetupBloc>();
    final state = context.watch<BusinessSetupBloc>().state;
    final theme = Theme.of(context);
    final typeError = state.typeError;

    return SetupStepLayout(
      title: "What's your business called?",
      subtitle: 'Customers will see this name.',
      actions: [
        PrimaryButton(
          label: 'Continue',
          onPressed: () => bloc.add(const SetupContinued()),
        ),
      ],
      children: [
        AppTextField(
          label: 'Business name',
          hint: 'e.g. Boulangerie de Kigali',
          initialValue: state.name,
          errorText: state.nameError,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: (name) => bloc.add(BusinessNameChanged(name)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'What kind of business?',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BusinessTypeGrid(
          selected: state.type,
          onSelected: (type) => bloc.add(BusinessTypeSelected(type)),
        ),
        if (typeError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            typeError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
