import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';

/// Accès REST MikroTik pour les sessions hotspot actives.
class ActiveSessionRemoteDatasource {
  const ActiveSessionRemoteDatasource();

  /// Liste les connexions actuellement actives (`/ip/hotspot/active`) sur
  /// [router]. Donnée live — jamais mise en cache localement.
  Future<List<ActiveSession>> getActiveSessions(MikroTikRouter router) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final rows = await client.get('/ip/hotspot/active');
      return rows.map(ActiveSession.fromRestJson).toList();
    } finally {
      client.close();
    }
  }

  /// Déconnecte une session active (`DELETE /ip/hotspot/active/{id}`).
  Future<void> disconnect(MikroTikRouter router, String mikrotikId) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      await client.delete('/ip/hotspot/active/$mikrotikId');
    } finally {
      client.close();
    }
  }
}
