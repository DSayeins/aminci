import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Accès sqflite pour la feature logout — suppression de la session active.
class LogoutLocalDatasource {
  final Database _db;

  const LogoutLocalDatasource(this._db);

  /// Supprime la session active (`active_session`), déconnectant l'utilisateur.
  Future<void> clearSession() async {
    await _db.delete('active_session');
  }
}
