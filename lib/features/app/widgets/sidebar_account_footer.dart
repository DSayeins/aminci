import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/enum/user_role.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/widgets/dashed_border_box.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/features/logout/presentation/bloc/logout_bloc.dart';

/// Utilisateur connecté + déconnexion (avec confirmation).
class SidebarAccountFooter extends StatelessWidget {
  const SidebarAccountFooter({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Se déconnecter ?', style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Vous serez redirigé vers l\'écran de connexion.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Se déconnecter', style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<LogoutBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) context.go('/login');
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is! LoginAuthenticated) return const SizedBox.shrink();
          final user = state.user;
          final displayName = user.name.isNotEmpty ? user.name : user.username;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapSm),
            child: DashedBorderBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapSm),
                child: Row(
                  children: [
                    Container(
                      width: AppSpacing.avatarSm,
                      height: AppSpacing.avatarSm,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: AppSpacing.borderFull),
                      child: Center(
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gapSm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: AppTypography.userName.copyWith(color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _roleLabel(user.role),
                            style: AppTypography.userRole.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      iconSize: AppSpacing.iconMd,
                      color: AppColors.textTertiary,
                      tooltip: 'Se déconnecter',
                      onPressed: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(UserRole role) => role == UserRole.admin ? 'Administrateur' : 'Opérateur';
}
