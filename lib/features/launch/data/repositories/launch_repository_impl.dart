import 'package:dartz/dartz.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/launch/domain/repository/launch_repository.dart';

class LaunchRepositoryImpl implements LaunchRepository {
  final DatabaseHelper _db;

  const LaunchRepositoryImpl(this._db);

  /// Premier lancement si la table [users] ne contient aucun enregistrement.
  @override
  Future<Either<Failure, bool>> isFirstLaunch() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('SELECT COUNT(*) AS count FROM users');
      final count = result.first['count'] as int;
      return Right(count == 0);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible de vérifier le premier lancement'));
    }
  }

  /// Session active si la table [active_session] contient une ligne.
  @override
  Future<Either<Failure, bool>> hasActiveSession() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('SELECT COUNT(*) AS count FROM active_session');
      final count = result.first['count'] as int;
      return Right(count > 0);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure('Impossible de vérifier la session active'));
    }
  }
}
