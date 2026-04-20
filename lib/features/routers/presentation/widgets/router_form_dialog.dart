import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

/// Dialog de création ou modification d'un routeur MikroTik.
///
/// Si [router] est fourni → mode édition. Sinon → mode création.
class RouterFormDialog extends StatefulWidget {
  final MikroTikRouter? router;

  const RouterFormDialog({super.key, this.router});

  @override
  State<RouterFormDialog> createState() => _RouterFormDialogState();
}

class _RouterFormDialogState extends State<RouterFormDialog> {
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _ipFocus = FocusNode();
  final _portFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  RouterOsVersion _rosVersion = RouterOsVersion.v7;

  bool get _isEditing => widget.router != null;

  String _defaultPortFor(RouterOsVersion version) => version == RouterOsVersion.v7
      ? MikroTikRouter.defaultRestPort.toString()
      : MikroTikRouter.defaultPort.toString();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.router!;
      _nameController.text = r.name;
      _ipController.text = r.ip;
      _portController.text = r.port.toString();
      _usernameController.text = r.username;
      _passwordController.text = r.password;
      _rosVersion = r.rosVersion;
    } else {
      _portController.text = _defaultPortFor(RouterOsVersion.v7);
    }
  }

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

  void _submit() {
    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? MikroTikRouter.defaultPort;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || ip.isEmpty || username.isEmpty || password.isEmpty) return;

    if (_isEditing) {
      context.read<RoutersBloc>().add(RouterUpdated(
            id: widget.router!.id,
            name: name,
            ip: ip,
            port: port,
            username: username,
            password: password,
            rosVersion: _rosVersion,
          ));
    } else {
      context.read<RoutersBloc>().add(RouterAdded(
            name: name,
            ip: ip,
            port: port,
            username: username,
            password: password,
            rosVersion: _rosVersion,
          ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Modifier le routeur' : 'Ajouter un routeur',
        style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nom
            _FieldLabel('Nom'),
            SizedBox(height: AppSpacing.gapSm),
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _ipFocus.requestFocus(),
              style: AppTypography.input.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Site principal'),
            ),
            SizedBox(height: AppSpacing.gapLg),

            // IP + Port sur la même ligne
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Adresse IP'),
                      SizedBox(height: AppSpacing.gapSm),
                      TextField(
                        controller: _ipController,
                        focusNode: _ipFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _portFocus.requestFocus(),
                        style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: '192.168.1.1'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.gapMd),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Port'),
                      SizedBox(height: AppSpacing.gapSm),
                      TextField(
                        controller: _portController,
                        focusNode: _portFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _usernameFocus.requestFocus(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(hintText: _defaultPortFor(_rosVersion)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.gapLg),

            // Nom d'utilisateur
            _FieldLabel('Nom d\'utilisateur'),
            SizedBox(height: AppSpacing.gapSm),
            TextField(
              controller: _usernameController,
              focusNode: _usernameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              style: AppTypography.input.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'admin'),
            ),
            SizedBox(height: AppSpacing.gapLg),

            // Mot de passe
            _FieldLabel('Mot de passe'),
            SizedBox(height: AppSpacing.gapSm),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTypography.input.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: AppSpacing.iconMd,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.gapLg),

            // Version RouterOS
            _FieldLabel('Version RouterOS'),
            SizedBox(height: AppSpacing.gapSm),
            Row(
              children: RouterOsVersion.values.map((version) {
                final selected = _rosVersion == version;
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.gapSm),
                  child: ChoiceChip(
                    label: Text(
                      version == RouterOsVersion.v7 ? 'v7+ (recommandé)' : 'v6',
                      style: AppTypography.labelMd.copyWith(
                        color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _rosVersion = version;
                      if (!_isEditing) {
                        _portController.text = _defaultPortFor(version);
                      }
                    }),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bgSurface,
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.borderDefault,
                      width: AppSpacing.borderThin,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
    );
  }
}
