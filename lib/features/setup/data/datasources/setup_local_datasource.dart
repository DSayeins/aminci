import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';

class SetupLocalDatasourceImpl {
  final Database _db;

  const SetupLocalDatasourceImpl(this._db);

  Future<void> create({required User user, required MikroTikRouter router, Preference? preference}) async {
    try {
      await _db.transaction((txn) async {
        // `user.password` est déjà hashé — voir CreateSetup (couche domain).
        // `User.toMap()` exclut volontairement `password` (jamais sérialisé
        // en clair) — on l'ajoute donc explicitement ici avant l'insertion.
        await txn.insert('users', {...user.toMap(), 'password': user.password});

        await txn.insert('routers', router.toMap());

        if (preference != null) {
          await txn.update('preferences', preference.toMap(), where: 'id = 1');
        }

        // Marque le premier lancement comme terminé — sinon le setup se
        // réaffiche à chaque redémarrage (voir LaunchLocalDatasource.isFirstLaunch).
        await txn.update('app_state', {'first_launch_done': 1}, where: 'id = 1');
      });
    } catch (e) {
      throw StorageException('Impossible de terminer la configuration initiale : $e');
    }
  }
}
