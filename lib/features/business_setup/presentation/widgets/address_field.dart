import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';

/// Address input with a "use my current location" button. Stateful only to
/// own the text controller, which is needed because GPS can fill the address
/// in for the owner.
class AddressField extends StatefulWidget {
  const AddressField({super.key});

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<BusinessSetupBloc>().state.address,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessSetupBloc>();
    return BlocConsumer<BusinessSetupBloc, BusinessSetupState>(
      // Copy an address filled in by the app into the field, without
      // fighting the owner while they type.
      listenWhen: (previous, current) => previous.address != current.address,
      listener: (context, state) {
        if (_controller.text != state.address) {
          _controller.value = TextEditingValue(
            text: state.address,
            selection: TextSelection.collapsed(offset: state.address.length),
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.isLocating != current.isLocating ||
          previous.addressError != current.addressError,
      builder: (context, state) {
        return AppTextField(
          label: 'Address or landmark',
          hint: 'e.g. KG 5 Ave, Kacyiru',
          controller: _controller,
          errorText: state.addressError,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.search,
          onChanged: (address) => bloc.add(BusinessAddressChanged(address)),
          onFieldSubmitted: (_) => bloc.add(const BusinessAddressSearched()),
          prefix: const Padding(
            padding: EdgeInsets.all(12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedLocation01,
              color: AppColors.accent,
            ),
          ),
          suffix: state.isLocating
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  tooltip: 'Use my current location',
                  onPressed: () => bloc.add(const CurrentLocationRequested()),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedGps01,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
        );
      },
    );
  }
}
