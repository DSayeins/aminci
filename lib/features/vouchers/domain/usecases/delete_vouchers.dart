import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class DeleteVouchers {
  final VouchersRepository _repository;
  const DeleteVouchers(this._repository);

  Future<Either<Failure, void>> call(MikroTikRouter router, List<Voucher> vouchers) =>
      _repository.deleteMany(router, vouchers);
}
