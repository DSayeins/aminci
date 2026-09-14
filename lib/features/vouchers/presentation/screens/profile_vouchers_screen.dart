import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:aminci/features/vouchers/presentation/widgets/generate_vouchers_dialog.dart';
import 'package:aminci/features/vouchers/presentation/widgets/voucher_tile.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';

/// Ouvre l'écran des vouchers générés pour [profile] sur [router].
///
/// Écran secondaire (poussé au-dessus de l'écran des profils), pas de route
/// go_router dédiée — cohérent avec les dialogs de création/modification.
Future<void> showProfileVouchersScreen(BuildContext context, MikroTikRouter router, HotspotProfile profile) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<VouchersBloc>()
          ..add(VouchersLoadRequested(router, profile)),
        child: ProfileVouchersScreen(router: router, profile: profile),
      ),
    ),
  );
}

class ProfileVouchersScreen extends StatefulWidget {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const ProfileVouchersScreen({super.key, required this.router, required this.profile});

  @override
  State<ProfileVouchersScreen> createState() => _ProfileVouchersScreenState();
}

class _ProfileVouchersScreenState extends State<ProfileVouchersScreen> {
  final Set<int> _selectedIds = {};

  bool get _isSelecting => _selectedIds.isNotEmpty;

  void _toggle(Voucher voucher) {
    setState(() {
      if (!_selectedIds.remove(voucher.id)) _selectedIds.add(voucher.id);
    });
  }

  void _clearSelection() => setState(_selectedIds.clear);

  void _selectAll(List<Voucher> vouchers) {
    setState(() {
      if (_selectedIds.length == vouchers.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(vouchers.map((v) => v.id));
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, List<Voucher> vouchers) async {
    final selected = vouchers.where((v) => _selectedIds.contains(v.id)).toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer les vouchers'),
        content: Text(
          selected.length == 1
              ? 'Supprimer le voucher « ${selected.first.code} » ? Cette action est irréversible.'
              : 'Supprimer ${selected.length} vouchers ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.textOnPrimary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<VouchersBloc>().add(VouchersDeleteRequested(widget.router, selected));
      _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VouchersBloc, VouchersState>(
      listener: (context, state) {
        if (state is! VouchersLoaded) return;
        // Retire de la sélection les vouchers qui ont disparu (supprimés).
        final currentIds = state.vouchers.map((v) => v.id).toSet();
        _selectedIds.removeWhere((id) => !currentIds.contains(id));
      },
      builder: (context, state) {
        final vouchers = state is VouchersLoaded
            ? state.vouchers
            : (state is VouchersError ? state.vouchers : const <Voucher>[]);
        final isBusy = state is VouchersLoaded && state.isBusy;

        return Scaffold(
          appBar: _isSelecting
              ? AppBar(
                  leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: _clearSelection),
                  title: Text('${_selectedIds.length} sélectionné${_selectedIds.length > 1 ? 's' : ''}'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.select_all_rounded),
                      tooltip: 'Tout sélectionner',
                      onPressed: () => _selectAll(vouchers),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Supprimer',
                      onPressed: isBusy ? null : () => _confirmDelete(context, vouchers),
                    ),
                  ],
                )
              : AppBar(
                  title: Text('Vouchers — ${widget.profile.mikrotikName}'),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.paddingMd),
                      child: TextButton.icon(
                        onPressed: () => showGenerateVouchersDialog(context),
                        icon: const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                        label: const Text('Générer des vouchers'),
                      ),
                    ),
                  ],
                ),
          body: Builder(
            builder: (context) {
              if (state is VouchersLoading || state is VouchersInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is VouchersError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => context.read<VouchersBloc>().add(
                        VouchersLoadRequested(widget.router, widget.profile),
                      ),
                );
              }

              if (vouchers.isEmpty) {
                return EmptyState(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Aucun voucher généré',
                  subtitle: 'Générez une première série de vouchers\npour ce profil.',
                  buttonLabel: 'Générer des vouchers',
                  buttonIcon: Icons.add_rounded,
                  onAction: () => showGenerateVouchersDialog(context),
                );
              }

              return ListView.separated(
                padding: AppSpacing.insetPage,
                itemCount: vouchers.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gapSm),
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  return VoucherTile(
                    voucher: voucher,
                    selected: _selectedIds.contains(voucher.id),
                    onTap: () => _toggle(voucher),
                    onLongPress: () => _toggle(voucher),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
