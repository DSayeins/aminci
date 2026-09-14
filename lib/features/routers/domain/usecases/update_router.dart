import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class UpdateRouter {
  final RoutersRepository _repository;
  const UpdateRouter(this._repository);

  Future<Either<Failure, MikroTikRouter>> call(MikroTikRouter router) => _repository.update(router);
}
