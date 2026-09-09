import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/domain/entities/launch_result.dart';
import 'package:dartz/dartz.dart';

/// Contrat de la couche domain pour le démarrage de l'application.
///
/// Implémenté dans la couche data — ne dépend d'aucun framework.
abstract class LaunchRepository {
  /// Initialise l'application et retourne le [LaunchResult] approprié.
  ///
  /// Effectue en séquence :
  /// 1. Ouverture de la base de données
  /// 2. Vérification du premier lancement
  /// 3. Vérification d'une session active
  Future<Either<Failure, LaunchResult>> initialize();
}
