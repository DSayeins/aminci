import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/profiles/domain/usecases/get_address_pools.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Ouvre le dialog d'ajout de profil et attend sa fermeture.
Future<void> showAddProfileDialog(BuildContext context, MikroTikRouter router) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<ProfilesBloc>(),
      child: _AddProfileDialog(router: router),
    ),
  );
}

/// Ouvre le dialog de modification d'un profil existant et attend sa fermeture.
Future<void> showEditProfileDialog(BuildContext context, MikroTikRouter router, HotspotProfile profile) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<ProfilesBloc>(),
      child: _AddProfileDialog(router: router, profile: profile),
    ),
  );
}

class _AddProfileDialog extends StatefulWidget {
  final MikroTikRouter router;

  /// Profil à modifier — `null` pour un ajout.
  final HotspotProfile? profile;

  const _AddProfileDialog({required this.router, this.profile});

  @override
  State<_AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<_AddProfileDialog> {
  late final _nameController = TextEditingController(text: widget.profile?.mikrotikName);
  late final _rateLimitController = TextEditingController(text: widget.profile?.rateLimit);
  late final _sessionTimeoutController = TextEditingController(text: widget.profile?.sessionTimeout);
  late final _sharedUsersController = TextEditingController(text: (widget.profile?.sharedUsers ?? 1).toString());
  late final _priceController = TextEditingController(
    text: widget.profile != null ? widget.profile!.price.toStringAsFixed(0) : '',
  );

  final _rateLimitFocus = FocusNode();
  final _sessionTimeoutFocus = FocusNode();
  final _sharedUsersFocus = FocusNode();
  final _priceFocus = FocusNode();

  String? _error;
  late String? _selectedAddressPool = widget.profile?.addressPool;
  List<String> _addressPools = [];
  bool _loadingPools = true;

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    _loadAddressPools();
  }

  Future<void> _loadAddressPools() async {
    final result = await sl<GetAddressPools>()(widget.router);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingPools = false), // silencieux — le pool reste optionnel
      (pools) => setState(() {
        _addressPools = pools;
        _loadingPools = false;
      }),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateLimitController.dispose();
    _sessionTimeoutController.dispose();
    _sharedUsersController.dispose();
    _priceController.dispose();
    _rateLimitFocus.dispose();
    _sessionTimeoutFocus.dispose();
    _sharedUsersFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final rateLimit = _rateLimitController.text.trim();
    final sessionTimeout = _sessionTimeoutController.text.trim();
    final sharedUsers = int.tryParse(_sharedUsersController.text.trim());
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));

    setState(() => _error = null);

    if (name.isEmpty) { setState(() => _error = 'Le nom est requis'); return; }
    if (sharedUsers == null || sharedUsers <= 0) { setState(() => _error = 'Nombre d\'utilisateurs invalide'); return; }
    if (price == null || price < 0) { setState(() => _error = 'Prix invalide'); return; }

    final profile = HotspotProfile(
      id: widget.profile?.id ?? 0,
      routerId: widget.router.id,
      mikrotikId: widget.profile?.mikrotikId,
      mikrotikName: name,
      rateLimit: rateLimit.isEmpty ? null : rateLimit,
      sessionTimeout: sessionTimeout.isEmpty ? null : sessionTimeout,
      addressPool: _selectedAddressPool,
      sharedUsers: sharedUsers,
      price: price,
      expiresAt: widget.profile?.expiresAt,
    );

    context.read<ProfilesBloc>().add(
      _isEditing ? ProfileUpdateRequested(widget.router, profile) : ProfileCreateRequested(widget.router, profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfilesBloc, ProfilesState>(
      listener: (context, state) {
        if (state is ProfilesLoaded && !state.isBusy) Navigator.of(context).pop();
        if (state is ProfilesError) setState(() => _error = state.message);
      },
      child: BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) {
          final isLoading = state is ProfilesLoaded && state.isBusy;

          return AlertDialog(
            title: Text(_isEditing ? 'Modifier le profil' : 'Ajouter un profil'),
            contentPadding: AppSpacing.insetCard,
            content: SizedBox(
              width: AppSpacing.dialogWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.gapMd),

                    AppTextField(
                      label: 'Nom du profil',
                      controller: _nameController,
                      hint: '1h - 500 FCFA',
                      enabled: !isLoading,
                      autofocus: true,
                      nextFocus: _rateLimitFocus,
                    ),
                    const SizedBox(height: AppSpacing.gapLg),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Débit (rate-limit)',
                            controller: _rateLimitController,
                            hint: '2M/1M',
                            focusNode: _rateLimitFocus,
                            enabled: !isLoading,
                            nextFocus: _sessionTimeoutFocus,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.gapMd),
                        Expanded(
                          child: AppTextField(
                            label: 'Durée (session-timeout)',
                            controller: _sessionTimeoutController,
                            hint: '1h',
                            focusNode: _sessionTimeoutFocus,
                            enabled: !isLoading,
                            nextFocus: _sharedUsersFocus,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.gapLg),

                    if (_loadingPools) ...[
                      const Center(child: SizedBox(
                        width: AppSpacing.iconMd,
                        height: AppSpacing.iconMd,
                        child: CircularProgressIndicator(strokeWidth: AppSpacing.borderDefault),
                      )),
                      const SizedBox(height: AppSpacing.gapLg),
                    ] else if (_addressPools.isNotEmpty) ...[
                      Text(
                        'Pool d\'adresses',
                        style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.gapSm),
                      Wrap(
                        spacing: AppSpacing.gapSm,
                        runSpacing: AppSpacing.gapSm,
                        children: _addressPools.map((pool) {
                          final selected = pool == _selectedAddressPool;
                          return ChoiceChip(
                            label: Text(pool),
                            selected: selected,
                            onSelected: isLoading
                                ? null
                                : (value) => setState(() => _selectedAddressPool = value ? pool : null),
                            selectedColor: AppColors.primaryLight,
                            labelStyle: AppTypography.labelMd.copyWith(
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            side: BorderSide(
                              color: selected ? AppColors.primary : AppColors.borderDefault,
                              width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
                            ),
                            backgroundColor: AppColors.bgSurface,
                            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.gapLg),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Utilisateurs simultanés',
                                style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.gapSm),
                              TextField(
                                controller: _sharedUsersController,
                                focusNode: _sharedUsersFocus,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _priceFocus.requestFocus(),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                                decoration: const InputDecoration(hintText: '1', fillColor: AppColors.bgPage),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.gapMd),
                        Expanded(
                          child: AppTextField(
                            label: 'Prix (FCFA)',
                            controller: _priceController,
                            hint: '500',
                            focusNode: _priceFocus,
                            enabled: !isLoading,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                      ],
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
                        child: Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.textError)),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.gapMd),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              SizedBox(
                height: AppSpacing.buttonHeightMd,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? SizedBox(
                          width: AppSpacing.iconMd,
                          height: AppSpacing.iconMd,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSpacing.borderDefault,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
