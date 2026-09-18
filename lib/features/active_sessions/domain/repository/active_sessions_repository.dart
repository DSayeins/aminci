import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';

abstract class ActiveSessionsRepository {
  Future<Either<Failure, List<ActiveSession>>> getActiveSessions(MikroTikRouter router);
  Future<Either<Failure, void>> disconnect(MikroTikRouter router, ActiveSession session);
}
