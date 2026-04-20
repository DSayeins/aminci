import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/profiles/domain/usecases/get_address_pools.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';

/// Dialog de création ou modification d'un profil hotspot MikroTik.
///
/// Si [profile] est fourni → mode édition. Sinon → mode création ([routerId] requis).
class ProfileFormDialog extends StatefulWidget {
  final int routerId;
  final HotspotProfile? profile;

  const ProfileFormDialog({super.key, required this.routerId, this.profile});

  @override
  State<ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<ProfileFormDialog> {
  final _nameController = TextEditingController();
  final _rateLimitController = TextEditingController();
  final _sessionTimeoutController = TextEditingController();
  final _idleTimeoutController = TextEditingController();
  final _keepaliveTimeoutController = TextEditingController();
  final _macCookieTimeoutController = TextEditingController();
  final _sharedUsersController = TextEditingController();

  final _rateFocus = FocusNode();
  final _sessionFocus = FocusNode();
  final _idleFocus = FocusNode();
  final _keepaliveFocus = FocusNode();
  final _macCookieFocus = FocusNode();
  final _sharedFocus = FocusNode();

  bool _addMacCookie = true;
  DateTime? _expiresAt;

  List<String> _pools = [];
  String? _selectedPool;
  bool _loadingPools = true;

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.profile!;
      _nameController.text = p.mikrotikName;
      _rateLimitController.text = p.rateLimit ?? '';
      _sessionTimeoutController.text = p.sessionTimeout ?? '';
      _idleTimeoutController.text = p.idleTimeout ?? '';
      _keepaliveTimeoutController.text = p.keepaliveTimeout ?? '';
      _macCookieTimeoutController.text = p.macCookieTimeout ?? '';
      _sharedUsersController.text = p.sharedUsers.toString();
      _addMacCookie = p.addMacCookie;
      _expiresAt = p.expiresAt;
      if (p.addressPool != null) {
        _pools = [p.addressPool!];
        _selectedPool = p.addressPool;
      }
    } else {
      _sharedUsersController.text = '1';
    }
    _loadPools();
  }

  Future<void> _loadPools() async {
    final result = await sl<GetAddressPools>()(widget.routerId);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingPools = false),
      (pools) => setState(() {
        _pools = pools;
        if (_selectedPool != null && !pools.contains(_selectedPool)) {
          _pools = [_selectedPool!, ...pools];
        }
        _loadingPools = false;
      }),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateLimitController.dispose();
    _sessionTimeoutController.dispose();
    _idleTimeoutController.dispose();
    _keepaliveTimeoutController.dispose();
    _macCookieTimeoutController.dispose();
    _sharedUsersController.dispose();
    _rateFocus.dispose();
    _sessionFocus.dispose();
    _idleFocus.dispose();
    _keepaliveFocus.dispose();
    _macCookieFocus.dispose();
    _sharedFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final pool = _selectedPool ?? '';
    if (name.isEmpty || pool.isEmpty) return;

    final rateLimit = _rateLimitController.text.trim();
    final sessionTimeout = _sessionTimeoutController.text.trim();
    final idleTimeout = _idleTimeoutController.text.trim();
    final keepaliveTimeout = _keepaliveTimeoutController.text.trim();
    final macCookieTimeout = _macCookieTimeoutController.text.trim();
    final sharedUsers = int.tryParse(_sharedUsersController.text.trim()) ?? 1;

    if (_isEditing) {
      context.read<ProfilesBloc>().add(ProfileUpdated(
            profileId: widget.profile!.id,
            routerId: widget.routerId,
            name: name,
            addressPool: pool,
            rateLimit: rateLimit.isEmpty ? null : rateLimit,
            sessionTimeout: sessionTimeout.isEmpty ? null : sessionTimeout,
            idleTimeout: idleTimeout.isEmpty ? null : idleTimeout,
            keepaliveTimeout: keepaliveTimeout.isEmpty ? null : keepaliveTimeout,
            addMacCookie: _addMacCookie,
            macCookieTimeout: macCookieTimeout.isEmpty ? null : macCookieTimeout,
            sharedUsers: sharedUsers,
            expiresAt: _expiresAt,
          ));
    } else {
      context.read<ProfilesBloc>().add(ProfileCreated(
            routerId: widget.routerId,
            name: name,
            addressPool: pool,
            rateLimit: rateLimit.isEmpty ? null : rateLimit,
            sessionTimeout: sessionTimeout.isEmpty ? null : sessionTimeout,
            idleTimeout: idleTimeout.isEmpty ? null : idleTimeout,
            keepaliveTimeout: keepaliveTimeout.isEmpty ? null : keepaliveTimeout,
            addMacCookie: _addMacCookie,
            macCookieTimeout: macCookieTimeout.isEmpty ? null : macCookieTimeout,
            sharedUsers: sharedUsers,
            expiresAt: _expiresAt,
          ));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing ? 'Modifier le profil' : 'Nouveau profil',
        style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: AppSpacing.dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel('Nom du profil'),
              SizedBox(height: AppSpacing.gapSm),
              TextField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _rateFocus.requestFocus(),
                style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'ex: basic'),
              ),
              SizedBox(height: AppSpacing.gapLg),

              _FieldLabel('Plage d\'adresses'),
              SizedBox(height: AppSpacing.gapSm),
              if (_loadingPools)
                const SizedBox(
                  height: AppSpacing.x10,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (_pools.isEmpty)
                Text(
                  'Aucune plage trouvée sur le routeur',
                  style: AppTypography.statSub.copyWith(color: AppColors.textTertiary),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedPool,
                  decoration: const InputDecoration(hintText: 'Choisir une plage'),
                  style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                  items: _pools
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, style: AppTypography.techData.copyWith(color: AppColors.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPool = v),
                ),
              SizedBox(height: AppSpacing.gapLg),

              // Limite de débit + Durée de session
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Limite de débit'),
                        SizedBox(height: AppSpacing.gapSm),
                        TextField(
                          controller: _rateLimitController,
                          focusNode: _rateFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _sessionFocus.requestFocus(),
                          style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'ex: 2M/2M'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Durée de session'),
                        SizedBox(height: AppSpacing.gapSm),
                        TextField(
                          controller: _sessionTimeoutController,
                          focusNode: _sessionFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _idleFocus.requestFocus(),
                          style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'ex: 1h'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.gapLg),

              // Délai d'inactivité + Délai keepalive
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Délai d\'inactivité'),
                        SizedBox(height: AppSpacing.gapSm),
                        TextField(
                          controller: _idleTimeoutController,
                          focusNode: _idleFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _keepaliveFocus.requestFocus(),
                          style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'ex: 5m'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Délai keepalive'),
                        SizedBox(height: AppSpacing.gapSm),
                        TextField(
                          controller: _keepaliveTimeoutController,
                          focusNode: _keepaliveFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _sharedFocus.requestFocus(),
                          style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'ex: 2m'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.gapLg),

              // Cookie MAC
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Durée du cookie MAC'),
                        SizedBox(height: AppSpacing.gapSm),
                        TextField(
                          controller: _macCookieTimeoutController,
                          focusNode: _macCookieFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _sharedFocus.requestFocus(),
                          enabled: _addMacCookie,
                          style: AppTypography.techData.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'ex: 3d'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.gapMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Cookie MAC'),
                      SizedBox(height: AppSpacing.gapSm),
                      Switch(
                        value: _addMacCookie,
                        onChanged: (v) => setState(() => _addMacCookie = v),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.gapLg),

              _FieldLabel('Utilisateurs simultanés'),
              SizedBox(height: AppSpacing.gapSm),
              TextField(
                controller: _sharedUsersController,
                focusNode: _sharedFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: '1'),
              ),
              SizedBox(height: AppSpacing.gapLg),

              _FieldLabel('Date d\'expiration'),
              SizedBox(height: AppSpacing.gapSm),
              _ExpiresAtPicker(
                value: _expiresAt,
                onChanged: (d) => setState(() => _expiresAt = d),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}

class _ExpiresAtPicker extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _ExpiresAtPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today_outlined, size: AppSpacing.iconSm),
            label: Text(
              value != null
                  ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                  : 'Aucune expiration',
              style: AppTypography.techData.copyWith(
                color: value != null ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x2,
              ),
            ),
          ),
        ),
        if (value != null) ...[
          SizedBox(width: AppSpacing.gapSm),
          IconButton(
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.clear),
            color: AppColors.textTertiary,
            iconSize: AppSpacing.iconMd,
            tooltip: 'Supprimer la date',
          ),
        ],
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
