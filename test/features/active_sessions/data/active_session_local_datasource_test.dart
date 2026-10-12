import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/features/active_sessions/data/datasources/active_session_local_datasource.dart';

import '../../../helpers/test_database.dart';

void main() {
  late Database db;
  late ActiveSessionLocalDatasource datasource;

  setUp(() async {
    db = await openTestDatabase();
    datasource = ActiveSessionLocalDatasource(db);
  });

  tearDown(() => db.close());

  test('renvoie le profil de chaque code demandé', () async {
    await insertVoucher(db, routerId: 1, code: 'ABC123', profileName: '1h-500');
    await insertVoucher(db, routerId: 1, code: 'XYZ789', profileName: '1j-2000');
    await insertVoucher(db, routerId: 1, code: 'NOTASKED', profileName: '1h-500');

    final result = await datasource.getProfileNamesByCode(1, ['ABC123', 'XYZ789', 'INCONNU']);

    expect(result, {'ABC123': '1h-500', 'XYZ789': '1j-2000'});
  });

  test("ignore les vouchers d'un autre routeur", () async {
    await insertVoucher(db, routerId: 2, code: 'ABC123', profileName: '1h-500');

    final result = await datasource.getProfileNamesByCode(1, ['ABC123']);

    expect(result, isEmpty);
  });
}
