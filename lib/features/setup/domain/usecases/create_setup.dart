import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';
import 'package:aminci/core/utils/password_hasher.dart';
import 'package:aminci/features/setup/domain/repository/setup_repository.dart';

class CreateSetup {
  final SetupRepository _repository;

  const CreateSetup(this._repository);

  Future<Either<Failure, Unit>> call({
    required User user,
    required MikroTikRouter router,
    Preference? preference,
  }) {
    final hashedUser = user.copyWith(password: PasswordHasher.hash(user.password));
    return _repository.create(user: hashedUser, router: router, preference: preference);
  }
}
