import 'package:get_it/get_it.dart';

import 'package:aminci/features/hotspot/data/datasources/hotspot_remote_datasource.dart';
import 'package:aminci/features/hotspot/data/repositories/hotspot_repository_impl.dart';
import 'package:aminci/features/hotspot/domain/repository/hotspot_repository.dart';
import 'package:aminci/features/hotspot/domain/usecases/get_hotspots.dart';
import 'package:aminci/features/hotspot/presentation/bloc/hotspot_bloc.dart';

void registerHotspotModule(GetIt sl) {
  sl.registerLazySingleton(() => const HotspotRemoteDatasource());
  sl.registerLazySingleton<HotspotRepository>(() => HotspotRepositoryImpl(sl()));

  sl.registerFactory(() => GetHotspots(sl()));

  sl.registerFactory(() => HotspotBloc(getHotspots: sl()));
}
