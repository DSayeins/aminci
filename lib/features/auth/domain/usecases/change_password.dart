import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/auth/domain/repository/auth_repository.dart';

class ChangePassword {
  final AuthRepository _repository;

  const ChangePassword(this._repository);

  Future<Either<Failure, void>> call({
    required int userId,
    required String newPassword,
  }) =>
      _repository.changePassword(userId: userId, newPassword: newPassword);
}
