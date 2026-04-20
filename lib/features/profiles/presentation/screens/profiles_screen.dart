import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/profiles/presentation/widgets/profile_card.dart';
import 'package:aminci/features/profiles/presentation/widgets/profile_form_dialog.dart';
import 'package:aminci/features/profiles/presentation/widgets/profile_generate_voucher_dialog.dart';
import 'package:aminci/features/profiles/presentation/widgets/profile_users_dialog.dart';
import 'package:aminci/shared/widgets/app_snackbar.dart';
import 'package:aminci/shared/widgets/empty_state.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfilesView();
  }
}

class _ProfilesView extends StatefulWidget {
  const _ProfilesView();

  @override
  State<_ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<_ProfilesView> {
  int? _selectedRouterId;

  @override
  void initState() {
    super.initState();
    context.read<ProfilesBloc>().add(const ProfilesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfilesBloc, ProfilesState>(
      listener: (context, state) {
        if (state is ProfilesOperationSuccess) {
          AppSnackbar.success(context, state.message);
        }
        if (state is ProfilesError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final profiles = switch (state) {
          ProfilesListLoaded(:final profiles) => profiles,
          ProfilesOperationSuccess(:final profiles) => profiles,
          ProfilesSyncing(:final profiles) => profiles,
          ProfilesError(:final profiles) => profiles,
          _ => <HotspotProfile>[],
        };

        final isSyncing = state is ProfilesSyncing;
        final isLoading = state is ProfilesLoading;

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
                        Text('Profils', style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary)),
                        SizedBox(height: AppSpacing.gapXs),
                        Text(
                          'Profils hotspot synchronisés depuis MikroTik',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedRouterId != null) ...[
                    SizedBox(
                      height: AppSpacing.buttonHeightMd,
                      child: OutlinedButton.icon(
                        onPressed: () => _showProfileForm(context),
                        icon: const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                        label: const Text('Ajouter'),
                      ),
                    ),
                    SizedBox(width: AppSpacing.gapSm),
                    SizedBox(
                      height: AppSpacing.buttonHeightMd,
                      child: ElevatedButton.icon(
                        onPressed: isSyncing
                            ? null
                            : () => context.read<ProfilesBloc>().add(ProfilesSynced(_selectedRouterId!)),
                        icon: isSyncing
                            ? SizedBox(
                                width: AppSpacing.iconMd,
                                height: AppSpacing.iconMd,
                                child: CircularProgressIndicator(
                                  strokeWidth: AppSpacing.borderDefault,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Icon(Icons.sync_rounded, size: AppSpacing.iconMd),
                        label: Text(isSyncing ? 'Synchronisation...' : 'Synchroniser'),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSpacing.gapXl),

              // Sélecteur de routeur
              if (state.routers.isEmpty)
                const EmptyState(
                  icon: Icons.router_outlined,
                  title: 'Aucun routeur configuré',
                  subtitle: 'Configurez un routeur dans l\'onglet Routeurs pour accéder aux profils.',
                )
              else
                _RouterSelector(
                  routers: state.routers,
                  selectedId: _selectedRouterId,
                  onSelected: (id) {
                    setState(() => _selectedRouterId = id);
                    context.read<ProfilesBloc>().add(ProfilesLoaded(id));
                  },
                ),
              SizedBox(height: AppSpacing.gapXl),

              // Liste des profils
              Expanded(
                child: _selectedRouterId == null
                    ? const EmptyState(
                        icon: Icons.touch_app_outlined,
                        title: 'Choisissez un routeur',
                        subtitle: 'Sélectionnez un routeur ci-dessus pour afficher ses profils.',
                      )
                    : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : profiles.isEmpty
                    ? EmptyState(
                        icon: Icons.tune_rounded,
                        title: 'Aucun profil en cache',
                        subtitle: 'Synchronisez les profils depuis le routeur MikroTik.',
                        buttonLabel: 'Synchroniser',
                        buttonIcon: Icons.sync_rounded,
                        onAction: () => context.read<ProfilesBloc>().add(ProfilesSynced(_selectedRouterId!)),
                      )
                    : ListView.separated(
                        itemCount: profiles.length,
                        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.gapMd),
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return ProfileCard(
                            profile: profile,
                            onEdit: () => _showProfileForm(context, profile: profile),
                            onDelete: () => _confirmDelete(context, profile),
                            onViewUsers: () => _showUsersDialog(context, profile),
                            onGenerateVouchers: () => _showGenerateVoucherDialog(context, profile),
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

  void _showProfileForm(BuildContext context, {HotspotProfile? profile}) {
    showDialog<void>(
      context: context,
      builder: (_) => ProfileFormDialog(routerId: _selectedRouterId!, profile: profile),
    );
  }

  void _confirmDelete(BuildContext context, HotspotProfile profile) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer le profil', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Supprimer "${profile.mikrotikName}" sur MikroTik et du cache local ?',
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProfilesBloc>().add(ProfileDeleted(profileId: profile.id, routerId: _selectedRouterId!));
            },
            child: Text('Supprimer', style: AppTypography.labelMd.copyWith(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  void _showGenerateVoucherDialog(BuildContext context, HotspotProfile profile) {
    showDialog<void>(
      context: context,
      builder: (_) => ProfileGenerateVoucherDialog(profile: profile),
    );
  }

  void _showUsersDialog(BuildContext context, HotspotProfile profile) {
    showDialog<void>(
      context: context,
      builder: (_) => ProfileUsersDialog(profile: profile),
    );
  }
}

// -----------------------------------------------------------------------------
// Sélecteur de routeur
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
