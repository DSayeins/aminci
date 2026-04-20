import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';
import 'package:dartz/dartz.dart';

/// Vérifie si une session utilisateur est persistée et toujours valide.
///
/// Retourne [true] si un utilisateur est déjà connecté — l'app peut
/// passer directement au shell principal sans repasser par le login.
/// Retourne [false] si aucune session active n'existe.
class CheckActiveSession {
  final LaunchRepository _repository;

  const CheckActiveSession(this._repository);

  Future<Either<Failure, bool>> call() => _repository.hasActiveSession();
}
