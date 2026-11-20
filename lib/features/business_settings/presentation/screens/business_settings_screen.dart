import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/menu_group.dart';
import 'package:sokosafi/core/widgets/menu_tile.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/business_settings/data/repositories/firestore_business_settings_repository.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';
import 'package:sokosafi/features/business_settings/presentation/bloc/business_settings_cubit.dart';
import 'package:sokosafi/features/business_settings/presentation/widgets/business_header_card.dart';
import 'package:sokosafi/features/business_settings/presentation/widgets/landmark_sheet.dart';
import 'package:sokosafi/features/business_settings/presentation/widgets/pickup_time_text.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sokosafi/router/app_routes.dart';

/// The owner's controls: accepting orders, pickup window and landmark,
/// auto-close, payout account and order alerts.
class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'Settings',
      builder: (context, business) => BlocProvider(
        create: (_) => BusinessSettingsCubit(
          repository: FirestoreBusinessSettingsRepository(),
          businessId: business.id,
          ownerId: ownerId,
        )..watch(),
        child: _SettingsView(business: business),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<BusinessSettingsCubit, BusinessSettingsState>(
        listenWhen: (previous, current) =>
            current.feedback != null && previous.feedback != current.feedback,
        listener: (context, state) {
          final feedback = state.feedback!;
          if (feedback.isError) {
            AppSnackBar.showError(context, feedback.message);
          } else {
            AppSnackBar.showSuccess(context, feedback.message);
          }
        },
        builder: (context, state) {
          final settings = state.settings;
          return switch (state.status) {
            BusinessSettingsStatus.loading => const LoadingView(),
            BusinessSettingsStatus.failure => EmptyView(
              title: 'We could not load your settings',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: context.read<BusinessSettingsCubit>().watch,
            ),
            BusinessSettingsStatus.ready when settings != null => _SettingsBody(
              business: business,
              settings: settings,
              state: state,
            ),
            BusinessSettingsStatus.ready => const LoadingView(),
          };
        },
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.business,
    required this.settings,
    required this.state,
  });

  final Business business;
  final BusinessSettings settings;
  final BusinessSettingsState state;

  Future<void> _pickPickupWindow(BuildContext context) async {
    final cubit = context.read<BusinessSettingsCubit>();
    final start = await showTimePicker(
      context: context,
      helpText: 'Pickup starts at',
      initialTime: PickupTimeText.toTimeOfDay(settings.pickupStart),
    );
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(
      context: context,
      helpText: 'Pickup ends at',
      initialTime: PickupTimeText.toTimeOfDay(settings.pickupEnd),
    );
    if (end == null) return;
    await cubit.setPickupWindow(
      start: PickupTimeText.fromTimeOfDay(start),
      end: PickupTimeText.fromTimeOfDay(end),
    );
  }

  Future<void> _editLandmark(BuildContext context) async {
    final cubit = context.read<BusinessSettingsCubit>();
    final landmark = await LandmarkSheet.show(context, settings.landmark);
    if (landmark != null) await cubit.setLandmark(landmark);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BusinessSettingsCubit>();
    final payout = state.payoutAccount;
    final payoutTitle = payout?.provider?.label ?? 'Mobile Money';
    final payoutValue = switch (payout) {
      null => 'Loading',
      _ when payout.maskedNumber.isEmpty => 'Add your number',
      _ => payout.maskedNumber,
    };
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        BusinessHeaderCard(business: business),
        const SizedBox(height: AppSpacing.lg),
        MenuGroup(
          children: [
            MenuTile(
              icon: HugeIcons.strokeRoundedStore01,
              title: 'Accepting orders',
              trailing: Switch.adaptive(
                value: settings.acceptingOrders,
                onChanged: cubit.setAcceptingOrders,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        MenuGroup(
          title: 'Operations',
          children: [
            MenuTile(
              icon: HugeIcons.strokeRoundedClock01,
              title: 'Pickup window',
              value: '${settings.pickupStart} – ${settings.pickupEnd}',
              onTap: () => _pickPickupWindow(context),
            ),
            MenuTile(
              icon: HugeIcons.strokeRoundedLocation01,
              title: 'Pickup landmark',
              value: settings.landmark.isEmpty ? 'Add' : settings.landmark,
              onTap: () => _editLandmark(context),
            ),
            MenuTile(
              icon: HugeIcons.strokeRoundedPackageRemove,
              title: 'Auto-close when sold out',
              trailing: Switch.adaptive(
                value: settings.autoClose,
                onChanged: cubit.setAutoClose,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        MenuGroup(
          title: 'Payout account',
          children: [
            MenuTile(
              icon: HugeIcons.strokeRoundedWallet01,
              title: payoutTitle,
              value: payoutValue,
              // The payout number is the owner's profile phone, edited on
              // Prince's Edit Profile screen rather than stored twice.
              onTap: () => context.push(AppRoutes.editProfile),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        MenuGroup(
          title: 'Notifications',
          children: [
            // Order alerts are a phone setting, so they reuse the
            // notifications preference SettingsCubit keeps in
            // SharedPreferences.
            BlocSelector<SettingsCubit, AppSettings, bool>(
              selector: (appSettings) => appSettings.notificationsEnabled,
              builder: (context, isEnabled) => MenuTile(
                icon: HugeIcons.strokeRoundedNotification01,
                title: 'Order sound alerts',
                trailing: Switch.adaptive(
                  value: isEnabled,
                  onChanged: context
                      .read<SettingsCubit>()
                      .setNotificationsEnabled,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        MenuGroup(
          children: [
            MenuTile(
              icon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
              title: 'Switch to customer account',
              onTap: () => context.go(AppRoutes.customerHome),
            ),
            MenuTile(
              icon: HugeIcons.strokeRoundedLogout01,
              title: 'Log out',
              isDestructive: true,
              onTap: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            ),
          ],
        ),
      ],
    );
  }
}
