import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Base SQLite en mémoire avec la table `vouchers` — DDL recopié de
/// `DatabaseHelper._onCreate`, à garder synchronisé.
Future<Database> openTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await db.execute('''
    CREATE TABLE vouchers (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      router_id         INTEGER NOT NULL,
      code              TEXT    NOT NULL UNIQUE,
      password          TEXT    NOT NULL DEFAULT '',
      profile_name      TEXT    NOT NULL,
      price             REAL    NOT NULL DEFAULT 0,
      status            TEXT    NOT NULL DEFAULT 'pending'
                                CHECK(status IN ('active', 'pending', 'expired')),
      created_at        INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      created_by        TEXT    NOT NULL DEFAULT '',
      mikrotik_id       TEXT,
      server            TEXT,
      comment           TEXT,
      limit_uptime      TEXT,
      limit_bytes_total INTEGER NOT NULL DEFAULT 0,
      uptime            TEXT,
      bytes_in          INTEGER NOT NULL DEFAULT 0,
      bytes_out         INTEGER NOT NULL DEFAULT 0,
      disabled          INTEGER NOT NULL DEFAULT 0
    )
  ''');
  return db;
}

Future<void> insertVoucher(Database db, {required int routerId, required String code, required String profileName}) {
  return db.insert('vouchers', {'router_id': routerId, 'code': code, 'profile_name': profileName});
}
