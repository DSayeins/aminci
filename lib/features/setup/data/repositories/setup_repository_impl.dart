import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';

/// Implémentation sqflite de [SetupRepository].
///
/// Réutilise le même schéma de hachage que [AuthRepositoryImpl] :
/// SHA-256 avec salt aléatoire 16 octets, format `"<salt_b64>:<sha256_hex>"`.
class SetupRepositoryImpl implements SetupRepository {
  final DatabaseHelper _db;

  const SetupRepositoryImpl(this._db);

  @override
  Future<Either<Failure, Unit>> createAdminAccount({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Nom d\'utilisateur et mot de passe requis'));
    }

    try {
      final db = await _db.database;
      await db.insert('users', {
        'username': username.trim(),
        'password_hash': _hash(password),
        'role': 'admin',
      });
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Impossible de créer le compte administrateur'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _hash(String password) {
    final salt = _salt();
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return '$salt:$digest';
  }

  String _salt() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes);
  }
}
