import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class GetHotspotServers {
  final VouchersRepository _repository;

  GetHotspotServers(this._repository);

  Future<Either<Failure, List<String>>> call(int routerId) =>
      _repository.getHotspotServers(routerId);
}
