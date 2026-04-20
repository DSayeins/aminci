import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class DeleteProfile {
  final ProfilesRepository _repository;

  DeleteProfile(this._repository);

  Future<Either<Failure, Unit>> call(int profileId) => _repository.deleteProfile(profileId);
}
