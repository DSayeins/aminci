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

  /// Crée plusieurs comptes hotspot (`PUT /ip/hotspot/user`) — les vouchers —
  /// pour [profile] sur [router]. Un seul client REST est réutilisé pour
  /// toute la série. Lance [MikroTikException] au premier échec.
  Future<List<Voucher>> createVouchers(
    MikroTikRouter router,
    HotspotProfile profile,
    List<({String code, String password})> credentials, {
    String? limitUptime,
    int limitBytesTotal = 0,
    String? comment,
    String? server,
  }) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final created = <Voucher>[];
      for (final credential in credentials) {
        final body = <String, dynamic>{
          'name': credential.code,
          'password': credential.password,
          'profile': profile.mikrotikName,
          if (server != null && server.isNotEmpty) 'server': server,
          if (limitUptime != null && limitUptime.isNotEmpty) 'limit-uptime': limitUptime,
          if (limitBytesTotal > 0) 'limit-bytes-total': limitBytesTotal.toString(),
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        };
        final result = await client.put('/ip/hotspot/user', body);
        created.add(Voucher.fromRestJson(result, routerId: router.id, profileName: profile.mikrotikName));
      }
      return created;
    } finally {
      client.close();
    }
  }

  /// Supprime plusieurs vouchers (`DELETE /ip/hotspot/user/{id}`) sur le
  /// routeur. Un seul client REST est réutilisé pour toute la série.
  /// Lance [MikroTikException] au premier échec.
  Future<void> deleteVouchers(MikroTikRouter router, List<String> mikrotikIds) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      for (final id in mikrotikIds) {
        await client.delete('/ip/hotspot/user/$id');
      }
    } finally {
      client.close();
    }
  }
}
