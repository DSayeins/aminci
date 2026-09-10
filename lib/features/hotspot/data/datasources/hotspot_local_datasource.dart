import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/hotspot.dart';

/// Cache local (sqflite) des hotspots — table `hotspots`.
class HotspotLocalDatasource {
  final Database _db;

  const HotspotLocalDatasource(this._db);

  Future<List<Hotspot>> getHotspots(int routerId) async {
    try {
      final rows = await _db.query('hotspots', where: 'router_id = ?', whereArgs: [routerId]);
      return rows.map(Hotspot.fromMap).toList();
    } catch (e) {
      throw StorageException('Impossible de charger les hotspots : $e');
    }
  }

  /// Remplace le cache local des hotspots du routeur [routerId] par
  /// [hotspots] — synchronisation complète (supprime puis réinsère).
  Future<void> replaceAll(int routerId, List<Hotspot> hotspots) async {
    try {
      await _db.transaction((txn) async {
        await txn.delete('hotspots', where: 'router_id = ?', whereArgs: [routerId]);
        for (final hotspot in hotspots) {
          await txn.insert('hotspots', hotspot.toMap());
        }
      });
    } catch (e) {
      throw StorageException('Impossible de sauvegarder les hotspots : $e');
    }
  }
}
