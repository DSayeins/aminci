import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class DeleteProfileUsers {
  final ProfilesRepository _repository;

  DeleteProfileUsers(this._repository);

  Future<Either<Failure, Unit>> call({
    required int routerId,
    required List<int> voucherIds,
  }) => _repository.deleteProfileUsers(routerId: routerId, voucherIds: voucherIds);
}
