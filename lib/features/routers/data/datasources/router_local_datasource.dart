import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/router.dart';

abstract class RouterLocalDatasource {
  Future<List<MikroTikRouter>> getRouters();
  Future<MikroTikRouter> addRouter(MikroTikRouter router);
  Future<MikroTikRouter> updateRouter(MikroTikRouter router);
  Future<void> deleteRouter(int id);
}

class RouterLocalDatasourceImpl implements RouterLocalDatasource {
  final Database _db;

  const RouterLocalDatasourceImpl(this._db);

  @override
  Future<List<MikroTikRouter>> getRouters() async {
    try {
      final rows = await _db.query('routers', orderBy: 'created_at ASC');
      return rows.map(MikroTikRouter.fromMap).toList();
    } catch (e) {
      throw StorageException('Impossible de charger les routeurs : $e');
    }
  }

  @override
  Future<MikroTikRouter> addRouter(MikroTikRouter router) async {
    try {
      final id = await _db.insert('routers', router.toMap());
      return router.copyWith(id: id);
    } catch (e) {
      throw StorageException('Impossible d\'ajouter le routeur : $e');
    }
  }

  @override
  Future<MikroTikRouter> updateRouter(MikroTikRouter router) async {
    try {
      await _db.update(
        'routers',
        router.toMap(),
        where: 'id = ?',
        whereArgs: [router.id],
      );
      return router;
    } catch (e) {
      throw StorageException('Impossible de modifier le routeur : $e');
    }
  }

  @override
  Future<void> deleteRouter(int id) async {
    try {
      await _db.delete('routers', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw StorageException('Impossible de supprimer le routeur : $e');
    }
  }
}
