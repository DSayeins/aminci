import 'package:aminci/features/login/data/datasource/login_local_datasource.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:aminci/features/login/data/repositories/login_repository_impl.dart';
import 'package:aminci/features/login/domain/repository/login_repository.dart';
import 'package:aminci/features/login/domain/usecases/login.dart';

void registerLoginModule(GetIt sl) {
  sl.registerLazySingleton(() => LoginLocalDatasource(sl()));
  sl.registerLazySingleton<LoginRepository>(() => LoginRepositoryImpl(sl()));
  sl.registerFactory(() => Login(sl()));
  sl.registerFactory(() => LoginBloc(login: sl()));
}
