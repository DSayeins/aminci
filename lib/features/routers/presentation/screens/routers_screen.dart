import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/routers/presentation/widgets/router_card.dart';
import 'package:aminci/features/routers/presentation/widgets/router_form_dialog.dart';
import 'package:aminci/shared/widgets/app_snackbar.dart';
import 'package:aminci/shared/widgets/empty_state.dart';

class RoutersScreen extends StatelessWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RoutersView();
  }
}

class _RoutersView extends StatefulWidget {
  const _RoutersView();

  @override
  State<_RoutersView> createState() => _RoutersViewState();
}

class _RoutersViewState extends State<_RoutersView> {
  @override
  void initState() {
    context.read<RoutersBloc>().add(const RoutersLoaded());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutersBloc, RoutersState>(
      listener: (context, state) {
        if (state is RoutersOperationSuccess) {
          AppSnackbar.success(context, state.message);
        }
        if (state is RoutersError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final routers = switch (state) {
          RoutersListLoaded(:final routers) => routers,
          RoutersOperationSuccess(:final routers) => routers,
          RouterTestingConnection(:final routers) => routers,
          RouterConnectionResult(:final routers) => routers,
          _ => <MikroTikRouter>[],
        };

        final isLoading = state is RoutersLoading;
        final testingId = state is RouterTestingConnection ? state.routerId : null;
        final connectionResult = state is RouterConnectionResult ? state : null;

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
                        Text('Routeurs', style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary)),
                        SizedBox(height: AppSpacing.gapXs),
                        Text(
                          '${routers.length} routeur${routers.length > 1 ? 's' : ''} configuré${routers.length > 1 ? 's' : ''}',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSpacing.buttonHeightMd,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _showAddDialog(context),
                      icon: const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                      label: const Text('Ajouter'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.gapXl),

              // Contenu
              Expanded(
                child: isLoading && routers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : routers.isEmpty
                    ? EmptyState(
                        icon: Icons.router_outlined,
                        title: 'Aucun routeur configuré',
                        subtitle: 'Ajoutez un routeur MikroTik pour commencer.',
                        buttonLabel: 'Ajouter un routeur',
                        buttonIcon: Icons.add_rounded,
                        onAction: () => _showAddDialog(context),
                      )
                    : ListView.separated(
                        itemCount: routers.length,
                        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.gapMd),
                        itemBuilder: (context, index) {
                          final router = routers[index];
                          return RouterCard(
                            router: router,
                            isTesting: testingId == router.id,
                            connectionResult: connectionResult?.routerId == router.id ? connectionResult : null,
                            onTest: () => context.read<RoutersBloc>().add(RouterConnectionTested(router.id)),
                            onEdit: () => _showEditDialog(context, router),
                            onDelete: () => _confirmDelete(context, router),
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

  void _showAddDialog(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => const RouterFormDialog());
  }

  void _showEditDialog(BuildContext context, MikroTikRouter router) {
    showDialog<void>(
      context: context,
      builder: (_) => RouterFormDialog(router: router),
    );
  }

  Future<void> _confirmDelete(BuildContext context, MikroTikRouter router) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer ce routeur ?', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Le routeur "${router.name}" et tous ses vouchers associés seront supprimés.',
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
      context.read<RoutersBloc>().add(RouterDeleted(router.id));
    }
  }
}
