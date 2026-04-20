import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class GetRouters {
  final RoutersRepository _repository;

  GetRouters(this._repository);

  Future<Either<Failure, List<MikroTikRouter>>> call() => _repository.getRouters();
}
