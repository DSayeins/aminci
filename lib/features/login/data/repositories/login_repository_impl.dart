import 'package:aminci/core/models/user.dart';
import 'package:aminci/features/login/data/datasource/login_local_datasource.dart';
import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/utils/password_hasher.dart';
import 'package:aminci/features/login/domain/repository/login_repository.dart';

/// Implémentation sqflite de [LoginRepository].
///
/// Vérification du mot de passe déléguée à [PasswordHasher].
class LoginRepositoryImpl implements LoginRepository {
  final LoginLocalDatasource _datasource;

  const LoginRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, User>> login({required String username, required String password}) async {
    try {
      final row = await _datasource.findUserByUsername(username);

      if (row == null) {
        return const Left(AuthFailure('Identifiants incorrects'));
      }

      final stored = row['password'] as String;

      if (!_verify(password, stored)) {
        return const Left(AuthFailure('Identifiants incorrects'));
      }

      await _datasource.createSession(row['id'] as int);

      return Right(_toUser(row));
    } catch (_) {
      return const Left(AuthFailure('Identifiants incorrects'));
    }
  }

  bool _verify(String password, String stored) => PasswordHasher.verify(password, stored);

  User _toUser(Map<String, dynamic> row) => User.fromMap(row);
}
