import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error.dart';
import 'package:aminci/core/models/voucher.dart';

/// Contrat du repository de gestion des vouchers hotspot.
abstract class VouchersRepository {
  /// Retourne tous les vouchers d'un routeur depuis la base locale.
  Future<Either<Failure, List<Voucher>>> getVouchers(int routerId);

  /// Retourne la liste des serveurs hotspot configurés sur un routeur.
  Future<Either<Failure, List<String>>> getHotspotServers(int routerId);

  /// Génère [quantity] vouchers sur le routeur MikroTik et les sauvegarde localement.
  ///
  /// Les codes sont générés localement (format AM-XXXXX) et créés en tant
  /// qu'utilisateurs hotspot avec le profil [profileName].
  Future<Either<Failure, List<Voucher>>> generateVouchers({
    required int routerId,
    required String profileName,
    required double price,
    required int quantity,
    required String createdBy,
    String? comment,
    String? limitUptime,
    int limitBytesTotal,
    String? server,
    int usernameLength,
    bool lettersOnly,
    bool samePassword,
  });

  /// Supprime un voucher localement et sur le routeur MikroTik.
  Future<Either<Failure, Unit>> deleteVoucher({
    required int voucherId,
    required int routerId,
  });

  /// Génère un PDF des [vouchers] fournis et ouvre la boîte de dialogue d'impression.
  Future<Either<Failure, Unit>> printVouchers(List<Voucher> vouchers);
}
