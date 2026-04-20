import 'package:dartz/dartz.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/app/domain/repository/app_repository.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';

class AppRepositoryImpl implements AppRepository {
  final DatabaseHelper _db;

  const AppRepositoryImpl(this._db);

  @override
  Future<Either<Failure, User>> getActiveUser() async {
    try {
      final db = await _db.database;
      final rows = await db.rawQuery('''
        SELECT u.id, u.username, u.role
        FROM active_session s
        JOIN users u ON u.id = s.user_id
        LIMIT 1
      ''');

      if (rows.isEmpty) {
        return const Left(StorageFailure('Aucune session active'));
      }

      return Right(_toUser(rows.first));
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire la session active'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final db = await _db.database;
      await db.delete('active_session');
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Impossible de fermer la session'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  User _toUser(Map<String, dynamic> row) {
    return User(
      id: row['id'] as int,
      username: row['username'] as String,
      role: (row['role'] as String) == 'admin' ? UserRole.admin : UserRole.operator,
    );
  }
}
