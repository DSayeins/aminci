import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';
import 'package:aminci/features/auth/domain/repository/auth_repository.dart';

/// Implémentation sqflite de [AuthRepository].
///
/// Hachage des mots de passe : SHA-256 avec salt aléatoire 16 octets.
/// Format stocké en base : `"<salt_b64>:<sha256_hex>"`
///
/// Dépendance : `crypto: ^3.0.3` dans pubspec.yaml
class AuthRepositoryImpl implements AuthRepository {
  final DatabaseHelper _db;

  const AuthRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Login / Logout
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (rows.isEmpty) {
        return const Left(AuthFailure('Identifiants incorrects'));
      }

      final row = rows.first;
      final stored = row['password_hash'] as String;

      if (!_verify(password, stored)) {
        return const Left(AuthFailure('Identifiants incorrects'));
      }

      // Upsert session active (id=1 — une seule ligne autorisée)
      await db.insert(
        'active_session',
        {'id': 1, 'user_id': row['id']},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Right(_toUser(row));
    } catch (_) {
      return const Left(AuthFailure('Identifiants incorrects'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final db = await _db.database;
      await db.delete('active_session');
      return const Right(null);
    } catch (_) {
      return const Left(StorageFailure('Impossible de fermer la session'));
    }
  }

  // ---------------------------------------------------------------------------
  // Session active
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, User>> getActiveUser() async {
    try {
      final db = await _db.database;
      final session = await db.rawQuery(
        '''
        SELECT u.id, u.username, u.role
        FROM active_session s
        JOIN users u ON u.id = s.user_id
        LIMIT 1
        ''',
      );

      if (session.isEmpty) {
        return const Left(AuthFailure('Aucune session active'));
      }

      return Right(_toUser(session.first));
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire la session active'));
    }
  }

  // ---------------------------------------------------------------------------
  // Gestion des utilisateurs
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, User>> createUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      final db = await _db.database;
      final id = await db.insert('users', {
        'username': username,
        'password_hash': _hash(password),
        'role': role.name,
      });

      return Right(User(id: id, username: username, role: role));
    } catch (_) {
      return const Left(StorageFailure('Impossible de créer l\'utilisateur'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final db = await _db.database;
      final rows = await db.query('users', orderBy: 'created_at ASC');
      return Right(rows.map(_toUser).toList());
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les utilisateurs'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      final db = await _db.database;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
      return const Right(null);
    } catch (_) {
      return const Left(StorageFailure('Impossible de supprimer l\'utilisateur'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final db = await _db.database;
      await db.update(
        'users',
        {'password_hash': _hash(newPassword)},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return const Right(null);
    } catch (_) {
      return const Left(StorageFailure('Impossible de modifier le mot de passe'));
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

  /// Génère un hash stockable : `"<salt_b64>:<sha256_hex>"`
  String _hash(String password) {
    final salt = _salt();
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return '$salt:$digest';
  }

  /// Vérifie un mot de passe contre un hash stocké.
  bool _verify(String password, String stored) {
    final sep = stored.indexOf(':');
    if (sep == -1) return false;
    final salt = stored.substring(0, sep);
    final expected = stored.substring(sep + 1);
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return digest.toString() == expected;
  }

  /// Génère un salt aléatoire sécurisé (16 octets → base64url).
  String _salt() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes);
  }
}
