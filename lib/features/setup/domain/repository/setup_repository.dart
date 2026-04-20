import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';

/// Contrat du repository de configuration initiale.
///
/// Utilisé uniquement lors du premier lancement pour créer le compte administrateur.
abstract class SetupRepository {
  /// Crée le premier compte administrateur.
  ///
  /// Retourne [Right(unit)] en cas de succès.
  /// Retourne [Left(StorageFailure)] si l'écriture en base échoue.
  /// Retourne [Left(ValidationFailure)] si [username] ou [password] est vide.
  Future<Either<Failure, Unit>> createAdminAccount({
    required String username,
    required String password,
  });
}
