import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/data/datasource/launch_local_datasource.dart';
import 'package:aminci/features/launch/domain/entities/launch_result.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';

/// Implémentation SQLite de [LaunchRepository].
/// Délègue les requêtes brutes à [LaunchLocalDatasource].
class LaunchRepositoryImpl implements LaunchRepository {
  final LaunchLocalDatasource _datasource;

  const LaunchRepositoryImpl(this._datasource);

  /// Détermine l'état de démarrage de l'application en deux étapes :
  /// 1. Flag `app_state.first_launch_done` non posé → premier lancement
  /// 2. Session active valide → utilisateur déjà connecté
  @override
  Future<Either<Failure, LaunchResult>> initialize() {
    return ErrorMapper.guard(() async {
      final firstLaunch = await _datasource.isFirstLaunch();
      if (firstLaunch) return const LaunchResultFirstLaunch();

      final user = await _datasource.getActiveUser();
      return user != null ? LaunchResultAuthenticated(user) : const LaunchResultUnauthenticated();
    }, fallbackMessage: 'Impossible d\'initialiser l\'application');
  }
}
