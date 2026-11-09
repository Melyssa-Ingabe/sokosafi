import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/widgets/menu_group.dart';
import 'package:sokosafi/core/widgets/menu_tile.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sokosafi/features/settings/presentation/widgets/options_sheet.dart';
import 'package:sokosafi/features/settings/presentation/widgets/settings_switch.dart';

class PreferencesGroup extends StatelessWidget {
  const PreferencesGroup({super.key});

  Future<void> _pickRadius(BuildContext context, AppSettings settings) async {
    final cubit = context.read<SettingsCubit>();
    final kilometres = await showOptionsSheet<int>(
      context: context,
      title: 'Default search distance',
      options: AppSettings.searchRadiusOptionsKm,
      selected: settings.searchRadiusKm,
      labelOf: (option) => '$option km',
    );
    if (kilometres != null) await cubit.setSearchRadius(kilometres);
  }

  Future<void> _pickPayment(BuildContext context, AppSettings settings) async {
    final cubit = context.read<SettingsCubit>();
    final method = await showOptionsSheet<PaymentMethod>(
      context: context,
      title: 'Preferred payment method',
      options: PaymentMethod.values,
      selected: settings.preferredPaymentMethod,
      labelOf: (option) => option.label,
    );
    if (method != null) await cubit.setPreferredPaymentMethod(method);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    return MenuGroup(
      title: 'Preferences',
      children: [
        MenuTile(
          icon: HugeIcons.strokeRoundedNotification01,
          title: 'Notifications',
          trailing: SettingsSwitch(
            value: settings.notificationsEnabled,
            onChanged: cubit.setNotificationsEnabled,
          ),
        ),
        MenuTile(
          icon: HugeIcons.strokeRoundedMoon02,
          title: 'Dark mode',
          trailing: SettingsSwitch(
            value: settings.isDarkMode,
            onChanged: cubit.setDarkMode,
          ),
        ),
        MenuTile(
          icon: HugeIcons.strokeRoundedLocation01,
          title: 'Search distance',
          value: '${settings.searchRadiusKm} km',
          onTap: () => _pickRadius(context, settings),
        ),
        MenuTile(
          icon: HugeIcons.strokeRoundedWallet01,
          title: 'Payment method',
          value: settings.preferredPaymentMethod.label,
          onTap: () => _pickPayment(context, settings),
        ),
      ],
    );
  }
}
