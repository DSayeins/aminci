import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';

/// Lecture du cache local des vouchers pour enrichir les sessions actives —
/// `/ip/hotspot/active` ne renvoie pas le profil, seul le code du voucher.
class ActiveSessionLocalDatasource {
  final Database _db;

  const ActiveSessionLocalDatasource(this._db);

  /// Profil (`profile_name`) de chaque voucher de [routerId] dont le code est
  /// dans [codes]. Les codes inconnus localement sont absents du résultat.
  Future<Map<String, String>> getProfileNamesByCode(int routerId, List<String> codes) async {
    if (codes.isEmpty) return {};
    try {
      final placeholders = List.filled(codes.length, '?').join(', ');
      final rows = await _db.rawQuery(
        'SELECT code, profile_name FROM vouchers WHERE router_id = ? AND code IN ($placeholders)',
        [routerId, ...codes],
      );
      return {for (final row in rows) row['code'] as String: row['profile_name'] as String};
    } catch (e) {
      throw StorageException('Impossible de lire les profils des sessions : $e');
    }
  }
}
