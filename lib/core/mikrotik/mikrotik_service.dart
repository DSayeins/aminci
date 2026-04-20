import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/router.dart';

/// Façade métier au-dessus de [MikroTikRestClient].
///
/// Expose les commandes hotspot MikroTik sous forme de méthodes Dart typées
/// via la REST API (MikroTik v7+, HTTP port 80).
///
/// Utiliser [MikroTikService.fromRouter] pour créer le service depuis un routeur.
class MikroTikService {
  final MikroTikRestClient _client;

  const MikroTikService(this._client);

  /// Crée le service depuis la configuration d'un routeur.
  factory MikroTikService.fromRouter(MikroTikRouter router) {
    return MikroTikService(
      MikroTikRestClient(host: router.ip, port: router.port, username: router.username, password: router.password),
    );
  }

  Future<void> connect() => _client.connect();
  Future<void> disconnect() => _client.disconnect();
  bool get isConnected => _client.isConnected;

  // ---------------------------------------------------------------------------
  // Vouchers — /ip/hotspot/user
  // ---------------------------------------------------------------------------

  Future<void> addUser({
    required String name,
    required String profile,
    String? password,
    String? comment,
    String? limitUptime,
    int? limitBytesTotal,
    String? server,
  }) async {
    await _client.put('/ip/hotspot/user', {
      'name': name,
      'profile': profile,
      if (password != null) 'password': password,
      if (comment != null) 'comment': comment,
      if (limitUptime != null) 'limit-uptime': limitUptime,
      if (limitBytesTotal != null && limitBytesTotal > 0) 'limit-bytes-total': limitBytesTotal.toString(),
      if (server != null) 'server': server,
    });
  }

  Future<List<String>> listAddressPools() async {
    final data = await _client.get('/ip/pool');
    return _fromList(data).map((m) => m['name'] ?? '').where((n) => n.isNotEmpty).toList();
  }

  Future<List<String>> listHotspotServers() async {
    final data = await _client.get('/ip/hotspot');
    return _fromList(data).map((m) => m['name'] ?? '').where((n) => n.isNotEmpty).toList();
  }

  Future<List<Map<String, String>>> listUsers({String? profile}) async {
    final data = await _client.get('/ip/hotspot/user', query: profile != null ? {'profile': profile} : null);
    return _fromList(data);
  }

  Future<void> updateUser({required String mikrotikId, String? profile, String? password, String? comment}) async {
    await _client.patch('/ip/hotspot/user/$mikrotikId', {
      if (profile != null) 'profile': profile,
      if (password != null) 'password': password,
      if (comment != null) 'comment': comment,
    });
  }

  Future<void> removeUser(String mikrotikId) async {
    await _client.delete('/ip/hotspot/user/$mikrotikId');
  }

  // ---------------------------------------------------------------------------
  // Sessions actives — /ip/hotspot/active
  // ---------------------------------------------------------------------------

  Future<List<Map<String, String>>> listActiveSessions() async {
    final data = await _client.get('/ip/hotspot/active');
    return _fromList(data);
  }

  Future<void> removeActiveSession(String mikrotikId) async {
    await _client.delete('/ip/hotspot/active/$mikrotikId');
  }

  // ---------------------------------------------------------------------------
  // Profils — /ip/hotspot/user/profile
  // ---------------------------------------------------------------------------

  Future<List<Map<String, String>>> listProfiles() async {
    final data = await _client.get('/ip/hotspot/user/profile');
    return _fromList(data);
  }

  Future<void> addProfile({
    required String name,
    required String addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool addMacCookie = true,
    String? macCookieTimeout,
    int sharedUsers = 1,
  }) async {
    await _client.put('/ip/hotspot/user/profile', {
      'name': name,
      'address-pool': addressPool,
      'shared-users': sharedUsers.toString(),
      'add-mac-cookie': addMacCookie ? 'true' : 'false',
      if (rateLimit != null) 'rate-limit': rateLimit,
      if (sessionTimeout != null) 'session-timeout': sessionTimeout,
      if (idleTimeout != null) 'idle-timeout': idleTimeout,
      if (keepaliveTimeout != null) 'keepalive-timeout': keepaliveTimeout,
      if (macCookieTimeout != null) 'mac-cookie-timeout': macCookieTimeout,
    });
  }

  Future<void> updateProfile({
    required String mikrotikId,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool? addMacCookie,
    String? macCookieTimeout,
    int? sharedUsers,
  }) async {
    await _client.patch('/ip/hotspot/user/profile/$mikrotikId', {
      if (rateLimit != null) 'rate-limit': rateLimit,
      if (sessionTimeout != null) 'session-timeout': sessionTimeout,
      if (idleTimeout != null) 'idle-timeout': idleTimeout,
      if (keepaliveTimeout != null) 'keepalive-timeout': keepaliveTimeout,
      if (addMacCookie != null) 'add-mac-cookie': addMacCookie ? 'true' : 'false',
      if (macCookieTimeout != null) 'mac-cookie-timeout': macCookieTimeout,
      if (sharedUsers != null) 'shared-users': sharedUsers.toString(),
    });
  }

  Future<void> removeProfile(String mikrotikId) async {
    await _client.delete('/ip/hotspot/user/profile/$mikrotikId');
  }

  // ---------------------------------------------------------------------------
  // Système — /system
  // ---------------------------------------------------------------------------

  Future<String> getIdentity() async {
    final data = await _client.get('/system/identity');
    return (data is Map ? data['name']?.toString() : null) ?? '';
  }

  Future<Map<String, String>> getSystemResource() async {
    final data = await _client.get('/system/resource');
    return _fromMap(data);
  }

  Future<Map<String, String>> getSystemClock() async {
    final data = await _client.get('/system/clock');
    return _fromMap(data);
  }

  // ---------------------------------------------------------------------------
  // Helpers privés
  // ---------------------------------------------------------------------------

  List<Map<String, String>> _fromList(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>).map((item) {
      final map = item as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    }).toList();
  }

  Map<String, String> _fromMap(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }
}
