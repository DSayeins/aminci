import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/domain/repository/active_sessions_repository.dart';

class GetActiveSessions {
  final ActiveSessionsRepository _repository;
  const GetActiveSessions(this._repository);

  Future<Either<Failure, List<ActiveSession>>> call(MikroTikRouter router) => _repository.getActiveSessions(router);
}
