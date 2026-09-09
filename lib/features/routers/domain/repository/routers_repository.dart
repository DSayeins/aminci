import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';

abstract class RoutersRepository {
  Future<Either<Failure, List<MikroTikRouter>>> getAll();
  Future<Either<Failure, MikroTikRouter>> create(MikroTikRouter router);
  Future<Either<Failure, MikroTikRouter>> update(MikroTikRouter router);
  Future<Either<Failure, void>> delete(int id);
  Future<Either<Failure, String>> testConnection(MikroTikRouter router);
}
