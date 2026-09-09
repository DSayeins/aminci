import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';

/// Contrat de la couche domain pour la déconnexion locale.
///
/// Implémenté dans la couche data par [LogoutRepositoryImpl].
abstract class LogoutRepository {
  /// Ferme la session active locale (supprime `active_session`).
  Future<Either<Failure, void>> logout();
}
