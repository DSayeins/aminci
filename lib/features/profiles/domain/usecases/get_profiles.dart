import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';
import 'package:dartz/dartz.dart';

class GetProfiles {
  final ProfilesRepository _repository;

  GetProfiles(this._repository);

  Future<Either<Failure, List<HotspotProfile>>> call(int routerId) async => _repository.getProfiles(routerId);
}
