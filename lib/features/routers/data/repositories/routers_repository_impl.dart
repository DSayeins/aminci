import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/exceptions.dart' hide MikroTikException;
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/mikrotik/mikrotik_exception.dart';
import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/data/datasources/router_local_datasource.dart';
import 'package:aminci/features/routers/domain/repository/routers_repository.dart';

class RoutersRepositoryImpl implements RoutersRepository {
  final RouterLocalDatasource _local;

  const RoutersRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<MikroTikRouter>>> getAll() async {
    try {
      final routers = await _local.getRouters();
      return Right(routers);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible de charger les routeurs'));
    }
  }

  @override
  Future<Either<Failure, MikroTikRouter>> create(MikroTikRouter router) async {
    // Vérifie la connexion avant de persister
    final testResult = await testConnection(router);
    if (testResult.isLeft()) {
      return testResult.fold((f) => Left(f), (_) => throw StateError('unreachable'));
    }

    try {
      final saved = await _local.addRouter(router);
      return Right(saved);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible d\'ajouter le routeur'));
    }
  }

  @override
  Future<Either<Failure, MikroTikRouter>> update(MikroTikRouter router) async {
    try {
      final updated = await _local.updateRouter(router);
      return Right(updated);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible de modifier le routeur'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _local.deleteRouter(id);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible de supprimer le routeur'));
    }
  }

  @override
  Future<Either<Failure, String>> testConnection(MikroTikRouter router) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final result = await client.get('/system/identity');
      final identity = (result.firstOrNull?['name'] ?? router.ip) as String;
      return Right(identity);
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (e) {
      return Left(MikroTikFailure('Connexion échouée : $e'));
    } finally {
      client.close();
    }
  }
}
