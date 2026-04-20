// =============================================================================
// Datasource local — SQLite (table profiles + vouchers)
// =============================================================================

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';

abstract class ProfileLocalDatasource {
  /// Retourne tous les profils d'un routeur depuis le cache local.
  Future<List<HotspotProfile>> getProfiles(int routerId);

  /// Retourne un profil par son identifiant local.
  Future<HotspotProfile?> getProfile(int profileId);

  /// Remplace tous les profils d'un routeur dans une transaction atomique.
  ///
  /// Les prix existants sont conservés par nom de profil.
  Future<List<HotspotProfile>> replaceProfiles(int routerId, List<Map<String, dynamic>> rows);

  /// Insère un nouveau profil et retourne l'entité avec son [id] local.
  Future<HotspotProfile> insertProfile(Map<String, dynamic> data);

  /// Met à jour les champs d'un profil existant.
  Future<HotspotProfile> updateProfile(int profileId, Map<String, dynamic> data);

  /// Met à jour le prix local d'un profil.
  Future<HotspotProfile> updatePrice(int profileId, double price);

  /// Supprime un profil du cache local.
  Future<void> deleteProfile(int profileId);

  // --- Vouchers d'un profil ---

  /// Retourne les vouchers en cache pour un profil donné.
  Future<List<Voucher>> getVouchersByProfile(int routerId, String profileName);

  /// Insère un voucher absent du cache.
  Future<void> insertVoucher(Map<String, dynamic> data);

  /// Met à jour le statut d'un voucher identifié par son code.
  Future<void> updateVoucherStatus(int routerId, String code, VoucherStatus status);

  /// Supprime des vouchers par leurs identifiants locaux.
  Future<void> deleteVouchersByIds(List<int> ids);

  /// Supprime tous les vouchers d'un profil.
  Future<void> deleteVouchersByProfile(int routerId, String profileName);

  /// Met à jour les stats live d'un voucher existant (données MikroTik temps réel).
  Future<void> updateVoucherStats(int routerId, String code, Map<String, dynamic> stats);
}

// =============================================================================
// Datasource distant — MikroTik REST API
// =============================================================================

abstract class ProfileRemoteDatasource {
  /// Liste tous les profils hotspot depuis MikroTik.
  Future<List<Map<String, String>>> listProfiles();

  /// Crée un profil hotspot sur MikroTik.
  Future<void> addProfile({
    required String name,
    required String addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool addMacCookie,
    String? macCookieTimeout,
    int sharedUsers,
  });

  /// Modifie un profil existant sur MikroTik.
  Future<void> updateProfile({
    required String mikrotikId,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool? addMacCookie,
    String? macCookieTimeout,
    int? sharedUsers,
  });

  /// Supprime un profil sur MikroTik.
  Future<void> removeProfile(String mikrotikId);

  /// Liste les utilisateurs (vouchers) d'un profil sur MikroTik.
  Future<List<Map<String, String>>> listUsersByProfile(String profileName);

  /// Supprime une liste d'utilisateurs sur MikroTik par leurs identifiants MikroTik.
  Future<void> removeUsers(List<String> mikrotikIds);
}
