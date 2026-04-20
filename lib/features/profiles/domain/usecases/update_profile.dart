import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class UpdateProfile {
  final ProfilesRepository _repository;

  UpdateProfile(this._repository);

  Future<Either<Failure, HotspotProfile>> call({
    required int profileId,
    String? name,
    String? addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool? addMacCookie,
    String? macCookieTimeout,
    int? sharedUsers,
    DateTime? expiresAt,
  }) => _repository.updateProfile(
        profileId: profileId,
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
