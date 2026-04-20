import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';
import 'package:dartz/dartz.dart';

class CreateAdminAccount {
  final SetupRepository _repository;

  CreateAdminAccount(this._repository);

  Future<Either<Failure, Unit>> call({required String username, required String password}) =>
      _repository.createAdminAccount(username: username, password: password);
}
