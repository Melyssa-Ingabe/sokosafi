import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/storage/device_photo_picker.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/date_time_picker.dart';
import 'package:sokosafi/core/widgets/now_ticker.dart';
import 'package:sokosafi/core/widgets/photo_source_sheet.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/listings/data/repositories/firestore_listing_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_templates.dart';
import 'package:sokosafi/features/listings/domain/validation/listing_validator.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_bloc.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_form_cubit.dart';
import 'package:sokosafi/features/listings/presentation/widgets/category_selector.dart';
import 'package:sokosafi/features/listings/presentation/widgets/date_time_tile.dart';
import 'package:sokosafi/features/listings/presentation/widgets/form_section_card.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_photo_field.dart';
import 'package:sokosafi/features/listings/presentation/widgets/quantity_stepper.dart';
import 'package:sokosafi/features/listings/presentation/widgets/rwf_suffix.dart';
import 'package:sokosafi/features/listings/presentation/widgets/savings_line.dart';
import 'package:sokosafi/features/listings/presentation/widgets/template_chips.dart';
import 'package:sokosafi/router/app_routes.dart';

/// "Seller / Add product" and "Edit listing". With [initialListing] the form
/// is prefilled and saves changes to that listing.
class ListingFormScreen extends StatelessWidget {
  const ListingFormScreen({
    super.key,
    required this.ownerId,
    this.initialListing,
  });

  final String ownerId;
  final Listing? initialListing;

  @override
  Widget build(BuildContext context) {
    final isEditing = initialListing != null;
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: isEditing ? 'Edit listing' : 'Create listing',
      builder: (context, business) {
        final repository = FirestoreListingRepository();
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ListingFormCubit(
                listingRepository: repository,
                photoPicker: DevicePhotoPicker(),
                imageStorage: const UnavailableImageStorage(),
                businessId: business.id,
                initialListing: initialListing,
              ),
            ),
            // Past listings feed the "Recent templates" row.
            if (!isEditing)
              BlocProvider(
                create: (_) =>
                    ListingBloc(listingRepository: repository)
                      ..add(ListingsSubscriptionRequested(business.id)),
              ),
          ],
          child: const _ListingFormView(),
        );
      },
    );
  }
}

/// Stateful only to own the text controllers and the form key.
class _ListingFormView extends StatefulWidget {
  const _ListingFormView();

  @override
  State<_ListingFormView> createState() => _ListingFormViewState();
}

