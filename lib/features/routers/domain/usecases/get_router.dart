import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class GetRouter {
  final RoutersRepository _repository;

  GetRouter(this._repository);

  Future<Either<Failure, MikroTikRouter>> call(int id) => _repository.getRouter(id);
}
