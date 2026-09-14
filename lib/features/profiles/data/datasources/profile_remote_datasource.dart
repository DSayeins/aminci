import 'package:flutter/foundation.dart';

import 'package:aminci/core/mikrotik/mikrotik_rest_client.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';

/// Accès REST MikroTik pour la feature profils.
class ProfileRemoteDatasource {
  const ProfileRemoteDatasource();

  /// Liste les profils hotspot (`/ip/hotspot/user/profile/print`) d'un routeur.
  /// Lance [MikroTikException] en cas d'échec — voir [MikroTikRestClient].
  Future<List<HotspotProfile>> getProfiles(MikroTikRouter router) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final rows = await client.get('/ip/hotspot/user/profile');
      debugPrint('[ProfileRemoteDatasource] /ip/hotspot/user/profile brut (${rows.length}) : $rows');
      return rows.map((row) => HotspotProfile.fromRestJson(row, routerId: router.id)).toList();
    } finally {
      client.close();
    }
  }

  /// Crée un profil hotspot (`PUT /ip/hotspot/user/profile`) sur le routeur.
  /// Lance [MikroTikException] en cas d'échec.
  Future<HotspotProfile> createProfile(MikroTikRouter router, HotspotProfile profile) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      final body = <String, dynamic>{
        'name': profile.mikrotikName,
        if (profile.rateLimit != null && profile.rateLimit!.isNotEmpty) 'rate-limit': profile.rateLimit,
        if (profile.sessionTimeout != null && profile.sessionTimeout!.isNotEmpty)
          'session-timeout': profile.sessionTimeout,
        if (profile.addressPool != null && profile.addressPool!.isNotEmpty) 'address-pool': profile.addressPool,
        'shared-users': profile.sharedUsers.toString(),
      };
      final result = await client.put('/ip/hotspot/user/profile', body);
      return HotspotProfile.fromRestJson(result, routerId: router.id).copyWith(price: profile.price);
    } finally {
      client.close();
    }
  }

  /// Supprime un profil hotspot (`DELETE /ip/hotspot/user/profile/{id}`) sur
  /// le routeur. Lance [MikroTikException] en cas d'échec.
  Future<void> deleteProfile(MikroTikRouter router, String mikrotikId) async {
    final client = MikroTikRestClient(
      ip: router.ip,
      port: router.port,
      username: router.username,
      password: router.password,
    );
    try {
      await client.delete('/ip/hotspot/user/profile/$mikrotikId');
    } finally {
      client.close();
    }
  }
}
