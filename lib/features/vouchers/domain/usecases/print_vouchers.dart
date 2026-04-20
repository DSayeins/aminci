import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class PrintVouchers {
  final VouchersRepository _repository;

  const PrintVouchers(this._repository);

  Future<Either<Failure, Unit>> call(List<Voucher> vouchers) =>
      _repository.printVouchers(vouchers);
}
