import 'package:get_it/get_it.dart';

import 'package:aminci/features/routers/data/datasources/router_local_datasource.dart';
import 'package:aminci/features/routers/data/repositories/routers_repository_impl.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';
import 'package:aminci/features/routers/domain/usecases/add_router.dart';
import 'package:aminci/features/routers/domain/usecases/delete_router.dart';
import 'package:aminci/features/routers/domain/usecases/get_routers.dart';
import 'package:aminci/features/routers/domain/usecases/update_router.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

void registerRoutersModule(GetIt sl) {
  sl.registerLazySingleton<RouterLocalDatasource>(() => RouterLocalDatasourceImpl(sl()));
  sl.registerLazySingleton<RoutersRepository>(() => RoutersRepositoryImpl(sl()));

  sl.registerFactory(() => GetRouters(sl()));
  sl.registerFactory(() => AddRouter(sl()));
  sl.registerFactory(() => UpdateRouter(sl()));
  sl.registerFactory(() => DeleteRouter(sl()));

  sl.registerFactory(() => RoutersBloc(
        getRouters: sl(),
        addRouter: sl(),
        updateRouter: sl(),
        deleteRouter: sl(),
      ));
}
