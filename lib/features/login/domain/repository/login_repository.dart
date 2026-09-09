import 'package:aminci/core/models/user.dart';
import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';

/// Contrat de la couche domain pour l'authentification locale.
///
/// Tout est stocké dans sqflite — pas d'authentification distante.
/// Implémenté dans la couche data par [LoginRepositoryImpl].
abstract class LoginRepository {
  /// Authentifie un utilisateur par identifiants.
  ///
  /// Vérifie le hash du mot de passe, persiste la session dans
  /// [active_session] et retourne l'[User] connecté.
  Future<Either<Failure, User>> login({required String username, required String password});
}
