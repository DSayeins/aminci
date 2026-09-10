import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/hotspot/data/datasources/hotspot_local_datasource.dart';
import 'package:aminci/features/hotspot/data/datasources/hotspot_remote_datasource.dart';
import 'package:aminci/features/hotspot/domain/repository/hotspot_repository.dart';

class HotspotRepositoryImpl implements HotspotRepository {
  final HotspotRemoteDatasource _remote;
  final HotspotLocalDatasource _local;

  const HotspotRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<Hotspot>>> getHotspots(MikroTikRouter router) {
    return ErrorMapper.guard(() async {
      final hotspots = await _remote.getHotspots(router);
      await _local.replaceAll(router.id, hotspots);
      return hotspots;
    }, fallbackMessage: 'Impossible de charger les hotspots');
  }
}
