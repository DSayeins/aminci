import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class GetVouchers {
  final VouchersRepository _repository;

  GetVouchers(this._repository);

  Future<Either<Failure, List<Voucher>>> call(int routerId) => _repository.getVouchers(routerId);
}
