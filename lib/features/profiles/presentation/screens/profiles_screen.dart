import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/core/utils/currency_formatter.dart';
import 'package:aminci/features/profiles/presentation/bloc/profiles_bloc.dart';
import 'package:aminci/features/profiles/presentation/widgets/add_profile_dialog.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/features/vouchers/domain/usecases/delete_vouchers_for_profile.dart';
import 'package:aminci/features/vouchers/presentation/screens/profile_vouchers_screen.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  MikroTikRouter? _router;

  @override
  void initState() {
    super.initState();
    final state = context.read<RoutersBloc>().state;
    _router = state is RoutersLoaded ? state.selectedRouter : null;
    _load();
  }

  void _load() {
    final router = _router;
    if (router != null) context.read<ProfilesBloc>().add(ProfilesLoadRequested(router));
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      // AppShell garantit normalement un routeur sélectionné avant d'atteindre
      // cette page — filet de sécurité si jamais ce n'est pas le cas.
      return const EmptyState(
        icon: Icons.router_rounded,
        title: 'Aucun routeur sélectionné',
        subtitle: 'Choisissez un routeur pour voir ses profils.',
      );
    }

    return Column(
      children: [
        _Header(router: router),
        Expanded(
          child: BlocBuilder<ProfilesBloc, ProfilesState>(
            builder: (context, state) {
              if (state is ProfilesLoading || state is ProfilesInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProfilesError) {
                return ErrorView(message: state.message, onRetry: _load);
              }

              final loaded = state as ProfilesLoaded;

              if (loaded.profiles.isEmpty) {
                return EmptyState(
                  icon: Icons.tune_rounded,
                  title: 'Aucun profil configuré',
                  subtitle: 'Ajoutez un premier profil,\nou configurez-en un via WinBox.',
                  buttonLabel: 'Ajouter un profil',
                  buttonIcon: Icons.add_rounded,
                  onAction: () => showAddProfileDialog(context, router),
                );
              }

              return GridView.builder(
                padding: AppSpacing.insetPage,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: AppSpacing.gapMd,
                  crossAxisSpacing: AppSpacing.gapMd,
                  childAspectRatio: 0.9,
                ),
                itemCount: loaded.profiles.length,
                itemBuilder: (context, index) => _ProfileCard(router: router, profile: loaded.profiles[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// En-tête — bouton d'ajout
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final MikroTikRouter router;

  const _Header({required this.router});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.paddingLg,
        AppSpacing.paddingMd,
        AppSpacing.paddingLg,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlocBuilder<ProfilesBloc, ProfilesState>(
            builder: (context, state) {
              final isBusy = state is ProfilesLoaded && state.isBusy;
              return OutlinedButton.icon(
                onPressed: isBusy ? null : () => showAddProfileDialog(context, router),
                icon: const Icon(Icons.add_rounded, size: AppSpacing.iconMd),
                label: const Text('Ajouter un profil'),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Carte profil
// -----------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const _ProfileCard({required this.router, required this.profile});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le profil'),
        content: Text('Supprimer « ${profile.mikrotikName} » ? Cette action est irréversible.'),
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
      context.read<ProfilesBloc>().add(ProfileDeleteRequested(router, profile));
      // Suppression en cascade des vouchers du profil — best-effort, en
      // tâche de fond : ne bloque pas la suppression du profil et n'affiche
      // pas d'erreur séparée si le routeur est momentanément injoignable.
      unawaited(sl<DeleteVouchersForProfile>()(router, profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetCard,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.x10,
                height: AppSpacing.x10,
                decoration: BoxDecoration(color: AppColors.bgSubtle, borderRadius: AppSpacing.borderMd),
                child: const Icon(Icons.tune_rounded, color: AppColors.textTertiary, size: AppSpacing.iconLg),
              ),
              const Spacer(),
              if (profile.isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(color: AppColors.statusExpiredBg, borderRadius: AppSpacing.borderFull),
                  child: Text('Expiré', style: AppTypography.badge.copyWith(color: AppColors.statusExpired)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapLg),
          Text(
            profile.mikrotikName,
            style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.gapXs),
          Text(
            [
              if (profile.rateLimit != null) profile.rateLimit,
              if (profile.sessionTimeout != null) profile.sessionTimeout,
            ].join('  •  '),
            style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.gapXs),
          Text(
            '${profile.sharedUsers} utilisateur${profile.sharedUsers > 1 ? 's' : ''} simultané${profile.sharedUsers > 1 ? 's' : ''}',
            style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  CurrencyFormatter.format(profile.price),
                  style: AppTypography.statValue.copyWith(color: AppColors.primary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showEditProfileDialog(context, router, profile),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Supprimer',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showProfileVouchersScreen(context, router, profile),
              icon: const Icon(Icons.confirmation_number_outlined, size: AppSpacing.iconSm),
              label: const Text('Vouchers'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
