import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Dialog de génération de vouchers.
///
/// Placeholder pour l'instant : la création réelle des comptes sur le
/// routeur n'est pas encore implémentée — ce dialog ne fait qu'annoncer que
/// la fonctionnalité arrive.
Future<void> showGenerateVouchersDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const _GenerateVouchersDialog());
}

class _GenerateVouchersDialog extends StatefulWidget {
  const _GenerateVouchersDialog();

  @override
  State<_GenerateVouchersDialog> createState() => _GenerateVouchersDialogState();
}

class _GenerateVouchersDialogState extends State<_GenerateVouchersDialog> {
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La génération de vouchers arrive bientôt.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Générer des vouchers'),
      contentPadding: AppSpacing.insetCard,
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.gapMd),
            AppTextField(
              label: 'Nombre de vouchers',
              controller: _quantityController,
              hint: '10',
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.gapMd),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        ElevatedButton(onPressed: _submit, child: const Text('Générer')),
      ],
    );
  }
}
