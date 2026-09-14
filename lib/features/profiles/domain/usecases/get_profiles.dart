import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class GetProfiles {
  final ProfilesRepository _repository;
  const GetProfiles(this._repository);

  Future<Either<Failure, List<HotspotProfile>>> call(MikroTikRouter router) => _repository.getProfiles(router);
}
