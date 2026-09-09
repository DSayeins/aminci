import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/hotspot/domain/repository/hotspot_repository.dart';

class GetHotspots {
  final HotspotRepository _repository;

  const GetHotspots(this._repository);

  Future<Either<Failure, List<Hotspot>>> call(MikroTikRouter router) => _repository.getHotspots(router);
}
