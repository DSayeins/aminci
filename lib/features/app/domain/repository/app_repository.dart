import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';

/// Contrat du repository de la feature app.
///
/// Fournit les données nécessaires au shell de l'application :
/// utilisateur actif et déconnexion.
abstract class AppRepository {
  /// Récupère l'utilisateur actuellement connecté depuis la session active.
  ///
  /// Retourne [Left(StorageFailure)] si aucune session n'existe.
  Future<Either<Failure, User>> getActiveUser();

  /// Déconnecte l'utilisateur courant (supprime la session active).
  ///
  /// Retourne [Left(StorageFailure)] en cas d'erreur DB.
  Future<Either<Failure, Unit>> logout();
}
