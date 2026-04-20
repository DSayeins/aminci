import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/profiles/domain/usecases/clear_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profile_users.dart';
import 'package:aminci/features/profiles/presentation/bloc/profile_users_cubit.dart';
import 'package:aminci/features/profiles/presentation/widgets/voucher_row.dart';
import 'package:aminci/features/vouchers/domain/usecases/print_vouchers.dart';

class ProfileUsersDialog extends StatelessWidget {
  final HotspotProfile profile;

  const ProfileUsersDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileUsersCubit(
        GetIt.instance<GetProfileUsers>(),
        GetIt.instance<DeleteProfileUsers>(),
        GetIt.instance<ClearProfileUsers>(),
      )..load(routerId: profile.routerId, profileName: profile.mikrotikName),
      child: _ProfileUsersDialogBody(profile: profile),
    );
  }
}

class _ProfileUsersDialogBody extends StatefulWidget {
  final HotspotProfile profile;

  const _ProfileUsersDialogBody({required this.profile});

  @override
  State<_ProfileUsersDialogBody> createState() => _ProfileUsersDialogBodyState();
}

class _ProfileUsersDialogBodyState extends State<_ProfileUsersDialogBody> {
  final Set<int> _selected = {};

  void _toggleAll(List<Voucher> vouchers, bool select) {
    setState(() {
      if (select) {
        _selected.addAll(vouchers.map((v) => v.id));
      } else {
        _selected.clear();
      }
    });
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 500, maxWidth: 580, maxHeight: 600),
        child: BlocConsumer<ProfileUsersCubit, ProfileUsersState>(
          listener: (context, state) {
            // Après suppression, vider la sélection
            if (state is ProfileUsersLoaded && !state.isDeleting) {
              setState(() => _selected.clear());
            }
            if (state is ProfileUsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: AppTypography.bodySm),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<ProfileUsersCubit>();
            final vouchers = state is ProfileUsersLoaded ? state.vouchers : <Voucher>[];
            final isDeleting = state is ProfileUsersLoaded && state.isDeleting;
            final allSelected = vouchers.isNotEmpty && _selected.length == vouchers.length;

            return Padding(
              padding: AppSpacing.insetCard,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    children: [
                      if (vouchers.isNotEmpty)
                        Checkbox(
                          value: allSelected,
                          tristate: _selected.isNotEmpty && !allSelected,
                          onChanged: isDeleting ? null : (v) => _toggleAll(vouchers, v ?? false),
                          activeColor: AppColors.primary,
                        ),
                      SizedBox(width: AppSpacing.gapSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Utilisateurs — ${widget.profile.mikrotikName}',
                              style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
                            ),
                            if (vouchers.isNotEmpty)
                              Text(
                                '${vouchers.length} voucher${vouchers.length > 1 ? 's' : ''}${_selected.isNotEmpty ? ' · ${_selected.length} sélectionné${_selected.length > 1 ? 's' : ''}' : ''}',
                                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isDeleting ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: AppSpacing.iconMd),
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.gapMd),

                  // Contenu
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 120, maxHeight: 400),
                    child: _buildBody(context, state, vouchers, isDeleting),
                  ),

                  // Barre d'actions (visible si liste non vide)
                  if (vouchers.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.gapMd),
                    _buildActions(context, cubit, vouchers, isDeleting),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileUsersState state, List<Voucher> vouchers, bool isDeleting) {
    if (state is ProfileUsersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileUsersError) {
      return Center(
        child: Text(
          state.message,
          style: AppTypography.bodyMd.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded, size: AppSpacing.iconXl, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.gapMd),
            Text('Aucun voucher pour ce profil', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: vouchers.length,
          separatorBuilder: (_, _) => SizedBox(height: AppSpacing.gapSm),
          itemBuilder: (_, index) {
            final voucher = vouchers[index];
            final isSelected = _selected.contains(voucher.id);
            return VoucherRow(
              voucher: voucher,
              selected: isSelected,
              enabled: !isDeleting,
              onToggle: () => _toggle(voucher.id),
            );
          },
        ),
        if (isDeleting)
          Positioned.fill(
            child: Container(
              color: AppColors.bgSurface.withValues(alpha: 0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ProfileUsersCubit cubit, List<Voucher> vouchers, bool isDeleting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Imprimer la sélection
        if (_selected.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: isDeleting ? null : () => _onPrint(vouchers),
            icon: const Icon(Icons.print_outlined, size: AppSpacing.iconMd),
            label: Text('Imprimer (${_selected.length})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: AppSpacing.borderThin),
            ),
          ),
          SizedBox(width: AppSpacing.gapMd),
        ],

        // Supprimer la sélection
        if (_selected.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: isDeleting ? null : () => _confirmDelete(context, cubit, selected: true),
            icon: const Icon(Icons.delete_outline_rounded, size: AppSpacing.iconMd),
            label: Text('Supprimer (${_selected.length})'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error, width: AppSpacing.borderThin),
            ),
          ),
          SizedBox(width: AppSpacing.gapMd),
        ],

        // Tout supprimer
        FilledButton.icon(
          onPressed: isDeleting ? null : () => _confirmDelete(context, cubit, selected: false),
          icon: const Icon(Icons.delete_sweep_rounded, size: AppSpacing.iconMd),
          label: const Text('Tout supprimer'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
        ),
      ],
    );
  }

  void _onPrint(List<Voucher> allVouchers) {
    final toPrint = allVouchers.where((v) => _selected.contains(v.id)).toList();
    GetIt.instance<PrintVouchers>().call(toPrint);
  }

  void _confirmDelete(BuildContext context, ProfileUsersCubit cubit, {required bool selected}) {
    final count = selected ? _selected.length : null;
    final message = selected
        ? 'Supprimer ${count! > 1 ? 'ces $count vouchers' : 'ce voucher'} du profil et de MikroTik ?'
        : 'Supprimer tous les vouchers de ce profil sur MikroTik ?';

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Confirmer la suppression', style: AppTypography.sectionTitle),
        content: Text(message, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true) return;
      if (selected) {
        cubit.deleteUsers(_selected.toList());
      } else {
        cubit.clearAll();
      }
    });
  }
}
