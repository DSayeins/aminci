import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class DeleteRouter {
  final RoutersRepository _repository;

  DeleteRouter(this._repository);

  Future<Either<Failure, Unit>> call(int id) => _repository.deleteRouter(id);
}
