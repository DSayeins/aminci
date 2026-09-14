import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/voucher.dart';

/// Accès à la table `vouchers` en base locale.
class VoucherLocalDatasource {
  final Database _db;

  const VoucherLocalDatasource(this._db);

  Future<List<Voucher>> getByProfile(int routerId, String profileName) async {
    try {
      final rows = await _db.query(
        'vouchers',
        where: 'router_id = ? AND profile_name = ?',
        whereArgs: [routerId, profileName],
        orderBy: 'created_at DESC',
      );
      return rows.map(Voucher.fromMap).toList();
    } catch (e) {
      throw StorageException('Impossible de charger les vouchers : $e');
    }
  }

  /// Ajoute un voucher nouvellement généré au cache local.
  Future<Voucher> insertVoucher(Voucher voucher) async {
    try {
      final id = await _db.insert('vouchers', voucher.toMap());
      return voucher.copyWith(id: id);
    } catch (e) {
      throw StorageException('Impossible d\'ajouter le voucher : $e');
    }
  }

  /// Supprime les vouchers [ids] du cache local.
  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      final placeholders = List.filled(ids.length, '?').join(', ');
      await _db.delete('vouchers', where: 'id IN ($placeholders)', whereArgs: ids);
    } catch (e) {
      throw StorageException('Impossible de supprimer les vouchers : $e');
    }
  }

  /// Supprime tous les vouchers du profil [profileName] du routeur [routerId]
  /// — appelé lors de la suppression du profil lui-même.
  Future<void> deleteAllForProfile(int routerId, String profileName) async {
    try {
      await _db.delete('vouchers', where: 'router_id = ? AND profile_name = ?', whereArgs: [routerId, profileName]);
    } catch (e) {
      throw StorageException('Impossible de supprimer les vouchers du profil : $e');
    }
  }

  /// Synchronise le cache local avec [remoteVouchers] pour le profil
  /// [profileName] du routeur [routerId] : met à jour les vouchers déjà
  /// connus en conservant leur `price`/`status`/`created_at`/`created_by`
  /// locaux (absents de RouterOS), insère les nouveaux, et supprime ceux qui
  /// n'existent plus sur le routeur. Scoping strict au profil concerné pour
  /// ne pas toucher les vouchers des autres profils.
  Future<void> syncFromRemote(int routerId, String profileName, List<Voucher> remoteVouchers) async {
    try {
      await _db.transaction((txn) async {
        final existingRows = await txn.query(
          'vouchers',
          where: 'router_id = ? AND profile_name = ?',
          whereArgs: [routerId, profileName],
        );
        final existingByMikrotikId = {
          for (final row in existingRows)
            if (row['mikrotik_id'] != null) row['mikrotik_id'] as String: row,
        };

        final remoteMikrotikIds = remoteVouchers.map((v) => v.mikrotikId).whereType<String>().toSet();

        for (final voucher in remoteVouchers) {
          final existing = existingByMikrotikId[voucher.mikrotikId];
          if (existing != null) {
            await txn.update(
              'vouchers',
              voucher.toMap()
                ..['price'] = existing['price']
                ..['status'] = existing['status']
                ..['created_at'] = existing['created_at']
                ..['created_by'] = existing['created_by'],
              where: 'id = ?',
              whereArgs: [existing['id']],
            );
          } else {
            await txn.insert('vouchers', voucher.toMap());
          }
        }

        for (final row in existingRows) {
          final mikrotikId = row['mikrotik_id'] as String?;
          if (mikrotikId != null && !remoteMikrotikIds.contains(mikrotikId)) {
            await txn.delete('vouchers', where: 'id = ?', whereArgs: [row['id']]);
          }
        }
      });
    } catch (e) {
      throw StorageException('Impossible de sauvegarder les vouchers : $e');
    }
  }
}
