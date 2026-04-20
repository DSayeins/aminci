import 'package:aminci/core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Contrat de la couche domain pour le démarrage de l'application.
///
/// Implémenté dans la couche data — ne dépend d'aucun framework.
abstract class LaunchRepository {
  /// Vérifie si c'est le premier lancement de l'application.
  ///
  /// Retourne [true] si aucun compte administrateur n'existe encore
  /// (base de données vide). Dans ce cas, l'app doit guider l'utilisateur
  /// vers la création du compte admin.
  Future<Either<Failure, bool>> isFirstLaunch();

  /// Vérifie si une session utilisateur est persistée et toujours valide.
  ///
  /// Retourne [true] si un utilisateur est déjà connecté (token/id stocké en
  /// base). Dans ce cas, l'app peut passer directement au shell principal
  /// sans repasser par l'écran d'authentification.
  Future<Either<Failure, bool>> hasActiveSession();
}
