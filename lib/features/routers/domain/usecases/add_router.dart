import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class AddRouter {
  final RoutersRepository _repository;
  const AddRouter(this._repository);

  Future<Either<Failure, MikroTikRouter>> call(MikroTikRouter router) => _repository.create(router);
}