class _ListingFormViewState extends State<_ListingFormView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _originalPrice = TextEditingController();
  final _discountPrice = TextEditingController();
  final _instructions = TextEditingController();

  @override
  void initState() {
    super.initState();
    _copyPrefill(context.read<ListingFormCubit>().state.prefill);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _originalPrice.dispose();
    _discountPrice.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _copyPrefill(ListingPrefill? prefill) {
    if (prefill == null) return;
    _title.text = prefill.title;
    _description.text = prefill.description;
    _originalPrice.text = prefill.originalPrice;
    _discountPrice.text = prefill.discountPrice;
    _instructions.text = prefill.instructions;
  }

  void _pricesChanged(String _) {
    context.read<ListingFormCubit>().pricesChanged(
      originalPrice: _originalPrice.text,
      discountPrice: _discountPrice.text,
    );
  }

  void _submit() {
    // Shows the text-field errors; the cubit checks everything again.
    _formKey.currentState?.validate();
    context.read<ListingFormCubit>().submit(
      title: _title.text,
      description: _description.text,
      originalPrice: _originalPrice.text,
      discountPrice: _discountPrice.text,
      instructions: _instructions.text,
    );
  }

  Future<void> _choosePhoto() async {
    final cubit = context.read<ListingFormCubit>();
    final source = await PhotoSourceSheet.show(context);
    if (source != null) await cubit.photoRequested(source);
  }

  Future<void> _pickMadeAt(DateTime current) async {
    final cubit = context.read<ListingFormCubit>();
    final now = DateTime.now();
    final picked = await pickDateTime(
      context,
      initial: current,
      firstDate: now.subtract(const Duration(days: 3)),
      lastDate: now,
    );
    if (picked != null) cubit.madeAtChanged(picked);
  }

  Future<void> _pickPickupBy(DateTime current) async {
    final cubit = context.read<ListingFormCubit>();
    final now = DateTime.now();
    final picked = await pickDateTime(
      context,
      initial: current,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (picked != null) cubit.pickupByChanged(picked);
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.myListings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ListingFormCubit>();
    final theme = Theme.of(context);
    final digitsOnly = [FilteringTextInputFormatter.digitsOnly];

    return BlocListener<ListingFormCubit, ListingFormState>(
      listener: (context, state) {
        final feedback = state.feedback;
        if (feedback != null) {
          feedback.isError
              ? AppSnackBar.showError(context, feedback.message)
              : AppSnackBar.showSuccess(context, feedback.message);
        }
        if (state.status == ListingFormStatus.success) _close();
      },
      child: BlocBuilder<ListingFormCubit, ListingFormState>(
        builder: (context, state) {
          final now = DateTime.now();
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Close',
                onPressed: _close,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              title: Text(state.isEditing ? 'Edit listing' : 'Create listing'),
            ),
            body: BlocListener<ListingFormCubit, ListingFormState>(
              listenWhen: (previous, current) =>
                  previous.prefillRevision != current.prefillRevision,
              listener: (context, state) => _copyPrefill(state.prefill),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        children: [
                          if (!state.isEditing)
                            BlocBuilder<ListingBloc, ListingState>(
                              builder: (context, listingsState) =>
                                  TemplateChips(
                                    templates: ListingTemplates.recent(
                                      listingsState.listings,
                                    ),
                                    onSelected: cubit.templateApplied,
                                  ),
                            ),
                          ListingPhotoField(
                            photoPath: state.photoPath,
                            imageUrl: state.imageUrl,
                            onTap: _choosePhoto,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FormSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                  label: 'What are you selling?',
                                  hint: 'e.g. Fresh artisan breads',
                                  controller: _title,
                                  validator: ListingValidator.title,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  maxLength: ListingValidator.maxTitleLength,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  label: 'Description',
                                  hint: 'What is in it? Any allergens?',
                                  controller: _description,
                                  validator: ListingValidator.description,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  minLines: 2,
                                  maxLines: 4,
                                  maxLength:
                                      ListingValidator.maxDescriptionLength,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'CATEGORY',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                CategorySelector(
                                  selected: state.category,
                                  onSelected: cubit.categorySelected,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FormSectionCard(
                            child: Column(
                              children: [
                                QuantityStepper(
                                  quantity: state.quantity,
                                  errorText: state.quantityError,
                                  onDecrement: cubit.quantityDecremented,
                                  onIncrement: cubit.quantityIncremented,
                                ),
                                const Divider(height: AppSpacing.xl),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Original price',
                                        hint: '1000',
                                        controller: _originalPrice,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: digitsOnly,
                                        textInputAction: TextInputAction.next,
                                        validator:
                                            ListingValidator.originalPrice,
                                        onChanged: _pricesChanged,
                                        suffix: const RwfSuffix(),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Discount price',
                                        hint: '600',
                                        controller: _discountPrice,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: digitsOnly,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) =>
                                            ListingValidator.discountPrice(
                                              value,
                                              original: _originalPrice.text,
                                            ),
                                        onChanged: _pricesChanged,
                                        suffix: const RwfSuffix(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SavingsLine(percent: state.savingsPercent),
                          const SizedBox(height: AppSpacing.xl),
                          DateTimeTile(
                            label: 'Made at',
                            value: DateFormatters.dayAndTime(
                              state.madeAt,
                              now: now,
                            ),
                            errorText: state.madeAtError,
                            onTap: () => _pickMadeAt(state.madeAt),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Ticks so the "In 2h" chip counts down while the
                          // owner fills in the form.
                          NowTicker(
                            builder: (context, tickNow) => DateTimeTile(
                              label: 'Pickup deadline',
                              value: DateFormatters.dayAndTime(
                                state.pickupBy,
                                now: tickNow,
                              ),
                              badge: DateFormatters.timeUntil(
                                state.pickupBy,
                                now: tickNow,
                              ),
                              helperText: state.isEditing
                                  ? null
                                  : 'Default: 2 hours from now',
                              errorText: state.pickupByError,
                              onTap: () => _pickPickupBy(state.pickupBy),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'Pickup instructions (optional)',
                            hint:
                                'e.g. Come to the side entrance, ask for '
                                'Sarah at the counter',
                            controller: _instructions,
                            validator: ListingValidator.instructions,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: ListingValidator.maxInstructionsLength,
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          AppSpacing.sm,
                          AppSpacing.pagePadding,
                          AppSpacing.lg,
                        ),
                        child: PrimaryButton(
                          label: state.isEditing
                              ? 'Save changes'
                              : 'Confirm listing',
                          isLoading: state.isSubmitting,
                          onPressed: _submit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
