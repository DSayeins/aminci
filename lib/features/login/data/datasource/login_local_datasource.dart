import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Accès sqflite pour la feature login — recherche d'utilisateur et gestion
/// de la session active.
class LoginLocalDatasource {
  final Database _db;

  const LoginLocalDatasource(this._db);

  /// Retourne la ligne brute de l'utilisateur (`users`) par son username, ou
  /// `null` si aucun utilisateur ne correspond.
  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    final rows = await _db.query('users', where: 'username = ?', whereArgs: [username]);
    return rows.isEmpty ? null : rows.first;
  }

  /// Ouvre (ou remplace) la session active pour l'utilisateur [userId].
  /// Une seule ligne autorisée (`id = 1`).
  Future<void> createSession(int userId) async {
    await _db.insert(
      'active_session',
      {'id': 1, 'user_id': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
