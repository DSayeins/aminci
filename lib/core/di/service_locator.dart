import 'package:aminci/features/app/data/app_repository_impl.dart';
import 'package:aminci/features/app/domain/repository/app_repository.dart';
import 'package:aminci/features/app/domain/usecases/get_user.dart';
import 'package:aminci/features/app/domain/usecases/logout.dart';
import 'package:aminci/features/profiles/data/profiles_repository_impl.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';
import 'package:aminci/features/profiles/domain/usecases/create_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/get_address_pools.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profiles.dart';
import 'package:aminci/features/profiles/domain/usecases/sync_profiles.dart';
import 'package:aminci/features/profiles/domain/usecases/clear_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/update_price.dart';
import 'package:aminci/features/profiles/domain/usecases/update_profile.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/vouchers/data/vouchers_repository_impl.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';
import 'package:aminci/features/vouchers/domain/usecases/delete_voucher.dart';
import 'package:aminci/features/vouchers/domain/usecases/generate_vouchers.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_hotspot_servers.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_vouchers.dart';
import 'package:aminci/features/vouchers/domain/usecases/print_vouchers.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aminci/features/auth/domain/repository/auth_repository.dart';
import 'package:aminci/features/auth/domain/usecases/change_password.dart';
import 'package:aminci/features/auth/domain/usecases/login.dart';
import 'package:aminci/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aminci/features/launch/data/repositories/launch_repository_impl.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';
import 'package:aminci/features/launch/domain/usecases/check_active_session.dart';
import 'package:aminci/features/launch/domain/usecases/check_first_launch.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/routers/data/routers_repository_impl.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';
import 'package:aminci/features/routers/domain/usecases/add_router.dart';
import 'package:aminci/features/routers/domain/usecases/delete_router.dart';
import 'package:aminci/features/routers/domain/usecases/get_routers.dart';
import 'package:aminci/features/routers/domain/usecases/test_connection.dart';
import 'package:aminci/features/routers/domain/usecases/update_router.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/setup/data/repositories/setup_repository_impl.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';
import 'package:aminci/features/setup/domain/usecases/create_admin_account.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';

final sl = GetIt.instance;

/// Initialise toutes les dépendances de l'application.
/// À appeler une seule fois dans [main] avant [runApp].
Future<void> setupServiceLocator() async {
  _registerCore();
  _registerApp();
  _registerLaunch();
  _registerAuth();
  _registerSetup();
  _registerRouters();
  _registerProfiles();
  _registerVouchers();
}

// -----------------------------------------------------------------------------
// Core
// -----------------------------------------------------------------------------

void _registerCore() {
  // Base de données — singleton permanent
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
}

// -----------------------------------------------------------------------------
// Feature : App (Navigation)
// -----------------------------------------------------------------------------

void _registerApp() {
  // Repository
  sl.registerLazySingleton<AppRepository>(() => AppRepositoryImpl(sl()));

  // Use cases
  sl.registerFactory(() => GetUser(sl()));
  sl.registerFactory(() => Logout(sl()));

  // BLoC
  sl.registerFactory(() => AppBloc(getUser: sl(), logout: sl()));
}

// -----------------------------------------------------------------------------
// Feature : Auth
// -----------------------------------------------------------------------------

void _registerAuth() {
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use cases
  sl.registerFactory(() => Login(sl()));
  sl.registerFactory(() => ChangePassword(sl()));

  // BLoC
  sl.registerFactory(() => AuthBloc(login: sl(), changePassword: sl()));
}

// -----------------------------------------------------------------------------
// Feature : Setup
// -----------------------------------------------------------------------------

void _registerSetup() {
  // Repository
  sl.registerLazySingleton<SetupRepository>(() => SetupRepositoryImpl(sl()));

  // Use case
  sl.registerFactory(() => CreateAdminAccount(sl()));

  // BLoC
  sl.registerFactory(() => SetupBloc(createAdminAccount: sl()));
}

// -----------------------------------------------------------------------------
// Feature : Routers
// -----------------------------------------------------------------------------

void _registerRouters() {
  sl.registerLazySingleton<RoutersRepository>(() => RoutersRepositoryImpl(sl()));

  sl.registerFactory(() => GetRouters(sl()));
  sl.registerFactory(() => AddRouter(sl()));
  sl.registerFactory(() => UpdateRouter(sl()));
  sl.registerFactory(() => DeleteRouter(sl()));
  sl.registerFactory(() => TestConnection(sl()));

  sl.registerFactory(
    () => RoutersBloc(getRouters: sl(), addRouter: sl(), updateRouter: sl(), deleteRouter: sl(), testConnection: sl()),
  );
}

// -----------------------------------------------------------------------------
// Feature : Launch
// -----------------------------------------------------------------------------

void _registerLaunch() {
  // Repository
  sl.registerLazySingleton<LaunchRepository>(() => LaunchRepositoryImpl(sl()));

  // Use cases
  sl.registerFactory(() => CheckFirstLaunch(sl()));
  sl.registerFactory(() => CheckActiveSession(sl()));

  // BLoC — factory car recréé à chaque navigation vers LaunchScreen
  sl.registerFactory(() => LaunchBloc(checkFirstLaunch: sl(), checkActiveSession: sl()));
}

// -----------------------------------------------------------------------------
// Feature : Vouchers
// -----------------------------------------------------------------------------

void _registerVouchers() {
  sl.registerLazySingleton<VouchersRepository>(() => VouchersRepositoryImpl(sl()));

  sl.registerFactory(() => GetVouchers(sl()));
  sl.registerFactory(() => GenerateVouchers(sl()));
  sl.registerFactory(() => DeleteVoucher(sl()));
  sl.registerFactory(() => GetHotspotServers(sl()));
  sl.registerFactory(() => PrintVouchers(sl()));

  sl.registerFactory(
    () => VouchersBloc(
      getVouchers: sl(),
      generateVouchers: sl(),
      deleteVoucher: sl(),
      getHotspotServers: sl(),
    ),
  );
}

// -----------------------------------------------------------------------------
// Profiles
// -----------------------------------------------------------------------------

void _registerProfiles() {
  // Repository
  sl.registerLazySingleton<ProfilesRepository>(() => ProfilesRepositoryImpl(sl()));

  // Use cases
  sl.registerFactory(() => GetProfiles(sl()));
  sl.registerFactory(() => GetAddressPools(sl()));
  sl.registerFactory(() => SyncProfiles(sl()));
  sl.registerFactory(() => CreateProfile(sl()));
  sl.registerFactory(() => UpdateProfile(sl()));
  sl.registerFactory(() => DeleteProfile(sl()));
  sl.registerFactory(() => UpdatePrice(sl()));
  sl.registerFactory(() => GetProfileUsers(sl()));
  sl.registerFactory(() => DeleteProfileUsers(sl()));
  sl.registerFactory(() => ClearProfileUsers(sl()));

  sl.registerFactory(() => ProfilesBloc(
        getProfiles: sl(),
        syncProfiles: sl(),
        createProfile: sl(),
        updateProfile: sl(),
        deleteProfile: sl(),
        updatePrice: sl(),
        getRouters: sl(),
      ));
}
