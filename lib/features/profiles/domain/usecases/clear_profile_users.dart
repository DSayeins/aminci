import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class ClearProfileUsers {
  final ProfilesRepository _repository;

  ClearProfileUsers(this._repository);

  Future<Either<Failure, Unit>> call({
    required int routerId,
    required String profileName,
  }) => _repository.clearProfileUsers(routerId: routerId, profileName: profileName);
}
