import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';
import 'package:dartz/dartz.dart';

/// Vérifie si c'est le premier lancement de l'application.
///
/// Retourne [true] si aucun compte administrateur n'existe encore —
/// l'app doit guider l'utilisateur vers la création du compte admin.
/// Retourne [false] si l'app a déjà été configurée.
class CheckFirstLaunch {
  final LaunchRepository _repository;

  const CheckFirstLaunch(this._repository);

  Future<Either<Failure, bool>> call() => _repository.isFirstLaunch();
}
