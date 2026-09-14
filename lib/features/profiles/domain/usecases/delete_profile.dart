import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class DeleteProfile {
  final ProfilesRepository _repository;
  const DeleteProfile(this._repository);

  Future<Either<Failure, void>> call(MikroTikRouter router, HotspotProfile profile) =>
      _repository.delete(router, profile);
}
