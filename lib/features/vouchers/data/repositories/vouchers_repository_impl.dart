import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/data/datasources/voucher_code_generator.dart';
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

  @override
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
  }) {
    return ErrorMapper.guard(() async {
      final codes = <String>{};
      while (codes.length < quantity) {
        codes.add(VoucherCodeGenerator.code());
      }
      final credentials = codes.map((code) => (code: code, password: VoucherCodeGenerator.password())).toList();

      final created = await _remote.createVouchers(
        router,
        profile,
        credentials,
        limitUptime: limitUptime,
        limitBytesTotal: limitBytesTotal,
        comment: comment,
        server: server,
      );

      final now = DateTime.now();
      // On force les champs métier saisis dans le formulaire plutôt que de
      // faire confiance à la réponse REST de création (RouterOS ne réémet
      // pas forcément tous les champs, ex: limit-bytes-total).
      final vouchers = created
          .map(
            (v) => Voucher(
              id: 0,
              routerId: router.id,
              code: v.code,
              password: v.password,
              profileName: profile.mikrotikName,
              price: price,
              status: VoucherStatus.pending,
              createdAt: now,
              createdBy: createdBy,
              mikrotikId: v.mikrotikId,
              server: server,
              comment: comment,
              limitUptime: limitUptime,
              limitBytesTotal: limitBytesTotal,
              uptime: v.uptime,
              bytesIn: v.bytesIn,
              bytesOut: v.bytesOut,
              disabled: v.disabled,
            ),
          )
          .toList();

      // `insertVoucher` renvoie le voucher avec l'id local réellement
      // attribué par SQLite — indispensable pour la sélection multiple sur
      // l'écran (sans ça, tous les vouchers générés partagent id=0 et se
      // sélectionnent ensemble).
      final inserted = <Voucher>[];
      for (final voucher in vouchers) {
        inserted.add(await _local.insertVoucher(voucher));
      }
      return inserted;
    }, fallbackMessage: 'Impossible de générer les vouchers');
  }
}
