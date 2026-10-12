import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/features/active_sessions/presentation/widgets/active_session_tile.dart';

Widget _wrap(ActiveSession session) {
  return MaterialApp(
    home: Scaffold(body: ActiveSessionTile(session: session, onDisconnect: () {})),
  );
}

void main() {
  testWidgets('affiche le profil du voucher', (tester) async {
    await tester.pumpWidget(_wrap(const ActiveSession(mikrotikId: '*1', code: 'ABC123', profileName: '1h-500')));

    expect(find.text('1h-500'), findsOneWidget);
  });
}
