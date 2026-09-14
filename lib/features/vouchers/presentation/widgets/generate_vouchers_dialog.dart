import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/features/vouchers/domain/usecases/generate_vouchers.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:aminci/features/vouchers/presentation/widgets/voucher_print.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Ouvre le dialog de génération de vouchers pour [profile] sur [router].
Future<void> showGenerateVouchersDialog(BuildContext context, MikroTikRouter router, HotspotProfile profile) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<VouchersBloc>(),
      child: _GenerateVouchersDialog(router: router, profile: profile),
    ),
  );
}

class _GenerateVouchersDialog extends StatefulWidget {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const _GenerateVouchersDialog({required this.router, required this.profile});

  @override
  State<_GenerateVouchersDialog> createState() => _GenerateVouchersDialogState();
}

class _GenerateVouchersDialogState extends State<_GenerateVouchersDialog> {
  late final _quantityController = TextEditingController(text: '10');
  late final _priceController = TextEditingController(text: widget.profile.price.toStringAsFixed(0));
  final _validityController = TextEditingController();
  final _quotaController = TextEditingController();
  final _commentController = TextEditingController();

  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _validityController.dispose();
    _quotaController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final quantity = int.tryParse(_quantityController.text.trim());
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    final quotaGb = double.tryParse(_quotaController.text.trim().replaceAll(',', '.'));

    setState(() => _error = null);

    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Nombre de vouchers invalide');
      return;
    }
    if (quantity > 200) {
      setState(() => _error = 'Maximum 200 vouchers à la fois');
      return;
    }
    if (price == null || price < 0) {
      setState(() => _error = 'Prix invalide');
      return;
    }

    final loginState = context.read<LoginBloc>().state;
    final createdBy = loginState is LoginAuthenticated ? loginState.user.username : '';

    final hotspotState = context.read<HotspotBloc>().state;
    final server = hotspotState is HotspotLoaded ? hotspotState.selected?.name : null;

    setState(() => _isSubmitting = true);

    final result = await sl<GenerateVouchers>()(
      widget.router,
      widget.profile,
      quantity: quantity,
      price: price,
      createdBy: createdBy,
      limitUptime: _validityController.text.trim().isEmpty ? null : _validityController.text.trim(),
      limitBytesTotal: ((quotaGb ?? 0) * 1073741824).round(),
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      server: server,
    );
    if (!mounted) return;

    await result.fold(
      (failure) async => setState(() {
        _isSubmitting = false;
        _error = failure.message;
      }),
      (created) async {
        context.read<VouchersBloc>().add(VouchersGenerated(created));
        Navigator.of(context).pop();
        // Sauvegarde le PDF dans Documents et lance directement l'impression.
        await saveAndPrintGeneratedVouchers(created, widget.profile);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Générer des vouchers'),
      contentPadding: AppSpacing.insetCard,
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.gapMd),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Nombre de vouchers',
                      controller: _quantityController,
                      hint: '10',
                      enabled: !_isSubmitting,
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: AppTextField(
                      label: 'Prix unitaire (FCFA)',
                      controller: _priceController,
                      hint: '500',
                      enabled: !_isSubmitting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapLg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Validité',
                      controller: _validityController,
                      hint: '1d',
                      tooltip:
                          'Durée de connexion cumulée autorisée avant expiration. Format MikroTik : h (heures), d (jours), w (semaines) — ex: 3h, 1d, 1w1d. Vide = illimité.',
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: AppTextField(
                      label: 'Quota de données (Go)',
                      controller: _quotaController,
                      hint: '5',
                      tooltip: 'Volume de données total autorisé (envoi + réception), en gigaoctets. Vide ou 0 = illimité.',
                      enabled: !_isSubmitting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapLg),
              AppTextField(
                label: 'Commentaire (optionnel)',
                controller: _commentController,
                hint: 'ex: lot du 14/09',
                enabled: !_isSubmitting,
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.gapMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.paddingSm,
                    vertical: AppSpacing.gapSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: AppSpacing.borderSm,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: AppSpacing.borderThin,
                    ),
                  ),
                  child: Text(_error!, style: TextStyle(color: AppColors.textError)),
                ),
              ],

              const SizedBox(height: AppSpacing.gapMd),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        SizedBox(
          height: AppSpacing.buttonHeightMd,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? SizedBox(
                    width: AppSpacing.iconMd,
                    height: AppSpacing.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSpacing.borderDefault,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Text('Générer'),
          ),
        ),
      ],
    );
  }
}
