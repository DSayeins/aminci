import 'package:get_it/get_it.dart';

import 'package:aminci/features/setup/data/datasources/setup_local_datasource.dart';
import 'package:aminci/features/setup/data/repositories/setup_repository_impl.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';
import 'package:aminci/features/setup/domain/usecases/create_setup.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';

void registerSetupModule(GetIt sl) {
  sl.registerLazySingleton(() => SetupLocalDatasourceImpl(sl()));
  sl.registerLazySingleton<SetupRepository>(() => SetupRepositoryImpl(sl()));
  sl.registerFactory(() => CreateSetup(sl()));
  sl.registerFactory(() => SetupBloc(createSetup: sl()));
}
