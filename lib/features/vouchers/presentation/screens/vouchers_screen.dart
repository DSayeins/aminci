import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:aminci/features/vouchers/data/voucher_ticket_printer.dart';
import 'package:aminci/features/vouchers/presentation/widgets/generate_voucher_dialog.dart';
import 'package:aminci/features/vouchers/presentation/widgets/voucher_card.dart';
import 'package:aminci/shared/widgets/app_snackbar.dart';
import 'package:aminci/shared/widgets/empty_state.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<VouchersBloc>()),
        BlocProvider(create: (_) => sl<ProfilesBloc>()),
      ],
      child: const _VouchersView(),
    );
  }
}

class _VouchersView extends StatefulWidget {
  const _VouchersView();

  @override
  State<_VouchersView> createState() => _VouchersViewState();
}

class _VouchersViewState extends State<_VouchersView> {
  int? _selectedRouterId;

  // Garde en mémoire les IDs des vouchers fraîchement générés pour les mettre en avant
  Set<int> _newVoucherIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VouchersBloc, VouchersState>(
      listener: (context, state) {
        if (state is VouchersOperationSuccess) {
          AppSnackbar.success(context, state.message);
          if (state.newVouchers.isNotEmpty) {
            setState(() => _newVoucherIds = state.newVouchers.map((v) => v.id).toSet());
            _triggerPrint(context, state);
          } else {
            setState(() => _newVoucherIds = {});
          }
        }
        if (state is VouchersError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final vouchers = switch (state) {
          VouchersListLoaded(:final vouchers) => vouchers,
          VouchersOperationSuccess(:final vouchers) => vouchers,
          VouchersGenerating(:final vouchers) => vouchers,
          VouchersError(:final vouchers) => vouchers,
          _ => <Voucher>[],
        };

        final isGenerating = state is VouchersGenerating;
        final isLoading = state is VouchersLoading;

        return Padding(
          padding: AppSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vouchers', style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary)),
                        SizedBox(height: AppSpacing.gapXs),
                        Text(
                          '${vouchers.length} voucher${vouchers.length > 1 ? 's' : ''}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedRouterId != null)
                    SizedBox(
                      height: AppSpacing.buttonHeightMd,
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : () => _showGenerateDialog(context),
                        icon: isGenerating
                            ? SizedBox(
                                width: AppSpacing.iconMd,
                                height: AppSpacing.iconMd,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSpacing.borderDefault,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                        label: Text(isGenerating ? 'Génération...' : 'Générer'),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.gapXl),

              // Sélecteur de routeur
              BlocBuilder<RoutersBloc, RoutersState>(
                builder: (context, routersState) {
                  final routers = switch (routersState) {
                    RoutersListLoaded(:final routers) => routers,
                    RoutersOperationSuccess(:final routers) => routers,
                    _ => <MikroTikRouter>[],
                  };

                  if (routers.isEmpty) {
                    return const EmptyState(
                      icon: Icons.router_outlined,
                      title: 'Aucun routeur configuré',
                      subtitle: 'Configurez un routeur dans l\'onglet Routeurs pour accéder aux vouchers.',
                    );
                  }

                  return _RouterSelector(
                    routers: routers,
                    selectedId: _selectedRouterId,
                    onSelected: (id) {
                      setState(() {
                        _selectedRouterId = id;
                        _newVoucherIds = {};
                      });
                      context.read<VouchersBloc>().add(VouchersLoaded(id));
                      context.read<ProfilesBloc>().add(ProfilesLoaded(id));
                    },
                  );
                },
              ),
              SizedBox(height: AppSpacing.gapXl),

              // Liste des vouchers
              Expanded(
                child: _selectedRouterId == null
                    ? const SizedBox.shrink()
                    : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vouchers.isEmpty
                    ? EmptyState(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Aucun voucher',
                        subtitle: 'Générez des vouchers pour ce routeur.',
                        buttonLabel: 'Générer',
                        buttonIcon: Icons.add_rounded,
                        onAction: () => _showGenerateDialog(context),
                      )
                    : ListView.separated(
                        itemCount: vouchers.length,
                        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.gapMd),
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index];
                          return VoucherCard(
                            voucher: voucher,
                            isNew: _newVoucherIds.contains(voucher.id),
                            onDelete: () => _confirmDelete(context, voucher),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _triggerPrint(BuildContext context, VouchersOperationSuccess state) {
    // Récupérer le nom du routeur depuis RoutersBloc
    final routersState = context.read<RoutersBloc>().state;
    final routers = switch (routersState) {
      RoutersListLoaded(:final routers) => routers,
      RoutersOperationSuccess(:final routers) => routers,
      _ => <MikroTikRouter>[],
    };
    final router = routers.where((r) => r.id == _selectedRouterId).firstOrNull;
    final routerName = router?.name ?? '';

    // Récupérer les profils depuis ProfilesBloc (indexés par nom)
    final profilesState = context.read<ProfilesBloc>().state;
    final profiles = switch (profilesState) {
      ProfilesListLoaded(:final profiles) => profiles,
      ProfilesOperationSuccess(:final profiles) => profiles,
      _ => <HotspotProfile>[],
    };
    final profilesByName = {for (final p in profiles) p.mikrotikName: p};

    VoucherTicketPrinter.printTickets(
      vouchers: state.newVouchers,
      routerName: routerName,
      profilesByName: profilesByName,
    );
  }

  void _showGenerateDialog(BuildContext context) {
    final appState = context.read<AppBloc>().state;
    final createdBy = appState is AppNavigating ? appState.user.username : '';

    showDialog<void>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<VouchersBloc>()),
          BlocProvider.value(value: context.read<ProfilesBloc>()),
        ],
        child: GenerateVoucherDialog(
          routerId: _selectedRouterId!,
          createdBy: createdBy,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Voucher voucher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ce voucher ?', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Le voucher "${voucher.code}" sera supprimé localement et sur le routeur MikroTik.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<VouchersBloc>().add(VoucherDeleted(voucherId: voucher.id, routerId: _selectedRouterId!));
    }
  }
}

// -----------------------------------------------------------------------------
// Sélecteur de routeur (identique à ProfilesScreen)
// -----------------------------------------------------------------------------

class _RouterSelector extends StatelessWidget {
  final List<MikroTikRouter> routers;
  final int? selectedId;
  final void Function(int) onSelected;

  const _RouterSelector({required this.routers, required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: routers.map((router) {
          final isSelected = router.id == selectedId;
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.gapSm),
            child: GestureDetector(
              onTap: () => onSelected(router.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.bgSurface,
                  borderRadius: AppSpacing.borderFull,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDefault,
                    width: isSelected ? AppSpacing.borderDefault : AppSpacing.borderThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppSpacing.x2,
                      height: AppSpacing.x2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.gapSm),
                    Text(
                      router.name,
                      style: AppTypography.labelMd.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
