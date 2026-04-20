import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/app/domain/repository/app_repository.dart';
import 'package:dartz/dartz.dart';

class Logout {
  final AppRepository _repository;

  Logout(this._repository);

  Future<Either<Failure, Unit>> call() async => await _repository.logout();
}
