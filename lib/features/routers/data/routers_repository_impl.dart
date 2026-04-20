import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/mikrotik/mikrotik_service.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class RoutersRepositoryImpl implements RoutersRepository {
  final DatabaseHelper _db;

  const RoutersRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<MikroTikRouter>>> getRouters() async {
    try {
      final db = await _db.database;
      final rows = await db.query('routers', orderBy: 'created_at ASC');
      return Right(rows.map(MikroTikRouter.fromMap).toList());
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les routeurs'));
    }
  }

  @override
  Future<Either<Failure, MikroTikRouter>> getRouter(int id) async {
    try {
      final db = await _db.database;
      final rows = await db.query('routers', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) return const Left(StorageFailure('Routeur introuvable'));
      return Right(MikroTikRouter.fromMap(rows.first));
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire le routeur'));
    }
  }

  // ---------------------------------------------------------------------------
  // Écriture
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, MikroTikRouter>> addRouter({
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    required RouterOsVersion rosVersion,
  }) async {
    try {
      final db = await _db.database;
      final id = await db.insert('routers', {
        'name': name,
        'ip': ip,
        'port': port,
        'username': username,
        'password': password,
        'ros_version': rosVersion.name,
      });
      return Right(MikroTikRouter(
        id: id,
        name: name,
        ip: ip,
        port: port,
        username: username,
        password: password,
        rosVersion: rosVersion,
      ));
    } catch (_) {
      return const Left(StorageFailure('Impossible d\'ajouter le routeur'));
    }
  }

  @override
  Future<Either<Failure, MikroTikRouter>> updateRouter({
    required int id,
    required String name,
    required String ip,
    required int port,
    required String username,
    required String password,
    required RouterOsVersion rosVersion,
  }) async {
    try {
      final db = await _db.database;
      await db.update(
        'routers',
        {
          'name': name,
          'ip': ip,
          'port': port,
          'username': username,
          'password': password,
          'ros_version': rosVersion.name,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return Right(MikroTikRouter(
        id: id,
        name: name,
        ip: ip,
        port: port,
        username: username,
        password: password,
        rosVersion: rosVersion,
      ));
    } catch (_) {
      return const Left(StorageFailure('Impossible de modifier le routeur'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRouter(int id) async {
    try {
      final db = await _db.database;
      await db.delete('routers', where: 'id = ?', whereArgs: [id]);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Impossible de supprimer le routeur'));
    }
  }

  // ---------------------------------------------------------------------------
  // Test de connexion
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> testConnection(int id) async {
    final result = await getRouter(id);

    return result.fold(
      (failure) => Left(failure),
      (router) async {
        debugPrint('[TestConnection] → ${router.name} (${router.ip}:${router.port}) user=${router.username} version=${router.rosVersion.name}');
        final service = MikroTikService.fromRouter(router);
        try {
          debugPrint('[TestConnection] Connexion en cours...');
          await service.connect();
          debugPrint('[TestConnection] Connexion établie — déconnexion');
          await service.disconnect();
          debugPrint('[TestConnection] ✓ Succès');
          return const Right(unit);
        } on NetworkException catch (e) {
          debugPrint('[TestConnection] ✗ NetworkException: ${e.message}');
          return Left(NetworkFailure(e.message));
        } on MikroTikException catch (e) {
          debugPrint('[TestConnection] ✗ MikroTikException: ${e.message}');
          return Left(MikroTikFailure(e.message));
        } catch (e) {
          debugPrint('[TestConnection] ✗ Exception inattendue: $e');
          return const Left(NetworkFailure('Connexion impossible au routeur'));
        }
      },
    );
  }
}
