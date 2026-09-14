import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/routers/presentation/widgets/add_router_dialog.dart';
import 'package:aminci/shared/widgets/empty_state.dart';

class RoutersScreen extends StatelessWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutersBloc, RoutersState>(
      listener: (context, state) {
        if (state is RoutersError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Column(
          children: [
            const _Header(),
            const Expanded(child: _Body()),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutersBloc, RoutersState>(
      builder: (context, state) {
        final isBusy = state is RoutersLoaded && state.isBusy;

        return Container(
          height: AppSpacing.topbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingLg),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
            ),
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: AppSpacing.logoIconSize,
                height: AppSpacing.logoIconSize,
                decoration: const BoxDecoration(color: AppColors.logoBg, shape: BoxShape.circle),
                child: const Icon(
                  Icons.wifi_tethering_rounded,
                  color: AppColors.textOnPrimary,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.gapMd),
              Text('Aminci', style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
              const SizedBox(width: AppSpacing.gapXl),
              Container(width: AppSpacing.borderThin, height: AppSpacing.iconLg, color: AppColors.borderDefault),
              const SizedBox(width: AppSpacing.gapXl),
              Text('Routeurs MikroTik', style: AppTypography.topbarTitle.copyWith(color: AppColors.textPrimary)),

              const Spacer(),

              OutlinedButton.icon(
                onPressed: isBusy ? null : () => showAddRouterDialog(context),
                icon: const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                label: const Text('Ajouter'),
              ),
              const SizedBox(width: AppSpacing.gapMd),
              ElevatedButton.icon(
                onPressed: () => context.go('/hotspots'),
                icon: const Icon(Icons.arrow_forward_rounded, size: AppSpacing.iconMd),
                label: const Text('Accéder à l\'app'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Corps — liste des routeurs
// -----------------------------------------------------------------------------

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutersBloc, RoutersState>(
      builder: (context, state) {
        if (state is RoutersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final routers = switch (state) {
          RoutersLoaded(:final routers) => routers,
          RoutersError(:final routers) => routers,
          _ => const [],
        };

        if (routers.isEmpty) {
          return const EmptyState(
            icon: Icons.router_rounded,
            title: 'Aucun routeur configuré',
            subtitle: 'Ajoutez votre premier routeur MikroTik\npour commencer à générer des vouchers.',
          );
        }

        return GridView.builder(
          padding: AppSpacing.insetPage,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: AppSpacing.gapMd,
            crossAxisSpacing: AppSpacing.gapMd,
            childAspectRatio: 1.15,
          ),
          itemCount: routers.length,
          itemBuilder: (context, index) => _RouterCard(router: routers[index]),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Carte routeur
// -----------------------------------------------------------------------------

class _RouterCard extends StatelessWidget {
  final MikroTikRouter router;

  const _RouterCard({required this.router});

  Future<void> _confirmDelete(BuildContext context, MikroTikRouter router) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le routeur'),
        content: Text('Supprimer « ${router.name} » ? Cette action est irréversible.'),
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
      context.read<RoutersBloc>().add(RouterDeleteRequested(router.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutersBloc, RoutersState>(
      buildWhen: (prev, curr) {
        final prevSel = prev is RoutersLoaded ? prev.selectedRouter?.id : null;
        final currSel = curr is RoutersLoaded ? curr.selectedRouter?.id : null;
        return prevSel != currSel;
      },
      builder: (context, state) {
        final isSelected = state is RoutersLoaded && state.selectedRouter?.id == router.id;

        return Container(
          padding: AppSpacing.insetCard,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: AppSpacing.borderLg,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderDefault,
              width: isSelected ? AppSpacing.borderDefault : AppSpacing.borderThin,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSpacing.x10,
                    height: AppSpacing.x10,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : AppColors.bgSubtle,
                      borderRadius: AppSpacing.borderMd,
                    ),
                    child: Icon(
                      Icons.router_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      size: AppSpacing.iconLg,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                      decoration: BoxDecoration(color: AppColors.statusActiveBg, borderRadius: AppSpacing.borderFull),
                      child: Text('Actif', style: AppTypography.badge.copyWith(color: AppColors.statusActive)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapLg),
              Text(
                router.name,
                style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.gapXs),
              Text(
                '${router.ip}:${router.port}  •  ${router.rosVersion.name.toUpperCase()}',
                style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<RoutersBloc>().add(RouterSelected(router));
                        context.go('/hotspots');
                      },
                      child: const Text('Utiliser'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSm),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showEditRouterDialog(context, router),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDelete(context, router),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
