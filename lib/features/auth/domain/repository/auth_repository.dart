import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';

/// Contrat de la couche domain pour l'authentification locale.
///
/// Tout est stocké dans sqflite — pas d'authentification distante.
/// Implémenté dans la couche data par [AuthRepositoryImpl].
abstract class AuthRepository {
  /// Authentifie un utilisateur par identifiants.
  ///
  /// Vérifie le hash du mot de passe, persiste la session dans
  /// [active_session] et retourne l'[User] connecté.
  Future<Either<Failure, User>> login({required String username, required String password});

  /// Supprime la session active — déconnecte l'utilisateur courant.
  Future<Either<Failure, void>> logout();

  /// Retourne l'utilisateur dont la session est persistée, ou
  /// [AuthFailure] si aucune session active n'existe.
  ///
  /// Utilisé par [LaunchBloc] pour restaurer la session au démarrage.
  Future<Either<Failure, User>> getActiveUser();

  /// Crée un nouveau compte utilisateur.
  ///
  /// Seul un admin peut créer des comptes [UserRole.operator].
  /// Le premier compte créé (au setup) est obligatoirement [UserRole.admin].
  Future<Either<Failure, User>> createUser({
    required String username,
    required String password,
    required UserRole role,
  });

  /// Retourne la liste de tous les utilisateurs enregistrés.
  /// Réservé à l'admin.
  Future<Either<Failure, List<User>>> getUsers();

  /// Supprime un compte utilisateur par son [id].
  /// Impossible de supprimer son propre compte.
  Future<Either<Failure, void>> deleteUser(int id);

  /// Modifie le mot de passe d'un utilisateur.
  Future<Either<Failure, void>> changePassword({required int userId, required String newPassword});
}
