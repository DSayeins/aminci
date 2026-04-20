import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class GetProfileUsers {
  final ProfilesRepository _repository;

  GetProfileUsers(this._repository);

  Future<Either<Failure, List<Voucher>>> call({
    required int routerId,
    required String profileName,
  }) => _repository.getProfileUsers(routerId: routerId, profileName: profileName);
}
