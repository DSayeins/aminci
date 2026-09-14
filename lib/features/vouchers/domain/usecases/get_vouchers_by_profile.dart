import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class GetVouchersByProfile {
  final VouchersRepository _repository;
  const GetVouchersByProfile(this._repository);

  Future<Either<Failure, List<Voucher>>> call(MikroTikRouter router, HotspotProfile profile) =>
      _repository.getByProfile(router, profile);
}
