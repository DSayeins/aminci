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

  @override
  Future<Either<Failure, void>> deleteMany(MikroTikRouter router, List<Voucher> vouchers) {
    return ErrorMapper.guard(() async {
      final mikrotikIds = vouchers.map((v) => v.mikrotikId).whereType<String>().toList();
      if (mikrotikIds.isNotEmpty) {
        await _remote.deleteVouchers(router, mikrotikIds);
      }
      await _local.deleteMany(vouchers.map((v) => v.id).toList());
    }, fallbackMessage: 'Impossible de supprimer les vouchers');
  }
}
