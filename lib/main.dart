import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sokosafi/core/app/sokosafi_app.dart';
import 'package:sokosafi/core/config/firebase_options.dart';
import 'package:sokosafi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_saved_merchants_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';
import 'package:sokosafi/features/settings/data/repositories/settings_repository.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sokosafi/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final preferences = await SharedPreferences.getInstance();

  final authBloc = AuthBloc(authRepository: AuthRepositoryImpl())
    ..add(const AuthStarted());
  final settingsCubit = SettingsCubit(SettingsRepository(preferences));

  // Saved merchants are shared by the product heart and the Saved screen,
  // so one cubit lives for the whole app and follows whoever is signed in.
  final savedMerchantsCubit = SavedMerchantsCubit(
    repository: FirestoreSavedMerchantsRepository(),
  );
  authBloc.stream
      .map((state) => state.user?.uid)
      .distinct()
      .listen(savedMerchantsCubit.watchFor);

  runApp(
    SokosafiApp(
      authBloc: authBloc,
      settingsCubit: settingsCubit,
      savedMerchantsCubit: savedMerchantsCubit,
      router: buildAppRouter(authBloc),
    ),
  );
}
