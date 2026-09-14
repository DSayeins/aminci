import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

/// Supprime tous les vouchers d'un profil — utilisé lors de la suppression
/// du profil lui-même, pour éviter de laisser des comptes hotspot orphelins
/// sur le routeur.
class DeleteVouchersForProfile {
  final VouchersRepository _repository;
  const DeleteVouchersForProfile(this._repository);

  Future<Either<Failure, void>> call(MikroTikRouter router, HotspotProfile profile) =>
      _repository.deleteAllForProfile(router, profile);
}
