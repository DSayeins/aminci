import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';

/// Accès REST MikroTik pour la feature hotspot.
class HotspotRemoteDatasource {
  const HotspotRemoteDatasource();

  /// Liste les serveurs hotspot (`/ip/hotspot/print`) d'un routeur.
  /// Lance [MikroTikException] en cas d'échec — voir [MikroTikRestClient].
  Future<List<Hotspot>> getHotspots(MikroTikRouter router) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final rows = await client.get('/ip/hotspot');
      return rows.map((row) => Hotspot.fromRestJson(row, routerId: router.id)).toList();
    } finally {
      client.close();
    }
  }
}
