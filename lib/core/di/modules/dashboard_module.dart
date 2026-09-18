import 'package:get_it/get_it.dart';

import 'package:aminci/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:aminci/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:aminci/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:aminci/features/dashboard/domain/usecases/get_dashboard_metrics.dart';
import 'package:aminci/features/dashboard/presentation/bloc/dashboard_bloc.dart';

void registerDashboardModule(GetIt sl) {
  sl.registerLazySingleton(() => DashboardLocalDatasource(sl()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(sl()));

  sl.registerFactory(() => GetDashboardMetrics(sl()));

  sl.registerFactory(() => DashboardBloc(getDashboardMetrics: sl(), getActiveSessions: sl()));
}
