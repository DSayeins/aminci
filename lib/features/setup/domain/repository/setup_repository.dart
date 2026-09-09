import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';
import 'package:dartz/dartz.dart';

abstract class SetupRepository {
  Future<Either<Failure, Unit>> create({
    required User user,
    required MikroTikRouter router,
    Preference? preference,
  });
}
