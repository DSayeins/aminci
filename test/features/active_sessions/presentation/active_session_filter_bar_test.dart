import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aminci/features/active_sessions/presentation/active_session_filter.dart';
import 'package:aminci/features/active_sessions/presentation/widgets/active_session_filter_bar.dart';

void main() {
  testWidgets('affiche une puce par option et renvoie le filtre cliqué', (tester) async {
    ProfileFilter? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveSessionFilterBar(
            options: const [AllProfiles(), NamedProfile('1h-500'), UnknownProfile()],
            selected: const AllProfiles(),
            onChanged: (filter) => tapped = filter,
          ),
        ),
      ),
    );

    expect(find.text('Tous'), findsOneWidget);
    expect(find.text('Inconnu'), findsOneWidget);

    await tester.tap(find.text('1h-500'));

    expect(tapped, const NamedProfile('1h-500'));
  });
}
