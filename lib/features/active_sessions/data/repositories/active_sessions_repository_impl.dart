import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/data/datasources/active_session_remote_datasource.dart';
import 'package:aminci/features/active_sessions/domain/repository/active_sessions_repository.dart';

class ActiveSessionsRepositoryImpl implements ActiveSessionsRepository {
  final ActiveSessionRemoteDatasource _remote;

  const ActiveSessionsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ActiveSession>>> getActiveSessions(MikroTikRouter router) {
    return ErrorMapper.guard(
      () => _remote.getActiveSessions(router),
      fallbackMessage: 'Impossible de charger les sessions actives',
    );
  }

  @override
  Future<Either<Failure, void>> disconnect(MikroTikRouter router, ActiveSession session) {
    return ErrorMapper.guard(
      () => _remote.disconnect(router, session.mikrotikId),
      fallbackMessage: 'Impossible de déconnecter la session',
    );
  }
}
