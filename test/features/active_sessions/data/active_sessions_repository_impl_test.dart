import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/data/datasources/active_session_local_datasource.dart';
import 'package:aminci/features/active_sessions/data/datasources/active_session_remote_datasource.dart';
import 'package:aminci/features/active_sessions/data/repositories/active_sessions_repository_impl.dart';

import '../../../helpers/test_database.dart';

/// Remplace uniquement l'appel réseau MikroTik ; la base locale reste réelle.
class _FakeRemote implements ActiveSessionRemoteDatasource {
  final List<ActiveSession> sessions;

  _FakeRemote(this.sessions);

  @override
  Future<List<ActiveSession>> getActiveSessions(MikroTikRouter router) async => sessions;

  @override
  Future<void> disconnect(MikroTikRouter router, String mikrotikId) async {}
}

const _router = MikroTikRouter(id: 1, name: 'R1', ip: '192.168.88.1', port: 80, username: 'admin', password: 'x');

void main() {
  late Database db;

  setUp(() async => db = await openTestDatabase());
  tearDown(() => db.close());

  test('rattache à chaque session le profil de son voucher', () async {
    await insertVoucher(db, routerId: 1, code: 'ABC123', profileName: '1h-500');
    final remote = _FakeRemote(const [
      ActiveSession(
        mikrotikId: '*1',
        code: 'ABC123',
        address: '10.5.50.2',
        macAddress: 'AA:BB:CC:DD:EE:01',
        server: 'hotspot1',
        uptime: '5m30s',
        bytesIn: 1000,
        bytesOut: 200,
      ),
      ActiveSession(mikrotikId: '*2', code: 'WINBOX1', address: '10.5.50.3'),
    ]);
    final repository = ActiveSessionsRepositoryImpl(remote, ActiveSessionLocalDatasource(db));

    final result = await repository.getActiveSessions(_router);

    final sessions = result.getOrElse(() => fail('échec inattendu : $result'));
    expect(sessions[0].profileName, '1h-500');
    expect(sessions[0].address, '10.5.50.2');
    expect(sessions[0].uptime, '5m30s');
    expect(sessions[0].bytesIn, 1000);
    expect(sessions[1].profileName, isNull);
  });
}
