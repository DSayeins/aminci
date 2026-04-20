import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class CreateProfile {
  final ProfilesRepository _repository;

  CreateProfile(this._repository);

  Future<Either<Failure, HotspotProfile>> call({
    required int routerId,
    required String name,
    required String addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool addMacCookie = true,
    String? macCookieTimeout,
    int sharedUsers = 1,
    DateTime? expiresAt,
  }) => _repository.createProfile(
        routerId: routerId,
        name: name,
        addressPool: addressPool,
        rateLimit: rateLimit,
        sessionTimeout: sessionTimeout,
        idleTimeout: idleTimeout,
        keepaliveTimeout: keepaliveTimeout,
        addMacCookie: addMacCookie,
        macCookieTimeout: macCookieTimeout,
        sharedUsers: sharedUsers,
        expiresAt: expiresAt,
      );
}
