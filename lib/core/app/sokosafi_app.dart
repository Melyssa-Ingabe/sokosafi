import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/theme/app_theme.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';

class SokosafiApp extends StatelessWidget {
  const SokosafiApp({super.key, required this.authBloc, required this.router});

  final AuthBloc authBloc;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'SokoSafi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    );
  }
}
