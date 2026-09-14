import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/data/datasources/voucher_local_datasource.dart';
import 'package:aminci/features/vouchers/data/datasources/voucher_remote_datasource.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class VouchersRepositoryImpl implements VouchersRepository {
  final VoucherRemoteDatasource _remote;
  final VoucherLocalDatasource _local;

  const VouchersRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<Voucher>>> getByProfile(MikroTikRouter router, HotspotProfile profile) {
    return ErrorMapper.guard(() async {
      final remoteVouchers = await _remote.getVouchers(router, profile);
      await _local.syncFromRemote(router.id, profile.mikrotikName, remoteVouchers);
      return _local.getByProfile(router.id, profile.mikrotikName);
    }, fallbackMessage: 'Impossible de charger les vouchers');
  }
}
