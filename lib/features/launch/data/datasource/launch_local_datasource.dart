import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/app_state.dart';
import 'package:aminci/core/models/user.dart';

abstract class LaunchLocalDatasource {
  Future<bool> isFirstLaunch();
  Future<void> markFirstLaunchDone();

  /// Retourne l'utilisateur de la session active (non expirée), ou `null`
  /// si aucune session n'est valide.
  Future<User?> getActiveUser();
}

class LaunchLocalDatasourceImpl implements LaunchLocalDatasource {
  final Database _db;

  const LaunchLocalDatasourceImpl(this._db);

  @override
  Future<bool> isFirstLaunch() async {
    try {
      final result = await _db.query('app_state', where: 'id = 1', limit: 1);
      if (result.isEmpty) return true;
      return !AppState.fromMap(result.first).firstLaunchDone;
    } catch (e) {
      throw StorageException('Impossible de vérifier le premier lancement : $e');
    }
  }

  @override
  Future<void> markFirstLaunchDone() async {
    try {
      await _db.update('app_state', {'first_launch_done': 1}, where: 'id = 1');
    } catch (e) {
      throw StorageException('Impossible de mettre à jour l\'état de lancement : $e');
    }
  }

  @override
  Future<User?> getActiveUser() async {
    try {
      final rows = await _db.rawQuery('''
        SELECT u.id, u.name, u.username, u.role
        FROM active_session a
        INNER JOIN users u ON u.id = a.user_id
        WHERE a.expires_at > strftime('%s', 'now')
        LIMIT 1
      ''');
      if (rows.isEmpty) return null;
      return User.fromMap(rows.first);
    } catch (e) {
      throw StorageException('Impossible de vérifier la session active : $e');
    }
  }
}
