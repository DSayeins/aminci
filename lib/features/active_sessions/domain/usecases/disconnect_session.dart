import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/domain/repository/active_sessions_repository.dart';

class DisconnectSession {
  final ActiveSessionsRepository _repository;
  const DisconnectSession(this._repository);

  Future<Either<Failure, void>> call(MikroTikRouter router, ActiveSession session) =>
      _repository.disconnect(router, session);
}
