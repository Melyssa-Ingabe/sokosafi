import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/theme/app_theme.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';

class SokosafiApp extends StatelessWidget {
  const SokosafiApp({
    super.key,
    required this.authBloc,
    required this.settingsCubit,
    required this.router,
  });

  final AuthBloc authBloc;
  final SettingsCubit settingsCubit;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: BlocSelector<SettingsCubit, AppSettings, bool>(
        selector: (settings) => settings.isDarkMode,
        builder: (context, isDarkMode) {
          return MaterialApp.router(
            title: 'SokoSafi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
