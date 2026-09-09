import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/logout/domain/repository/logout_repository.dart';

class Logout {
  final LogoutRepository _repository;

  const Logout(this._repository);

  Future<Either<Failure, void>> call() => _repository.logout();
}
