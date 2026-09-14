import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';

/// Accès REST MikroTik pour la feature vouchers.
class VoucherRemoteDatasource {
  const VoucherRemoteDatasource();

  /// Liste les vouchers (comptes `/ip/hotspot/user`) rattachés à [profile]
  /// sur [router], filtrés côté serveur via la query REST (`?profile=...`).
  ///
  /// Le champ `profile` d'une ligne peut valoir soit le nom du profil, soit
  /// son identifiant MikroTik interne (ex: `*D`) selon l'état de la référence
  /// côté RouterOS — on interroge donc avec les deux valeurs et on fusionne
  /// les résultats. Les comptes système (`admin`, `default-trial`) n'ont pas
  /// de champ `server` — on les exclut, car ils peuvent légitimement porter
  /// `profile: default` et matcher un profil réellement nommé ainsi.
  Future<List<Voucher>> getVouchers(MikroTikRouter router, HotspotProfile profile) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final byMikrotikId = <String, Map<String, dynamic>>{};

      final byName = await client.get('/ip/hotspot/user', query: {'profile': profile.mikrotikName});
      for (final row in byName) {
        final id = row['.id'] as String?;
        if (id != null) byMikrotikId[id] = row;
      }

      final mikrotikId = profile.mikrotikId;
      if (mikrotikId != null) {
        final byId = await client.get('/ip/hotspot/user', query: {'profile': mikrotikId});
        for (final row in byId) {
          final id = row['.id'] as String?;
          if (id != null) byMikrotikId[id] = row;
        }
      }

      return byMikrotikId.values
          .where((row) => row['server'] != null)
          .map((row) => Voucher.fromRestJson(row, routerId: router.id, profileName: profile.mikrotikName))
          .toList();
    } finally {
      client.close();
    }
  }
}
