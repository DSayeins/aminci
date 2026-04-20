import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';

class GenerateVoucherDialog extends StatefulWidget {
  final int routerId;
  final String createdBy;

  const GenerateVoucherDialog({super.key, required this.routerId, required this.createdBy});

  @override
  State<GenerateVoucherDialog> createState() => _GenerateVoucherDialogState();
}

class _GenerateVoucherDialogState extends State<GenerateVoucherDialog> {
  HotspotProfile? _selectedProfile;
  final _priceController = TextEditingController();

  int _quantity = 1;
  int _usernameLength = 4;
  bool _lettersOnly = false;
  bool _samePassword = true;

  static const _quantities = [1, 5, 10, 20, 50, 80, 100];

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilesBloc, ProfilesState>(
      builder: (context, state) {
        final profiles = switch (state) {
          ProfilesListLoaded(:final profiles) => profiles,
          ProfilesOperationSuccess(:final profiles) => profiles,
          _ => <HotspotProfile>[],
        };

        return AlertDialog(
          title: Text('Générer des vouchers', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
          content: SizedBox(
            width: AppSpacing.dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Profil ---
                  Text('Profil', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.gapSm),
                  profiles.isEmpty
                      ? Text(
                          'Aucun profil disponible — synchronisez d\'abord les profils.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                        )
                      : DropdownButtonFormField<HotspotProfile>(
                          initialValue: _selectedProfile,
                          hint: Text('Choisir un profil', style: AppTypography.bodySm),
                          decoration: const InputDecoration(isDense: true),
                          items: profiles
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.mikrotikName, style: AppTypography.bodyMd)))
                              .toList(),
                          onChanged: (p) => setState(() {
                            _selectedProfile = p;
                            if (p != null && _priceController.text.isEmpty) {
                              _priceController.text = p.price > 0 ? p.price.toStringAsFixed(0) : '';
                            }
                          }),
                        ),
                  SizedBox(height: AppSpacing.gapLg),

                  // --- Prix ---
                  Text('Prix (FCFA)', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.gapSm),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(isDense: true, hintText: '0'),
                    style: AppTypography.bodyMd,
                  ),
                  SizedBox(height: AppSpacing.gapLg),

                  // --- Quantité ---
                  Text('Quantité', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.gapSm),
                  Wrap(
                    spacing: AppSpacing.gapSm,
                    runSpacing: AppSpacing.gapSm,
                    children: _quantities.map((q) {
                      final sel = _quantity == q;
                      return GestureDetector(
                        onTap: () => setState(() => _quantity = q),
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
                            '$q',
                            style: AppTypography.labelMd.copyWith(
                              color: sel ? AppColors.textOnPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: AppSpacing.gapLg),

                  // --- Code voucher ---
                  Text('Code voucher', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
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
                                  onTap: () => setState(() => _usernameLength = len),
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
                                onTap: () => setState(() => _lettersOnly = true),
                              ),
                              SizedBox(width: AppSpacing.gapSm),
                              _ToggleChip(
                                label: 'Lettres + chiffres',
                                selected: !_lettersOnly,
                                onTap: () => setState(() => _lettersOnly = false),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.gapMd),
                  Row(
                    children: [
                      Switch(
                        value: _samePassword,
                        onChanged: (v) => setState(() => _samePassword = v),
                      ),
                      SizedBox(width: AppSpacing.gapSm),
                      Text(
                        _samePassword ? 'Mot de passe identique au code' : 'Mot de passe séparé (4 chiffres)',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: _selectedProfile == null || profiles.isEmpty ? null : _onConfirm,
              child: Text('Générer $_quantity voucher${_quantity > 1 ? 's' : ''}'),
            ),
          ],
        );
      },
    );
  }

  void _onConfirm() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    context.read<VouchersBloc>().add(
      VouchersGenerated(
        routerId: widget.routerId,
        profileName: _selectedProfile!.mikrotikName,
        price: price,
        quantity: _quantity,
        createdBy: widget.createdBy,
        usernameLength: _usernameLength,
        lettersOnly: _lettersOnly,
        samePassword: _samePassword,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
