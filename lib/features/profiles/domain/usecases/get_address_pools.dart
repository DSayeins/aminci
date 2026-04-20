import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class GetAddressPools {
  final ProfilesRepository _repository;

  GetAddressPools(this._repository);

  Future<Either<Failure, List<String>>> call(int routerId) =>
      _repository.getAddressPools(routerId);
}
