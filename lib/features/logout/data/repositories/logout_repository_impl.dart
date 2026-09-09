import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/features/logout/data/datasource/logout_local_datasource.dart';
import 'package:aminci/features/logout/domain/repository/logout_repository.dart';

class LogoutRepositoryImpl implements LogoutRepository {
  final LogoutLocalDatasource _datasource;

  const LogoutRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(StorageFailure('Impossible de fermer la session'));
    }
  }
}
