import 'dart:math';

import 'package:dartz/dartz.dart';

import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/mikrotik/mikrotik_service.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/data/services/voucher_print_service.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class VouchersRepositoryImpl implements VouchersRepository {
  final DatabaseHelper _db;

  const VouchersRepositoryImpl(this._db);

  // ---------------------------------------------------------------------------
  // Lecture locale
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<Voucher>>> getVouchers(int routerId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'vouchers',
        where: 'router_id = ?',
        whereArgs: [routerId],
        orderBy: 'created_at DESC',
      );
      return Right(rows.map(Voucher.fromMap).toList());
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les vouchers'));
    }
  }

  // ---------------------------------------------------------------------------
  // Serveurs hotspot
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<String>>> getHotspotServers(int routerId) async {
    final MikroTikRouter router;
    try {
      final db = await _db.database;
      final rows = await db.query('routers', where: 'id = ?', whereArgs: [routerId]);
      if (rows.isEmpty) return const Left(StorageFailure('Routeur introuvable'));
      router = MikroTikRouter.fromMap(rows.first);
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire le routeur'));
    }

    final service = MikroTikService.fromRouter(router);
    try {
      await service.connect();
      final servers = await service.listHotspotServers();
      await service.disconnect();
      return Right(servers);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (_) {
      return const Left(NetworkFailure('Connexion impossible au routeur'));
    }
  }

  // ---------------------------------------------------------------------------
  // Génération
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, List<Voucher>>> generateVouchers({
    required int routerId,
    required String profileName,
    required double price,
    required int quantity,
    required String createdBy,
    String? comment,
    String? limitUptime,
    int limitBytesTotal = 0,
    String? server,
    int usernameLength = 4,
    bool lettersOnly = false,
    bool samePassword = true,
  }) async {
    // 1. Récupérer le routeur
    final MikroTikRouter router;
    try {
      final db = await _db.database;
      final rows = await db.query('routers', where: 'id = ?', whereArgs: [routerId]);
      if (rows.isEmpty) return const Left(StorageFailure('Routeur introuvable'));
      router = MikroTikRouter.fromMap(rows.first);
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire le routeur'));
    }

    // 2. Charger les codes existants pour garantir l'unicité globale
    Set<String> existingCodes;
    try {
      final db = await _db.database;
      final rows = await db.query('vouchers', columns: ['code'], where: 'router_id = ?', whereArgs: [routerId]);
      existingCodes = rows.map((r) => r['code'] as String).toSet();
    } catch (_) {
      existingCodes = {};
    }

    // 3. Générer les paires (username, password) uniques
    final pairs = _generatePairs(
      count: quantity,
      length: usernameLength,
      lettersOnly: lettersOnly,
      samePassword: samePassword,
      existing: existingCodes,
    );

    // 3. Créer les users sur MikroTik
    final service = MikroTikService.fromRouter(router);

    try {
      await service.connect();
      for (final p in pairs) {
        await service.addUser(
          name: p.username,
          profile: profileName,
          password: p.password,
          comment: comment ?? 'Aminci — $createdBy',
          limitUptime: limitUptime,
          limitBytesTotal: limitBytesTotal > 0 ? limitBytesTotal : null,
          server: server,
        );
      }
      await service.disconnect();
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (_) {
      return const Left(NetworkFailure('Connexion impossible au routeur'));
    }

    // 4. Sauvegarder en local
    try {
      final db = await _db.database;
      final now = DateTime.now();
      final batch = db.batch();
      for (final p in pairs) {
        batch.insert('vouchers', {
          'router_id': routerId,
          'code': p.username,
          'password': p.password,
          'profile_name': profileName,
          'price': price,
          'status': VoucherStatus.pending.name,
          'created_at': now.millisecondsSinceEpoch ~/ 1000,
          'created_by': createdBy,
          if (comment != null) 'comment': comment,
          if (limitUptime != null) 'limit_uptime': limitUptime,
          'limit_bytes_total': limitBytesTotal,
          if (server != null) 'server': server,
        });
      }
      await batch.commit(noResult: true);

      final rows = await db.query(
        'vouchers',
        where: 'router_id = ? AND created_at = ?',
        whereArgs: [routerId, now.millisecondsSinceEpoch ~/ 1000],
        orderBy: 'id ASC',
      );
      return Right(rows.map(Voucher.fromMap).toList());
    } catch (_) {
      return const Left(StorageFailure('Vouchers créés sur MikroTik mais non sauvegardés localement'));
    }
  }

  // ---------------------------------------------------------------------------
  // Suppression
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> deleteVoucher({
    required int voucherId,
    required int routerId,
  }) async {
    // 1. Récupérer le voucher et le routeur
    final String voucherCode;
    final String? mikrotikId;
    final MikroTikRouter router;
    try {
      final db = await _db.database;

      final vRows = await db.query('vouchers', where: 'id = ?', whereArgs: [voucherId]);
      if (vRows.isEmpty) return const Left(StorageFailure('Voucher introuvable'));
      voucherCode = vRows.first['code'] as String;
      mikrotikId = vRows.first['mikrotik_id'] as String?;

      final rRows = await db.query('routers', where: 'id = ?', whereArgs: [routerId]);
      if (rRows.isEmpty) return const Left(StorageFailure('Routeur introuvable'));
      router = MikroTikRouter.fromMap(rRows.first);
    } catch (_) {
      return const Left(StorageFailure('Impossible de lire les données'));
    }

    // 2. Supprimer sur MikroTik
    final service = MikroTikService.fromRouter(router);
    try {
      await service.connect();
      if (mikrotikId != null && mikrotikId.isNotEmpty) {
        // Suppression directe via l'ID MikroTik stocké en cache
        await service.removeUser(mikrotikId);
      } else {
        // Fallback : recherche par nom si mikrotik_id absent
        final users = await service.listUsers();
        final match = users.where((u) => u['name'] == voucherCode).firstOrNull;
        if (match != null) {
          final id = match['.id'];
          if (id != null) await service.removeUser(id);
        }
      }
      await service.disconnect();
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on MikroTikException catch (e) {
      return Left(MikroTikFailure(e.message));
    } catch (_) {
      return const Left(NetworkFailure('Connexion impossible au routeur'));
    }

    // 3. Synchroniser le cache local (suppression de la DB)
    try {
      final db = await _db.database;
      await db.delete('vouchers', where: 'id = ?', whereArgs: [voucherId]);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure('Impossible de supprimer le voucher localement'));
    }
  }

  // ---------------------------------------------------------------------------
  // Impression
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> printVouchers(List<Voucher> vouchers) async {
    try {
      await const VoucherPrintService().print(vouchers);
      return const Right(unit);
    } catch (e) {
      return Left(StorageFailure('Impression impossible : $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static const _letters  = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _alphanum = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _digits   = '0123456789';

  List<({String username, String password})> _generatePairs({
    required int count,
    required int length,
    required bool lettersOnly,
    required bool samePassword,
    Set<String> existing = const {},
  }) {
    final rng   = Random.secure();
    final chars = lettersOnly ? _letters : _alphanum;
    final used  = <String>{...existing};
    final result = <({String username, String password})>[];

    while (result.length < count) {
      final username = List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
      if (used.contains(username)) continue;
      used.add(username);

      final password = samePassword
          ? username
          : List.generate(4, (_) => _digits[rng.nextInt(10)]).join();

      result.add((username: username, password: password));
    }
    return result;
  }
}
