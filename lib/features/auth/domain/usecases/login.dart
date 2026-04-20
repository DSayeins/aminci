import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';
import 'package:aminci/features/auth/domain/repository/auth_repository.dart';

class Login {
  final AuthRepository _repository;

  const Login(this._repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) =>
      _repository.login(username: username, password: password);
}
