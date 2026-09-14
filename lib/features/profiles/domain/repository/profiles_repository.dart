import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';

abstract class ProfilesRepository {
  /// Recharge les profils depuis le routeur, synchronise le cache local,
  /// puis retourne la liste à jour.
  Future<Either<Failure, List<HotspotProfile>>> getProfiles(MikroTikRouter router);

  /// Crée un profil sur le routeur puis le persiste en cache local.
  Future<Either<Failure, HotspotProfile>> create(MikroTikRouter router, HotspotProfile profile);

  /// Supprime un profil sur le routeur puis en cache local.
  Future<Either<Failure, void>> delete(MikroTikRouter router, HotspotProfile profile);
}
