import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/mikrotik/mikrotik_service.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/profiles/data/datasource/profile_datasource.dart';
import 'package:aminci/features/profiles/data/datasource/profile_datasource_impl.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final DatabaseHelper _db;

  const ProfilesRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Helpers privés
  // ---------------------------------------------------------------------------

  Future<Either<Failure, MikroTikRouter>> _getRouter(int routerId) async {
    try {
      final db = await _db.database;
      final rows = await db.query('routers', where: 'id = ?', whereArgs: [routerId]);
      if (rows.isEmpty) return const Left(StorageFailure('Routeur introuvable'));
      return Right(MikroTikRouter.fromMap(rows.first));
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire le routeur'));
    }
  }

  /// Ouvre une connexion MikroTik, crée un [ProfileRemoteDatasource] lié,
  /// exécute [action], puis ferme la connexion dans le finally.
  Future<Either<Failure, T>> _withRemote<T>(
    MikroTikRouter router,
    Future<T> Function(ProfileRemoteDatasource remote) action,
  ) async {
    final service = MikroTikService.fromRouter(router);
    final remote = ProfileRemoteDatasourceImpl(service);
    try {
      await service.connect();
      final result = await action(remote);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (_) {
      return const Left(NetworkFailure('Connexion impossible au routeur'));
    } finally {
      await service.disconnect();
    }
  }

  ProfileLocalDatasource get _local => ProfileLocalDatasourceImpl(_db);

  // ---------------------------------------------------------------------------
  // Lecture cache local
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<HotspotProfile>>> getProfiles(int routerId) async {
    try {
      return Right(await _local.getProfiles(routerId));
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les profils'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAddressPools(int routerId) async {
    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => []);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final service = MikroTikService.fromRouter(router);
    try {
      await service.connect();
      final pools = await service.listAddressPools();
      await service.disconnect();
      return Right(pools);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (_) {
      return const Left(NetworkFailure('Connexion impossible au routeur'));
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronisation depuis MikroTik
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<HotspotProfile>>> syncProfiles(int routerId) async {
    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => []);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    debugPrint('[SyncProfiles] Routeur: ${router.name} (${router.ip}:${router.port})');

    final remoteResult = await _withRemote<List<Map<String, String>>>(router, (r) => r.listProfiles());
    if (remoteResult.isLeft()) return remoteResult.map((_) => []);
    final mikrotikProfiles = (remoteResult as Right).value as List<Map<String, String>>;

    debugPrint(
      '[SyncProfiles] ${mikrotikProfiles.length} profil(s): ${mikrotikProfiles.map((p) => p['name']).join(', ')}',
    );
    if (mikrotikProfiles.isNotEmpty) {
      // debugPrint(
      //   '[SyncProfiles] exemple → ${mikrotikProfiles[2].entries.map((e) => '${e.key}=${e.value}').join(' | ')}',
      // );
    }

    // Convertir les données MikroTik au format DB
    final rows = mikrotikProfiles
        .map(
          (p) => <String, dynamic>{
            'mikrotik_id': p['.id'],
            'mikrotik_name': p['name'] ?? '',
            'address_pool': p['address-pool'],
            'rate_limit': p['rate-limit'],
            'session_timeout': p['session-timeout'],
            'idle_timeout': p['idle-timeout'],
            'keepalive_timeout': p['keepalive-timeout'],
            'add_mac_cookie': (p['add-mac-cookie'] == 'true') ? 1 : 0,
            'mac_cookie_timeout': p['mac-cookie-timeout'],
            'shared_users': int.tryParse(p['shared-users'] ?? '1') ?? 1,
          },
        )
        .toList();

    try {
      final profiles = await _local.replaceProfiles(routerId, rows);
      debugPrint('[SyncProfiles] ✓ ${profiles.length} profil(s) synchronisé(s)');
      return Right(profiles);
    } catch (e) {
      debugPrint('[SyncProfiles] ✗ Mise à jour cache: $e');
      return const Left(StorageFailure('Impossible de mettre à jour les profils'));
    }
  }

  // ---------------------------------------------------------------------------
  // Création d'un profil
  // ---------------------------------------------------------------------------

  @override
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
  }) async {
    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => throw UnimplementedError());
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<void>(
      router,
      (r) => r.addProfile(
        name: name,
        addressPool: addressPool,
        rateLimit: rateLimit,
        sessionTimeout: sessionTimeout,
        idleTimeout: idleTimeout,
        keepaliveTimeout: keepaliveTimeout,
        addMacCookie: addMacCookie,
        macCookieTimeout: macCookieTimeout,
        sharedUsers: sharedUsers,
      ),
    );
    if (remoteResult.isLeft()) return remoteResult.map((_) => throw UnimplementedError());

    final syncResult = await syncProfiles(routerId);
    return syncResult.fold(
      Left.new,
      (profiles) async {
        final created = profiles.where((p) => p.mikrotikName == name).firstOrNull;
        if (created == null) return const Left(StorageFailure('Profil créé mais introuvable après synchronisation'));
        if (expiresAt != null) {
          await _local.updateProfile(created.id, {'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000});
          return Right(created.copyWith(expiresAt: expiresAt));
        }
        return Right(created);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Mise à jour d'un profil
  // ---------------------------------------------------------------------------

  @override
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
  }) async {
    final existing = await _local.getProfile(profileId);
    if (existing == null) return const Left(StorageFailure('Profil introuvable'));
    if (existing.mikrotikId == null) {
      return const Left(MikroTikFailure("Identifiant MikroTik manquant — synchronisez d'abord les profils"));
    }

    final routerResult = await _getRouter(existing.routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => throw UnimplementedError());
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<void>(
      router,
      (r) => r.updateProfile(
        mikrotikId: existing.mikrotikId!,
        rateLimit: rateLimit,
        sessionTimeout: sessionTimeout,
        idleTimeout: idleTimeout,
        keepaliveTimeout: keepaliveTimeout,
        addMacCookie: addMacCookie,
        macCookieTimeout: macCookieTimeout,
        sharedUsers: sharedUsers,
      ),
    );
    if (remoteResult.isLeft()) return remoteResult.map((_) => throw UnimplementedError());

    final syncResult = await syncProfiles(existing.routerId);
    return syncResult.fold(
      Left.new,
      (profiles) async {
        final updated = profiles.where((p) => p.mikrotikId == existing.mikrotikId).firstOrNull;
        if (updated == null) return const Left(StorageFailure('Profil modifié mais introuvable après synchronisation'));
        if (expiresAt != null) {
          await _local.updateProfile(updated.id, {'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000});
          return Right(updated.copyWith(expiresAt: expiresAt));
        }
        return Right(updated);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Utilisateurs d'un profil
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<Voucher>>> getProfileUsers({required int routerId, required String profileName}) async {
    debugPrint('[GetProfileUsers] routerId=$routerId profileName=$profileName');

    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => []);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<List<Map<String, String>>>(router, (r) => r.listUsersByProfile(profileName));
    if (remoteResult.isLeft()) {
      debugPrint('[GetProfileUsers] MikroTik injoignable — lecture du cache local');
      try {
        final cached = await _local.getVouchersByProfile(routerId, profileName);
        return Right(cached);
      } catch (_) {
        return const Left(StorageFailure('Impossible de lire le cache local'));
      }
    }
    final mikrotikUsers = (remoteResult as Right).value as List<Map<String, String>>;

    debugPrint('[GetProfileUsers] ${mikrotikUsers.length} utilisateur(s) pour profil=$profileName');
    if (mikrotikUsers.isNotEmpty) {
      debugPrint(
        '[GetProfileUsers] exemple → ${mikrotikUsers.first.entries.map((e) => '${e.key}=${e.value}').join(' | ')}',
      );
    }

    try {
      final mikrotikCodes = mikrotikUsers.map((u) => u['name'] ?? '').toSet()..remove('');
      final existing = await _local.getVouchersByProfile(routerId, profileName);
      final existingCodes = {for (final v in existing) v.code: v};

      // Insérer les users MikroTik absents du cache + mettre à jour les stats existants
      for (final user in mikrotikUsers) {
        final code = user['name'] ?? '';
        if (code.isEmpty) continue;

        final stats = _statsFromMikrotik(user);

        if (!existingCodes.containsKey(code)) {
          debugPrint('[GetProfileUsers] → Insertion: code=$code');
          await _local.insertVoucher({
            'router_id': routerId,
            'code': code,
            'password': user['password'] ?? '',
            'profile_name': profileName,
            'price': 0.0,
            'status': VoucherStatus.active.name,
            'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'created_by': 'mikrotik',
            ...stats,
          });
        } else {
          // Mettre à jour les stats live (uptime, bytes, disabled, etc.)
          await _local.updateVoucherStats(routerId, code, stats);
        }
      }

      // Supprimer du cache les vouchers absents de MikroTik
      final toDelete = existing.where((v) => !mikrotikCodes.contains(v.code)).toList();
      if (toDelete.isNotEmpty) {
        final ids = toDelete.map((v) => v.id).whereType<int>().toList();
        debugPrint('[GetProfileUsers] → Suppression cache: ${ids.length} voucher(s) absents de MikroTik');
        if (ids.isNotEmpty) await _local.deleteVouchersByIds(ids);
      }

      // Activer les vouchers en attente qui apparaissent sur MikroTik
      for (final voucher in existing) {
        if (mikrotikCodes.contains(voucher.code) && voucher.status == VoucherStatus.pending) {
          debugPrint('[GetProfileUsers] → Activation: code=${voucher.code}');
          await _local.updateVoucherStatus(routerId, voucher.code, VoucherStatus.active);
        }
      }

      final result = await _local.getVouchersByProfile(routerId, profileName);
      debugPrint('[GetProfileUsers] ✓ ${result.length} voucher(s) en cache');
      return Right(result);
    } catch (e) {
      debugPrint('[GetProfileUsers] ✗ Sync cache: $e');
      return const Left(StorageFailure('Impossible de synchroniser les utilisateurs'));
    }
  }

  // ---------------------------------------------------------------------------
  // Suppression de vouchers sélectionnés
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> deleteProfileUsers({required int routerId, required List<int> voucherIds}) async {
    if (voucherIds.isEmpty) return const Right(unit);
    debugPrint('[DeleteProfileUsers] ${voucherIds.length} voucher(s) — routerId=$routerId');

    // Lire les mikrotik_id et le nom du profil depuis le cache
    final List<String> mikrotikIds;
    final String profileName;
    try {
      final db = await _db.database;
      final placeholders = List.filled(voucherIds.length, '?').join(', ');
      final rows = await db.rawQuery(
        'SELECT mikrotik_id, profile_name FROM vouchers WHERE id IN ($placeholders)',
        voucherIds,
      );
      mikrotikIds = rows.map((r) => r['mikrotik_id'] as String?).whereType<String>().toList();
      profileName = rows.isNotEmpty ? (rows.first['profile_name'] as String? ?? '') : '';
      debugPrint('[DeleteProfileUsers] MikroTik IDs: $mikrotikIds — profil: $profileName');
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les données'));
    }

    // Supprimer sur MikroTik via les IDs directs
    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => unit);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<void>(router, (remote) async {
      for (final id in mikrotikIds) {
        await remote.removeUsers([id]);
      }
    });
    if (remoteResult.isLeft()) return remoteResult.map((_) => unit);

    // Synchroniser le cache local via getProfileUsers
    if (profileName.isNotEmpty) {
      await getProfileUsers(routerId: routerId, profileName: profileName);
    }
    return const Right(unit);
  }

  // ---------------------------------------------------------------------------
  // Suppression de tous les vouchers d'un profil
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> clearProfileUsers({required int routerId, required String profileName}) async {
    debugPrint('[ClearProfileUsers] routerId=$routerId profil=$profileName');

    final existing = await _local.getVouchersByProfile(routerId, profileName);
    final mikrotikIds = existing.map((v) => v.mikrotikId).whereType<String>().toList();
    debugPrint('[ClearProfileUsers] ${mikrotikIds.length} voucher(s) à supprimer');
    if (mikrotikIds.isEmpty) return const Right(unit);

    // Supprimer sur MikroTik via les IDs directs
    final routerResult = await _getRouter(routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => unit);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<void>(router, (remote) async {
      for (final id in mikrotikIds) {
        await remote.removeUsers([id]);
      }
    });
    if (remoteResult.isLeft()) return remoteResult.map((_) => unit);

    // Synchroniser le cache local via getProfileUsers
    await getProfileUsers(routerId: routerId, profileName: profileName);
    return const Right(unit);
  }

  /// Convertit les champs MikroTik bruts en colonnes DB pour les stats live.
  Map<String, dynamic> _statsFromMikrotik(Map<String, String> user) {
    return {
      'mikrotik_id': user['.id'],
      'server': user['server'],
      'comment': user['comment'],
      'limit_uptime': user['limit-uptime'],
      'limit_bytes_total': int.tryParse(user['limit-bytes-total'] ?? '0') ?? 0,
      'uptime': user['uptime'],
      'bytes_in': int.tryParse(user['bytes-in'] ?? '0') ?? 0,
      'bytes_out': int.tryParse(user['bytes-out'] ?? '0') ?? 0,
      'disabled': user['disabled'] == 'true' ? 1 : 0,
    };
  }

  // ---------------------------------------------------------------------------
  // Suppression d'un profil
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> deleteProfile(int profileId) async {
    final profile = await _local.getProfile(profileId);
    if (profile == null) return const Left(StorageFailure('Profil introuvable'));
    if (profile.mikrotikId == null) {
      return const Left(MikroTikFailure("Identifiant MikroTik manquant — synchronisez d'abord les profils"));
    }

    // 1. Supprimer les vouchers du profil sur MikroTik + synchroniser le cache
    final clearResult = await clearProfileUsers(
      routerId: profile.routerId,
      profileName: profile.mikrotikName,
    );
    if (clearResult.isLeft()) return clearResult;

    // 2. Supprimer le profil sur MikroTik
    final routerResult = await _getRouter(profile.routerId);
    if (routerResult.isLeft()) return routerResult.map((_) => unit);
    final router = (routerResult as Right<Failure, MikroTikRouter>).value;

    final remoteResult = await _withRemote<void>(router, (r) => r.removeProfile(profile.mikrotikId!));
    if (remoteResult.isLeft()) return remoteResult.map((_) => unit);

    // 3. Synchroniser les profils locaux
    final syncResult = await syncProfiles(profile.routerId);
    return syncResult.fold(Left.new, (_) => const Right(unit));
  }

  // ---------------------------------------------------------------------------
  // Mise à jour du prix local
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, HotspotProfile>> updatePrice({required int profileId, required double price}) async {
    try {
      return Right(await _local.updatePrice(profileId, price));
    } catch (_) {
      return const Left(StorageFailure('Impossible de modifier le prix'));
    }
  }
}
