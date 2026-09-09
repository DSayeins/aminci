import 'package:get_it/get_it.dart';

import 'package:aminci/features/launch/data/datasource/launch_local_datasource.dart';
import 'package:aminci/features/launch/data/repositories/launch_repository_impl.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';
import 'package:aminci/features/launch/domain/usecases/initialize.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';

void registerLaunchModule(GetIt sl) {
  sl.registerLazySingleton<LaunchLocalDatasource>(() => LaunchLocalDatasourceImpl(sl()));
  sl.registerLazySingleton<LaunchRepository>(() => LaunchRepositoryImpl(sl()));

  sl.registerFactory(() => Initialize(sl()));

  sl.registerFactory(() => LaunchBloc(initialize: sl()));
}
