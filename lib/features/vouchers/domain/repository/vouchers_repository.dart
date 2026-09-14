import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';

abstract class VouchersRepository {
  Future<Either<Failure, List<Voucher>>> getByProfile(MikroTikRouter router, HotspotProfile profile);
  Future<Either<Failure, void>> deleteMany(MikroTikRouter router, List<Voucher> vouchers);

  /// Génère [quantity] nouveaux vouchers pour [profile] sur [router].
  Future<Either<Failure, List<Voucher>>> generate(
    MikroTikRouter router,
    HotspotProfile profile, {
    required int quantity,
    required double price,
    required String createdBy,
    String? limitUptime,
    int limitBytesTotal = 0,
    String? comment,
    String? server,
  });
}
