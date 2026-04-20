import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/app/domain/repository/app_repository.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

class GetUser {
  final AppRepository _repository;

  GetUser(this._repository);

  Future<Either<Failure, User>> call() async => await _repository.getActiveUser();
}
