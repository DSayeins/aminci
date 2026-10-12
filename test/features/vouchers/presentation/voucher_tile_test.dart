import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/presentation/widgets/voucher_tile.dart';

Voucher _voucher({String? comment}) => Voucher(
  id: 1,
  routerId: 1,
  code: 'ABC123',
  password: 'pw',
  profileName: '1h-500',
  price: 500,
  status: VoucherStatus.pending,
  createdAt: DateTime(2026, 10, 12),
  createdBy: 'admin',
  comment: comment,
);

Future<void> _pump(WidgetTester tester, Voucher voucher) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VoucherTile(voucher: voucher, selected: false, onTap: () {}, onLongPress: () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('affiche le commentaire quand il existe', (tester) async {
    await _pump(tester, _voucher(comment: 'lot du 14/09'));

    expect(find.text('lot du 14/09'), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
  });

  testWidgets("n'affiche rien quand le commentaire est vide", (tester) async {
    await _pump(tester, _voucher(comment: ''));

    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
  });
}
