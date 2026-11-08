import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:sokosafi/core/app/sokosafi_app.dart';
import 'package:sokosafi/core/config/firebase_options.dart';
import 'package:sokosafi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authBloc = AuthBloc(authRepository: AuthRepositoryImpl())
    ..add(const AuthStarted());

  runApp(SokosafiApp(authBloc: authBloc, router: buildAppRouter(authBloc)));
}
