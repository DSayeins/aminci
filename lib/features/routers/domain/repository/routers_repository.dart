import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error.dart';
import 'package:aminci/core/models/router.dart';

/// Contrat du repository de gestion des routeurs MikroTik.
abstract class RoutersRepository {
  /// Retourne tous les routeurs enregistrés.
  Future<Either<Failure, List<MikroTikRouter>>> getRouters();

  /// Retourne un routeur par son [id].
  Future<Either<Failure, MikroTikRouter>> getRouter(int id);

  /// Ajoute un nouveau routeur.
  Future<Either<Failure, MikroTikRouter>> addRouter({
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    required RouterOsVersion rosVersion,
  });

  /// Met à jour un routeur existant.
  Future<Either<Failure, MikroTikRouter>> updateRouter({
    required int id,
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    required RouterOsVersion rosVersion,
  });

  /// Supprime un routeur par son [id].
  Future<Either<Failure, Unit>> deleteRouter(int id);

  /// Teste la connexion TCP au routeur (login RouterOS API).
  ///
  /// Retourne [Right(unit)] si la connexion réussit.
  /// Retourne [Left(NetworkFailure)] ou [Left(MikroTikFailure)] sinon.
  Future<Either<Failure, Unit>> testConnection(int id);
}
