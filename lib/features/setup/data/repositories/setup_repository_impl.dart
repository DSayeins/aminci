import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';
import 'package:aminci/features/setup/data/datasources/setup_local_datasource.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';

class SetupRepositoryImpl implements SetupRepository {
  final SetupLocalDatasourceImpl _datasource;

  const SetupRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Unit>> create({required User user, required MikroTikRouter router, Preference? preference}) {
    return ErrorMapper.guard(() async {
      await _datasource.create(user: user, router: router, preference: preference);
      return unit;
    }, fallbackMessage: 'Impossible de terminer la configuration initiale');
  }
}
