import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/domain/entities/launch_result.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';
import 'package:dartz/dartz.dart';

class Initialize {
  final LaunchRepository _repository;

  const Initialize(this._repository);

  Future<Either<Failure, LaunchResult>> call() => _repository.initialize();
}
