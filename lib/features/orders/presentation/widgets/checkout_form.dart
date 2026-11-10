import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/utils/validators.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/checkout_business_card.dart';
import 'package:sokosafi/features/orders/presentation/widgets/checkout_summary_card.dart';
import 'package:sokosafi/features/orders/presentation/widgets/payment_method_option.dart';

/// The loaded checkout. Stateful only to own the form key and the mobile
/// money number controller; everything else lives in [CheckoutCubit].
class CheckoutForm extends StatefulWidget {
  const CheckoutForm({super.key, required this.state, required this.phone});

  final CheckoutState state;
  final String phone;

  @override
  State<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.phone,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CheckoutCubit>().placeOrder();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final state = widget.state;
    final item = state.item!;
    final sections = <Widget>[
      CheckoutBusinessCard(
        business: item.business,
        pickupBy: item.listing.pickupBy,
      ),
      CheckoutSummaryCard(
        state: state,
        onIncrease: cubit.increaseQuantity,
        onDecrease: cubit.decreaseQuantity,
      ),
      _PaymentSection(
        selected: state.paymentMethod,
        onSelected: cubit.selectPaymentMethod,
        numberField: AppTextField(
          label: 'Mobile money number',
          hint: '078 123 4567',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: Validators.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
    ];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              itemCount: sections.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) =>
                  StaggeredEntrance(index: index, child: sections[index]),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(AppSpacing.pagePadding),
            child: PrimaryButton(
              label: 'Confirm payment · ${Formatters.rwf(state.total)}',
              isLoading: state.isSubmitting,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.selected,
    required this.onSelected,
    required this.numberField,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;
  final Widget numberField;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final method in PaymentMethod.values) ...[
              if (method != PaymentMethod.values.first)
                const SizedBox(height: AppSpacing.md),
              PaymentMethodOption(
                method: method,
                isSelected: method == selected,
                onSelected: () => onSelected(method),
                details: numberField,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
