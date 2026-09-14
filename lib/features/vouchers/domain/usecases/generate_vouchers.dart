import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class GenerateVouchers {
  final VouchersRepository _repository;
  const GenerateVouchers(this._repository);

  Future<Either<Failure, List<Voucher>>> call(
    MikroTikRouter router,
    HotspotProfile profile, {
    required int quantity,
    required double price,
    required String createdBy,
    String? limitUptime,
    int limitBytesTotal = 0,
    String? comment,
    String? server,
  }) => _repository.generate(
    router,
    profile,
    quantity: quantity,
    price: price,
    createdBy: createdBy,
    limitUptime: limitUptime,
    limitBytesTotal: limitBytesTotal,
    comment: comment,
    server: server,
  );
}
