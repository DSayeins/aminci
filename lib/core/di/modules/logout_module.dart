import 'package:get_it/get_it.dart';

import 'package:aminci/features/logout/data/datasource/logout_local_datasource.dart';
import 'package:aminci/features/logout/data/repositories/logout_repository_impl.dart';
import 'package:aminci/features/logout/domain/repository/logout_repository.dart';
import 'package:aminci/features/logout/domain/usecases/logout.dart';
import 'package:aminci/features/logout/presentation/bloc/logout_bloc.dart';

void registerLogoutModule(GetIt sl) {
  sl.registerLazySingleton(() => LogoutLocalDatasource(sl()));
  sl.registerLazySingleton<LogoutRepository>(() => LogoutRepositoryImpl(sl()));
  sl.registerFactory(() => Logout(sl()));
  sl.registerFactory(() => LogoutBloc(logout: sl()));
}
