import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/enum/router_os_version.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Ouvre le dialog d'ajout de routeur et attend sa fermeture.
Future<void> showAddRouterDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<RoutersBloc>(),
      child: const _AddRouterDialog(),
    ),
  );
}

/// Ouvre le dialog de modification d'un routeur existant et attend sa fermeture.
Future<void> showEditRouterDialog(BuildContext context, MikroTikRouter router) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<RoutersBloc>(),
      child: _AddRouterDialog(router: router),
    ),
  );
}

class _AddRouterDialog extends StatefulWidget {
  /// Routeur à modifier — `null` pour un ajout.
  final MikroTikRouter? router;

  const _AddRouterDialog({this.router});

  @override
  State<_AddRouterDialog> createState() => _AddRouterDialogState();
}

class _AddRouterDialogState extends State<_AddRouterDialog> {
  late final _nameController = TextEditingController(text: widget.router?.name);
  late final _ipController = TextEditingController(text: widget.router?.ip);
  late final _portController = TextEditingController(
    text: (widget.router?.port ?? MikroTikRouter.defaultRestPort).toString(),
  );
  late final _usernameController = TextEditingController(text: widget.router?.username ?? 'admin');
  late final _passwordController = TextEditingController(text: widget.router?.password);

  final _ipFocus = FocusNode();
  final _portFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late RouterOsVersion _rosVersion = widget.router?.rosVersion ?? RouterOsVersion.v7;
  String? _error;

  bool get _isEditing => widget.router != null;

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _ipFocus.dispose();
    _portFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onVersionChanged(RouterOsVersion? v) {
    if (v == null) return;
    setState(() {
      _rosVersion = v;
      _portController.text = v == RouterOsVersion.v7
          ? MikroTikRouter.defaultRestPort.toString()
          : MikroTikRouter.defaultPort.toString();
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() => _error = null);

    if (name.isEmpty) { setState(() => _error = 'Le nom est requis'); return; }
    if (ip.isEmpty) { setState(() => _error = 'L\'adresse IP est requise'); return; }
    if (port == null || port <= 0) { setState(() => _error = 'Port invalide'); return; }
    if (username.isEmpty) { setState(() => _error = 'Le nom d\'utilisateur est requis'); return; }
    if (password.isEmpty) { setState(() => _error = 'Le mot de passe est requis'); return; }

    final router = MikroTikRouter(
      id: widget.router?.id ?? 0,
      name: name,
      ip: ip,
      port: port,
      username: username,
      password: password,
      rosVersion: _rosVersion,
    );

    context.read<RoutersBloc>().add(_isEditing ? RouterUpdateRequested(router) : RouterAddRequested(router));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutersBloc, RoutersState>(
      listener: (context, state) {
        if (state is RoutersLoaded && !state.isBusy) Navigator.of(context).pop();
        if (state is RoutersError) setState(() => _error = state.message);
      },
      child: BlocBuilder<RoutersBloc, RoutersState>(
        builder: (context, state) {
          final isLoading = state is RoutersLoaded && state.isBusy;

          return AlertDialog(
            title: Text(_isEditing ? 'Modifier le routeur' : 'Ajouter un routeur'),
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
                      label: 'Nom du site',
                      controller: _nameController,
                      hint: 'Cybercafé Central',
                      enabled: !isLoading,
                      autofocus: true,
                      nextFocus: _ipFocus,
                    ),
                    const SizedBox(height: AppSpacing.gapLg),

                    // Version RouterOS
                    Text('Version RouterOS', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.gapSm),
                    _RosVersionSelector(value: _rosVersion, enabled: !isLoading, onChanged: _onVersionChanged),
                    const SizedBox(height: AppSpacing.gapLg),

                    // IP + Port côte à côte
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            label: 'Adresse IP',
                            controller: _ipController,
                            hint: '192.168.1.1',
                            focusNode: _ipFocus,
                            enabled: !isLoading,
                            nextFocus: _portFocus,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.gapMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Port', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.gapSm),
                              TextField(
                                controller: _portController,
                                focusNode: _portFocus,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _usernameFocus.requestFocus(),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: '80',
                                  fillColor: AppColors.bgPage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.gapLg),

                    AppTextField(
                      label: 'Nom d\'utilisateur',
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      hint: 'admin',
                      enabled: !isLoading,
                      nextFocus: _passwordFocus,
                    ),
                    const SizedBox(height: AppSpacing.gapLg),

                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hint: '••••••••',
                      enabled: !isLoading,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
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

// -----------------------------------------------------------------------------
// Sélecteur de version RouterOS
// -----------------------------------------------------------------------------

class _RosVersionSelector extends StatelessWidget {
  final RouterOsVersion value;
  final bool enabled;
  final ValueChanged<RouterOsVersion?> onChanged;

  const _RosVersionSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RouterOsVersion.values.map((v) {
        final selected = v == value;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.gapSm),
          child: ChoiceChip(
            label: Text(v.name.toUpperCase()),
            selected: selected,
            onSelected: enabled ? (_) => onChanged(v) : null,
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
          ),
        );
      }).toList(),
    );
  }
}
