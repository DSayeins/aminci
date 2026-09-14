import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/profile.dart';

/// Cache local (sqflite) des profils hotspot — table `profiles`.
class ProfileLocalDatasource {
  final Database _db;

  const ProfileLocalDatasource(this._db);

  Future<HotspotProfile> insertProfile(HotspotProfile profile) async {
    try {
      final id = await _db.insert('profiles', profile.toMap());
      return profile.copyWith(id: id);
    } catch (e) {
      throw StorageException('Impossible d\'ajouter le profil : $e');
    }
  }

  Future<HotspotProfile> updateProfile(HotspotProfile profile) async {
    try {
      await _db.update('profiles', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
      return profile;
    } catch (e) {
      throw StorageException('Impossible de modifier le profil : $e');
    }
  }

  Future<void> deleteProfile(int id) async {
    try {
      await _db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw StorageException('Impossible de supprimer le profil : $e');
    }
  }

  Future<List<HotspotProfile>> getProfiles(int routerId) async {
    try {
      final rows = await _db.query('profiles', where: 'router_id = ?', whereArgs: [routerId], orderBy: 'mikrotik_name ASC');
      return rows.map(HotspotProfile.fromMap).toList();
    } catch (e) {
      throw StorageException('Impossible de charger les profils : $e');
    }
  }

  /// Synchronise le cache local avec [remoteProfiles] : met à jour les
  /// profils déjà connus en conservant leur `price`/`expires_at` locaux
  /// (absents de RouterOS), insère les nouveaux, et supprime ceux qui
  /// n'existent plus sur le routeur.
  Future<void> syncFromRemote(int routerId, List<HotspotProfile> remoteProfiles) async {
    try {
      await _db.transaction((txn) async {
        final existingRows = await txn.query('profiles', where: 'router_id = ?', whereArgs: [routerId]);
        final existingByMikrotikId = {
          for (final row in existingRows)
            if (row['mikrotik_id'] != null) row['mikrotik_id'] as String: row,
        };

        final remoteMikrotikIds = remoteProfiles.whereType<HotspotProfile>().map((p) => p.mikrotikId).whereType<String>().toSet();

        for (final profile in remoteProfiles) {
          final existing = existingByMikrotikId[profile.mikrotikId];
          if (existing != null) {
            await txn.update(
              'profiles',
              profile.toMap()
                ..['price'] = existing['price']
                ..['expires_at'] = existing['expires_at'],
              where: 'id = ?',
              whereArgs: [existing['id']],
            );
          } else {
            await txn.insert('profiles', profile.toMap());
          }
        }

        for (final row in existingRows) {
          final mikrotikId = row['mikrotik_id'] as String?;
          if (mikrotikId != null && !remoteMikrotikIds.contains(mikrotikId)) {
            await txn.delete('profiles', where: 'id = ?', whereArgs: [row['id']]);
          }
        }
      });
    } catch (e) {
      throw StorageException('Impossible de sauvegarder les profils : $e');
    }
  }
}
