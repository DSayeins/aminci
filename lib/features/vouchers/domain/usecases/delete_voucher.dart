import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class DeleteVoucher {
  final VouchersRepository _repository;

  DeleteVoucher(this._repository);

  Future<Either<Failure, Unit>> call({
    required int voucherId,
    required int routerId,
  }) =>
      _repository.deleteVoucher(
        voucherId: voucherId,
        routerId: routerId,
      );
}
