import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';

/// Contrat du repository de gestion des profils hotspot MikroTik.
///
/// Les profils sont définis sur le routeur MikroTik — l'app les synchronise
/// en cache local (sqflite) et les utilise lors de la génération de vouchers.
abstract class ProfilesRepository {
  /// Retourne les profils mis en cache pour un [routerId] donné.
  Future<Either<Failure, List<HotspotProfile>>> getProfiles(int routerId);

  /// Retourne la liste des address pools disponibles sur le routeur MikroTik.
  Future<Either<Failure, List<String>>> getAddressPools(int routerId);

  /// Synchronise les profils depuis le routeur MikroTik vers le cache local.
  ///
  /// Remplace tous les profils existants pour ce [routerId].
  Future<Either<Failure, List<HotspotProfile>>> syncProfiles(int routerId);

  /// Crée un profil hotspot sur le routeur MikroTik et l'enregistre en cache.
  Future<Either<Failure, HotspotProfile>> createProfile({
    required int routerId,
    required String name,
    required String addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool addMacCookie = true,
    String? macCookieTimeout,
    int sharedUsers = 1,
    DateTime? expiresAt,
  });

  Future<Either<Failure, HotspotProfile>> updateProfile({
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
  });

  /// Retourne les vouchers assignés à un profil depuis le cache local.
  Future<Either<Failure, List<Voucher>>> getProfileUsers({
    required int routerId,
    required String profileName,
  });

  /// Supprime une sélection de vouchers sur MikroTik et du cache local.
  Future<Either<Failure, Unit>> deleteProfileUsers({
    required int routerId,
    required List<int> voucherIds,
  });

  /// Supprime tous les vouchers d'un profil sur MikroTik et du cache local.
  Future<Either<Failure, Unit>> clearProfileUsers({
    required int routerId,
    required String profileName,
  });

  /// Supprime un profil hotspot sur MikroTik et du cache local.
  Future<Either<Failure, Unit>> deleteProfile(int profileId);

  /// Met à jour le prix local d'un profil (information non présente sur MikroTik).
  Future<Either<Failure, HotspotProfile>> updatePrice({required int profileId, required double price});
}
