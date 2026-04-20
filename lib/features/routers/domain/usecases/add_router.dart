import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class AddRouter {
  final RoutersRepository _repository;

  AddRouter(this._repository);

  Future<Either<Failure, MikroTikRouter>> call({
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    required RouterOsVersion rosVersion,
  }) => _repository.addRouter(
        name: name,
        ip: ip,
        port: port,
        username: username,
        password: password,
        rosVersion: rosVersion,
      );
}
