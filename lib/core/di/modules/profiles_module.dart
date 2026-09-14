import 'package:get_it/get_it.dart';

import 'package:aminci/features/profiles/data/datasources/profile_local_datasource.dart';
import 'package:aminci/features/profiles/data/datasources/profile_remote_datasource.dart';
import 'package:aminci/features/profiles/data/repositories/profiles_repository_impl.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';
import 'package:aminci/features/profiles/domain/usecases/create_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profiles.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';

void registerProfilesModule(GetIt sl) {
  sl.registerLazySingleton(() => const ProfileRemoteDatasource());
  sl.registerLazySingleton(() => ProfileLocalDatasource(sl()));
  sl.registerLazySingleton<ProfilesRepository>(() => ProfilesRepositoryImpl(sl(), sl()));

  sl.registerFactory(() => GetProfiles(sl()));
  sl.registerFactory(() => CreateProfile(sl()));
  sl.registerFactory(() => DeleteProfile(sl()));

  sl.registerFactory(() => ProfilesBloc(getProfiles: sl(), createProfile: sl(), deleteProfile: sl()));
}
