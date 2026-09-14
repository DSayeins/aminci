import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/profiles/data/datasources/profile_local_datasource.dart';
import 'package:aminci/features/profiles/data/datasources/profile_remote_datasource.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final ProfileRemoteDatasource _remote;
  final ProfileLocalDatasource _local;

  const ProfilesRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<HotspotProfile>>> getProfiles(MikroTikRouter router) {
    return ErrorMapper.guard(() async {
      final remoteProfiles = await _remote.getProfiles(router);
      await _local.syncFromRemote(router.id, remoteProfiles);
      return _local.getProfiles(router.id);
    }, fallbackMessage: 'Impossible de charger les profils');
  }

  @override
  Future<Either<Failure, HotspotProfile>> create(MikroTikRouter router, HotspotProfile profile) {
    return ErrorMapper.guard(() async {
      final created = await _remote.createProfile(router, profile);
      return _local.insertProfile(created);
    }, fallbackMessage: 'Impossible de créer le profil');
  }

  @override
  Future<Either<Failure, void>> delete(MikroTikRouter router, HotspotProfile profile) {
    return ErrorMapper.guard(() async {
      final mikrotikId = profile.mikrotikId;
      if (mikrotikId != null) {
        await _remote.deleteProfile(router, mikrotikId);
      }
      await _local.deleteProfile(profile.id);
    }, fallbackMessage: 'Impossible de supprimer le profil');
  }
}
