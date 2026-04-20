import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:aminci/shared/widgets/app_snackbar.dart';

class ProfileGenerateVoucherDialog extends StatefulWidget {
  final HotspotProfile profile;

  const ProfileGenerateVoucherDialog({super.key, required this.profile});

  @override
  State<ProfileGenerateVoucherDialog> createState() => _ProfileGenerateVoucherDialogState();
}

class _ProfileGenerateVoucherDialogState extends State<ProfileGenerateVoucherDialog> {
  final _priceController = TextEditingController();
  final _commentController = TextEditingController();
  final _limitUptimeController = TextEditingController();
  final _limitBytesController = TextEditingController();

  int _quantity = 1;
  _BytesUnit _bytesUnit = _BytesUnit.go;

  int _usernameLength = 4;
  bool _lettersOnly = false;
  bool _samePassword = true;

  List<String> _servers = [];
  String? _selectedServer;
  bool _loadingServers = true;

  static const _quantities = [1, 5, 10, 20, 50, 80, 100];

  @override
  void initState() {
    super.initState();
    if (widget.profile.price > 0) {
      _priceController.text = widget.profile.price.toStringAsFixed(0);
    }
    if (widget.profile.sessionTimeout != null) {
      _limitUptimeController.text = widget.profile.sessionTimeout!;
    }
    context.read<VouchersBloc>().add(VouchersHotspotServersRequested(widget.profile.routerId));
  }

  @override
  void dispose() {
    _priceController.dispose();
    _commentController.dispose();
    _limitUptimeController.dispose();
    _limitBytesController.dispose();
    super.dispose();
  }

