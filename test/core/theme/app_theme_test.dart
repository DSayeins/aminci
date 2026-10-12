import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_theme.dart';

/// Couleur réellement rendue du libellé — RawChip ne résout que la couleur
/// d'un TextStyle (WidgetStateColor), pas un WidgetStateTextStyle entier.
Color? _renderedLabelColor(WidgetTester tester, String label) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  return paragraph.text.style?.color;
}

Future<void> _pumpChips(WidgetTester tester, ThemeData theme) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Row(
          children: [
            ChoiceChip(label: const Text('Choisie'), selected: true, onSelected: (_) {}),
            ChoiceChip(label: const Text('Autre'), selected: false, onSelected: (_) {}),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('thème clair : libellé des puces visible et coloré selon la sélection', (tester) async {
    await _pumpChips(tester, AppTheme.light);

    expect(_renderedLabelColor(tester, 'Choisie'), AppColors.primary);
    expect(_renderedLabelColor(tester, 'Autre'), AppColors.textSecondary);
  });

  testWidgets('thème sombre : libellé des puces visible et coloré selon la sélection', (tester) async {
    await _pumpChips(tester, AppThemeDark.dark);

    expect(_renderedLabelColor(tester, 'Choisie'), AppColorsDark.primary);
    expect(_renderedLabelColor(tester, 'Autre'), AppColorsDark.textSecondary);
  });
}
