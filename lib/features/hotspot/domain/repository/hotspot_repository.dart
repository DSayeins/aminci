import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';

/// Contrat de la couche domain pour les serveurs hotspot MikroTik.
///
/// Implémenté dans la couche data par [HotspotRepositoryImpl].
abstract class HotspotRepository {
  /// Liste les serveurs hotspot du routeur [router] — donnée live, jamais
  /// mise en cache localement.
  Future<Either<Failure, List<Hotspot>>> getHotspots(MikroTikRouter router);
}
