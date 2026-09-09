import 'package:aminci/core/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/login/domain/repository/login_repository.dart';

class Login {
  final LoginRepository _repository;

  const Login(this._repository);

  Future<Either<Failure, User>> call({required String username, required String password}) =>
      _repository.login(username: username, password: password);
}