  int get _limitBytesTotal {
    final raw = double.tryParse(_limitBytesController.text) ?? 0;
    if (raw <= 0) return 0;
    return (raw * _bytesUnit.bytes).round();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VouchersBloc, VouchersState>(
      listener: (context, state) {
        if (state is VouchersServersLoaded) {
          setState(() {
            _servers = state.servers;
            _loadingServers = false;
          });
        }
        if (state is VouchersOperationSuccess) Navigator.of(context).pop();
        if (state is VouchersError) AppSnackbar.error(context, state.message);
      },
      child: BlocBuilder<VouchersBloc, VouchersState>(
        builder: (context, state) {
          final isGenerating = state is VouchersGenerating;

          return AlertDialog(
            title: Text('Générer des vouchers', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
            content: SizedBox(
              width: AppSpacing.dialogWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Profil (lecture seule) ---
                    Container(
                      padding: AppSpacing.insetCardDense,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppSpacing.borderMd,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: AppSpacing.borderThin,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: AppSpacing.iconMd, color: AppColors.primary),
                          SizedBox(width: AppSpacing.gapSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.profile.mikrotikName,
                                  style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                                ),
                                if (widget.profile.rateLimit != null || widget.profile.sessionTimeout != null)
                                  Text(
                                    [
                                      if (widget.profile.rateLimit != null) widget.profile.rateLimit!,
                                      if (widget.profile.sessionTimeout != null) widget.profile.sessionTimeout!,
                                    ].join(' · '),
                                    style: AppTypography.statSub.copyWith(color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Prix ---
                    _FieldLabel('Prix (FCFA)'),
                    SizedBox(height: AppSpacing.gapSm),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: '0'),
                      enabled: !isGenerating,
                    ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Quantité ---
                    _FieldLabel('Quantité'),
                    SizedBox(height: AppSpacing.gapSm),
                    Wrap(
                      spacing: AppSpacing.gapSm,
                      runSpacing: AppSpacing.gapSm,
                      children: _quantities.map((q) {
                        final selected = _quantity == q;
                        return GestureDetector(
                          onTap: isGenerating ? null : () => setState(() => _quantity = q),
                          child: Container(
                            width: AppSpacing.x10,
                            height: AppSpacing.x10,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.bgSurface,
                              borderRadius: AppSpacing.borderMd,
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.borderDefault,
                                width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$q',
                              style: AppTypography.labelMd.copyWith(
                                color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Code voucher ---
                    _FieldLabel('Code voucher'),
                    SizedBox(height: AppSpacing.gapSm),
                    Row(
                      children: [
                        // Taille
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Taille', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
                            SizedBox(height: AppSpacing.gapXs),
                            Row(
                              children: [4, 6, 8].map((len) {
                                final sel = _usernameLength == len;
                                return Padding(
                                  padding: EdgeInsets.only(right: AppSpacing.gapSm),
                                  child: GestureDetector(
                                    onTap: isGenerating ? null : () => setState(() => _usernameLength = len),
                                    child: Container(
                                      width: AppSpacing.x10,
                                      height: AppSpacing.x10,
                                      decoration: BoxDecoration(
                                        color: sel ? AppColors.primary : AppColors.bgSurface,
                                        borderRadius: AppSpacing.borderMd,
                                        border: Border.all(
                                          color: sel ? AppColors.primary : AppColors.borderDefault,
                                          width: sel ? AppSpacing.borderDefault : AppSpacing.borderThin,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$len',
                                        style: AppTypography.labelMd.copyWith(
                                          color: sel ? AppColors.textOnPrimary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(width: AppSpacing.gapXl),
                        // Composition
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Composition', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
                            SizedBox(height: AppSpacing.gapXs),
                            Row(
                              children: [
                                _ToggleChip(
                                  label: 'Lettres',
                                  selected: _lettersOnly,
                                  enabled: !isGenerating,
                                  onTap: () => setState(() => _lettersOnly = true),
                                ),
                                SizedBox(width: AppSpacing.gapSm),
                                _ToggleChip(
                                  label: 'Lettres + chiffres',
                                  selected: !_lettersOnly,
                                  enabled: !isGenerating,
                                  onTap: () => setState(() => _lettersOnly = false),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.gapMd),
                    // Mot de passe
                    Row(
                      children: [
                        Switch(
                          value: _samePassword,
                          onChanged: isGenerating ? null : (v) => setState(() => _samePassword = v),
                        ),
                        SizedBox(width: AppSpacing.gapSm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _samePassword ? 'Mot de passe identique au code' : 'Mot de passe séparé (4 chiffres)',
                              style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Serveur hotspot ---
                    _FieldLabel('Serveur hotspot'),
                    SizedBox(height: AppSpacing.gapSm),
                    if (_loadingServers)
                      const SizedBox(
                        height: AppSpacing.x10,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (_servers.isEmpty)
                      Text('Aucun serveur trouvé', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary))
                    else
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedServer,
                        decoration: const InputDecoration(hintText: 'Tous les serveurs'),
                        style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'Tous les serveurs',
                              style: AppTypography.input.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          ..._servers.map(
                            (s) => DropdownMenuItem<String?>(
                              value: s,
                              child: Text(s, style: AppTypography.techData.copyWith(color: AppColors.textPrimary)),
                            ),
                          ),
                        ],
                        onChanged: isGenerating ? null : (v) => setState(() => _selectedServer = v),
                      ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Limites par voucher ---
                    _FieldLabel('Limites par voucher (optionnel)'),
                    SizedBox(height: AppSpacing.gapSm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Durée max cumulée
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Durée max', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
                              SizedBox(height: AppSpacing.gapXs),
                              TextField(
                                controller: _limitUptimeController,
                                style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                                decoration: const InputDecoration(hintText: 'ex: 1h, 7d'),
                                enabled: !isGenerating,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.gapMd),
                        // Quota données
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quota données',
                                style: AppTypography.statSub.copyWith(color: AppColors.textTertiary),
                              ),
                              SizedBox(height: AppSpacing.gapXs),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _limitBytesController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                                      decoration: const InputDecoration(hintText: '0'),
                                      enabled: !isGenerating,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.gapSm),
                                  DropdownButton<_BytesUnit>(
                                    value: _bytesUnit,
                                    underline: const SizedBox.shrink(),
                                    style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
                                    items: _BytesUnit.values
                                        .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                                        .toList(),
                                    onChanged: isGenerating ? null : (u) => setState(() => _bytesUnit = u!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.gapLg),

                    // --- Commentaire ---
                    _FieldLabel('Commentaire (optionnel)'),
                    SizedBox(height: AppSpacing.gapSm),
                    TextField(
                      controller: _commentController,
                      style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(hintText: 'ex: lot marché, événement...'),
                      enabled: !isGenerating,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isGenerating ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: isGenerating ? null : () => _submit(context),
                child: isGenerating
                    ? SizedBox(
                        width: AppSpacing.iconMd,
                        height: AppSpacing.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSpacing.borderDefault,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : Text('Générer $_quantity voucher${_quantity > 1 ? 's' : ''}'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    final createdBy = appState is AppNavigating ? appState.user.username : '';
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final comment = _commentController.text.trim();
    final limitUptime = _limitUptimeController.text.trim();

    context.read<VouchersBloc>().add(
      VouchersGenerated(
        routerId: widget.profile.routerId,
        profileName: widget.profile.mikrotikName,
        price: price,
        quantity: _quantity,
        createdBy: createdBy,
        comment: comment.isEmpty ? null : comment,
        limitUptime: limitUptime.isEmpty ? null : limitUptime,
        limitBytesTotal: _limitBytesTotal,
        server: _selectedServer,
        usernameLength: _usernameLength,
        lettersOnly: _lettersOnly,
        samePassword: _samePassword,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers internes
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary));
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x2),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgSurface,
          borderRadius: AppSpacing.borderFull,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDefault,
            width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

enum _BytesUnit {
  mo('Mo', 1048576),
  go('Go', 1073741824);

  final String label;
  final int bytes;
  const _BytesUnit(this.label, this.bytes);
}
