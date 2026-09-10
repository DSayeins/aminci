import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Singleton d'accès à la base de données SQLite locale (Windows via sqflite_common_ffi).
///
/// Toutes les couches data passent par [DatabaseHelper.instance] pour obtenir
/// une référence à la [Database]. Ne jamais instancier directement.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'aminci.db';
  static const _dbVersion = 12;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<Database> _open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbDir = await _resolveDbDirectory();
    final path = '$dbDir${Platform.pathSeparator}$_dbName';

    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );
  }

  /// Résout le répertoire de stockage — AppData/Roaming/Aminci sur Windows.
  Future<String> _resolveDbDirectory() async {
    final appData = Platform.environment['APPDATA'];
    final dir = Directory('${appData ?? '.'}/Aminci');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE routers ADD COLUMN ros_version TEXT NOT NULL DEFAULT 'v7'");
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE profiles ADD COLUMN mikrotik_id TEXT");
      await db.execute("ALTER TABLE profiles ADD COLUMN address_pool TEXT");
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE profiles ADD COLUMN idle_timeout TEXT");
      await db.execute("ALTER TABLE profiles ADD COLUMN keepalive_timeout TEXT");
      await db.execute("ALTER TABLE profiles ADD COLUMN add_mac_cookie INTEGER NOT NULL DEFAULT 1");
      await db.execute("ALTER TABLE profiles ADD COLUMN mac_cookie_timeout TEXT");
    }
    if (oldVersion < 5) {
      await db.execute("ALTER TABLE vouchers ADD COLUMN mikrotik_id TEXT");
      await db.execute("ALTER TABLE vouchers ADD COLUMN server TEXT");
      await db.execute("ALTER TABLE vouchers ADD COLUMN comment TEXT");
      await db.execute("ALTER TABLE vouchers ADD COLUMN limit_uptime TEXT");
      await db.execute("ALTER TABLE vouchers ADD COLUMN limit_bytes_total INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE vouchers ADD COLUMN uptime TEXT");
      await db.execute("ALTER TABLE vouchers ADD COLUMN bytes_in INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE vouchers ADD COLUMN bytes_out INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE vouchers ADD COLUMN disabled INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 6) {
      await db.execute("ALTER TABLE profiles ADD COLUMN expires_at INTEGER");
    }
    if (oldVersion < 7) {
      await db.execute("ALTER TABLE active_session ADD COLUMN expires_at INTEGER NOT NULL DEFAULT 0");
    }
    if (oldVersion < 8) {
      await db.execute("ALTER TABLE users ADD COLUMN name TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE app_state (
          id                 INTEGER PRIMARY KEY CHECK(id = 1),
          first_launch_done  INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.insert('app_state', {'id': 1, 'first_launch_done': 0});
    }
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE preferences (
          id           INTEGER PRIMARY KEY CHECK(id = 1),
          theme_mode   TEXT    NOT NULL DEFAULT 'system',
          language     TEXT    NOT NULL DEFAULT 'fr',
          currency     TEXT    NOT NULL DEFAULT 'FCFA',
          date_format  TEXT    NOT NULL DEFAULT 'dd/MM/yyyy'
        )
      ''');
      await db.insert('preferences', {
        'id': 1,
        'theme_mode': 'system',
        'language': 'fr',
        'currency': 'FCFA',
        'date_format': 'dd/MM/yyyy',
      });
    }
    if (oldVersion < 11) {
      await db.execute('ALTER TABLE users RENAME COLUMN password_hash TO password');
    }
    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE hotspots (
          id           INTEGER PRIMARY KEY AUTOINCREMENT,
          router_id    INTEGER NOT NULL REFERENCES routers(id) ON DELETE CASCADE,
          mikrotik_id  TEXT    NOT NULL,
          name         TEXT    NOT NULL,
          interface    TEXT    NOT NULL,
          address_pool TEXT,
          profile      TEXT,
          disabled     INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ---------------------------------------------------------------------------
  // Schéma — version 1
  // ---------------------------------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // -- Utilisateurs locaux (Admin / Opérateur) ------------------------------
    batch.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL DEFAULT '',
        username      TEXT    NOT NULL UNIQUE,
        password      TEXT    NOT NULL,
        role          TEXT    NOT NULL CHECK(role IN ('admin', 'operator')),
        created_at    INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // -- Session active persistée (au plus 1 ligne) ---------------------------
    batch.execute('''
      CREATE TABLE active_session (
        id         INTEGER PRIMARY KEY CHECK(id = 1),
        user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        expires_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') + 86400)
      )
    ''');

    // -- Routeurs MikroTik ----------------------------------------------------
    batch.execute('''
      CREATE TABLE routers (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        ip          TEXT    NOT NULL,
        port        INTEGER NOT NULL DEFAULT 8728,
        username    TEXT    NOT NULL,
        password    TEXT    NOT NULL,
        ros_version TEXT    NOT NULL DEFAULT 'v7',
        created_at  INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // -- Profils hotspot (cache local des profils MikroTik) -------------------
    batch.execute('''
      CREATE TABLE profiles (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        router_id           INTEGER NOT NULL REFERENCES routers(id) ON DELETE CASCADE,
        mikrotik_id         TEXT,
        mikrotik_name       TEXT    NOT NULL,
        address_pool        TEXT,
        rate_limit          TEXT,
        session_timeout     TEXT,
        idle_timeout        TEXT,
        keepalive_timeout   TEXT,
        add_mac_cookie      INTEGER NOT NULL DEFAULT 1,
        mac_cookie_timeout  TEXT,
        shared_users        INTEGER NOT NULL DEFAULT 1,
        price               REAL    NOT NULL DEFAULT 0,
        expires_at          INTEGER,
        synced_at           INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // -- Vouchers générés -----------------------------------------------------
    batch.execute('''
      CREATE TABLE vouchers (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        router_id         INTEGER NOT NULL REFERENCES routers(id) ON DELETE CASCADE,
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

    // -- Hotspots MikroTik (cache local, un routeur peut en avoir plusieurs) --
    batch.execute('''
      CREATE TABLE hotspots (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        router_id    INTEGER NOT NULL REFERENCES routers(id) ON DELETE CASCADE,
        mikrotik_id  TEXT    NOT NULL,
        name         TEXT    NOT NULL,
        interface    TEXT    NOT NULL,
        address_pool TEXT,
        profile      TEXT,
        disabled     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // -- État applicatif (au plus 1 ligne) — détecte le premier lancement ----
    batch.execute('''
      CREATE TABLE app_state (
        id                 INTEGER PRIMARY KEY CHECK(id = 1),
        first_launch_done  INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.insert('app_state', {'id': 1, 'first_launch_done': 0});

    // -- Préférences UI globales (au plus 1 ligne) ---------------------------
    batch.execute('''
      CREATE TABLE preferences (
        id           INTEGER PRIMARY KEY CHECK(id = 1),
        theme_mode   TEXT    NOT NULL DEFAULT 'system',
        language     TEXT    NOT NULL DEFAULT 'fr',
        currency     TEXT    NOT NULL DEFAULT 'FCFA',
        date_format  TEXT    NOT NULL DEFAULT 'dd/MM/yyyy'
      )
    ''');
    batch.insert('preferences', {
      'id': 1,
      'theme_mode': 'system',
      'language': 'fr',
      'currency': 'FCFA',
      'date_format': 'dd/MM/yyyy',
    });

    await batch.commit(noResult: true);
  }
}
