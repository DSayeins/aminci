import 'package:aminci/core/database/database_helper.dart';
import 'package:aminci/core/mikrotik/mikrotik_service.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/profiles/data/datasource/profile_datasource.dart';

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  final DatabaseHelper _db;

  const ProfileLocalDatasourceImpl(this._db);

  @override
  Future<List<HotspotProfile>> getProfiles(int routerId) async {
    final db = await _db.database;
    final rows = await db.query(
      'profiles',
      where: 'router_id = ?',
      whereArgs: [routerId],
      orderBy: 'id DESC',
    );
    return rows.map(HotspotProfile.fromMap).toList();
  }

  @override
  Future<HotspotProfile?> getProfile(int profileId) async {
    final db = await _db.database;
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [profileId]);
    if (rows.isEmpty) return null;
    return HotspotProfile.fromMap(rows.first);
  }

  @override
  Future<List<HotspotProfile>> replaceProfiles(int routerId, List<Map<String, dynamic>> rows) async {
    final db = await _db.database;
    final updated = await db.transaction<List<Map<String, dynamic>>>((txn) async {
      // Conserver les prix par nom avant suppression
      final existing = await txn.query('profiles', where: 'router_id = ?', whereArgs: [routerId]);
      final priceByName = {for (final r in existing) r['mikrotik_name'] as String: (r['price'] as num).toDouble()};

      await txn.delete('profiles', where: 'router_id = ?', whereArgs: [routerId]);

      for (final row in rows) {
        final name = row['mikrotik_name'] as String? ?? '';
        if (name.isEmpty) continue;
        await txn.insert('profiles', {...row, 'router_id': routerId, 'price': priceByName[name] ?? 0.0});
      }

      return txn.query('profiles', where: 'router_id = ?', whereArgs: [routerId], orderBy: 'id DESC');
    });
    return updated.map(HotspotProfile.fromMap).toList();
  }

  @override
  Future<HotspotProfile> insertProfile(Map<String, dynamic> data) async {
    final db = await _db.database;
    final id = await db.insert('profiles', data);
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    return HotspotProfile.fromMap(rows.first);
  }

  @override
  Future<HotspotProfile> updateProfile(int profileId, Map<String, dynamic> data) async {
    final db = await _db.database;
    if (data.isNotEmpty) {
      await db.update('profiles', data, where: 'id = ?', whereArgs: [profileId]);
    }
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [profileId]);
    return HotspotProfile.fromMap(rows.first);
  }

  @override
  Future<HotspotProfile> updatePrice(int profileId, double price) async {
    final db = await _db.database;
    await db.update('profiles', {'price': price}, where: 'id = ?', whereArgs: [profileId]);
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [profileId]);
    return HotspotProfile.fromMap(rows.first);
  }

  @override
  Future<void> deleteProfile(int profileId) async {
    final db = await _db.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [profileId]);
  }

  @override
  Future<List<Voucher>> getVouchersByProfile(int routerId, String profileName) async {
    final db = await _db.database;
    final rows = await db.query(
      'vouchers',
      where: 'router_id = ? AND profile_name = ?',
      whereArgs: [routerId, profileName],
      orderBy: 'created_at DESC',
    );
    return rows.map(Voucher.fromMap).toList();
  }

  @override
  Future<void> insertVoucher(Map<String, dynamic> data) async {
    final db = await _db.database;
    await db.insert('vouchers', data);
  }

  @override
  Future<void> updateVoucherStatus(int routerId, String code, VoucherStatus status) async {
    final db = await _db.database;
    await db.update(
      'vouchers',
      {'status': status.name},
      where: 'router_id = ? AND code = ?',
      whereArgs: [routerId, code],
    );
  }

  @override
  Future<void> deleteVouchersByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = List.filled(ids.length, '?').join(', ');
    await db.rawDelete('DELETE FROM vouchers WHERE id IN ($placeholders)', ids);
  }

  @override
  Future<void> deleteVouchersByProfile(int routerId, String profileName) async {
    final db = await _db.database;
    await db.delete('vouchers', where: 'router_id = ? AND profile_name = ?', whereArgs: [routerId, profileName]);
  }

  @override
  Future<void> updateVoucherStats(int routerId, String code, Map<String, dynamic> stats) async {
    if (stats.isEmpty) return;
    final db = await _db.database;
    await db.update(
      'vouchers',
      stats,
      where: 'router_id = ? AND code = ?',
      whereArgs: [routerId, code],
    );
  }
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final MikroTikService _service;

  const ProfileRemoteDatasourceImpl(this._service);

  @override
  Future<List<Map<String, String>>> listProfiles() => _service.listProfiles();

  @override
  Future<void> addProfile({
    required String name,
    required String addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool addMacCookie = true,
    String? macCookieTimeout,
    int sharedUsers = 1,
  }) => _service.addProfile(
    name: name,
    addressPool: addressPool,
    rateLimit: rateLimit,
    sessionTimeout: sessionTimeout,
    idleTimeout: idleTimeout,
    keepaliveTimeout: keepaliveTimeout,
    addMacCookie: addMacCookie,
    macCookieTimeout: macCookieTimeout,
    sharedUsers: sharedUsers,
  );

  @override
  Future<void> updateProfile({
    required String mikrotikId,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool? addMacCookie,
    String? macCookieTimeout,
    int? sharedUsers,
  }) => _service.updateProfile(
    mikrotikId: mikrotikId,
    rateLimit: rateLimit,
    sessionTimeout: sessionTimeout,
    idleTimeout: idleTimeout,
    keepaliveTimeout: keepaliveTimeout,
    addMacCookie: addMacCookie,
    macCookieTimeout: macCookieTimeout,
    sharedUsers: sharedUsers,
  );

  @override
  Future<void> removeProfile(String mikrotikId) => _service.removeProfile(mikrotikId);

  @override
  Future<List<Map<String, String>>> listUsersByProfile(String profileName) => _service.listUsers(profile: profileName);

  @override
  Future<void> removeUsers(List<String> mikrotikIds) async {
    for (final id in mikrotikIds) {
      await _service.removeUser(id);
    }
  }
}
