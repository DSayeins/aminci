import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';
import 'package:dartz/dartz.dart';

class SyncProfiles {
  final ProfilesRepository _repository;

  SyncProfiles(this._repository);

  Future<Either<Failure, List<HotspotProfile>>> call(int routerId) async => _repository.syncProfiles(routerId);
}
