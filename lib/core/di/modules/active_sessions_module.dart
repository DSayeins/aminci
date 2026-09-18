import 'package:get_it/get_it.dart';

import 'package:aminci/features/active_sessions/data/datasources/active_session_remote_datasource.dart';
import 'package:aminci/features/active_sessions/data/repositories/active_sessions_repository_impl.dart';
import 'package:aminci/features/active_sessions/domain/repository/active_sessions_repository.dart';
import 'package:aminci/features/active_sessions/domain/usecases/disconnect_session.dart';
import 'package:aminci/features/active_sessions/domain/usecases/get_active_sessions.dart';
import 'package:aminci/features/active_sessions/presentation/bloc/active_sessions_bloc.dart';

void registerActiveSessionsModule(GetIt sl) {
  sl.registerLazySingleton(() => const ActiveSessionRemoteDatasource());
  sl.registerLazySingleton<ActiveSessionsRepository>(() => ActiveSessionsRepositoryImpl(sl()));

  sl.registerFactory(() => GetActiveSessions(sl()));
  sl.registerFactory(() => DisconnectSession(sl()));

  sl.registerFactory(() => ActiveSessionsBloc(getActiveSessions: sl(), disconnectSession: sl()));
}
