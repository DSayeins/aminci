import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/navigation/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';

/// Barre de navigation latérale — logo, items filtrés par rôle, footer utilisateur.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppNavigating) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          width: AppSpacing.sidebarWidth,
          color: isDark ? AppColorsDark.sidebarBg : AppColors.sidebarBg,
          child: Column(
            children: [
              _SidebarLogo(),
              const Divider(height: 1),
              Expanded(
                child: _SidebarNav(pages: state.availablePages, current: state.currentPage),
              ),
              const Divider(height: 1),
              _SidebarFooter(),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Logo
// -----------------------------------------------------------------------------

class _SidebarLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;

    return SizedBox(
      height: AppSpacing.sidebarLogoHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH),
        child: Row(
          children: [
            Container(
              width: AppSpacing.logoIconSize,
              height: AppSpacing.logoIconSize,
              decoration: BoxDecoration(color: AppColors.logoBg, borderRadius: AppSpacing.borderSm),
              child: const Icon(Icons.wifi_tethering_rounded, color: AppColors.textOnPrimary, size: AppSpacing.iconSm),
            ),
            SizedBox(width: AppSpacing.gapSm),
            Text('Aminci', style: AppTypography.logoText.copyWith(color: textPrimary)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Navigation
// -----------------------------------------------------------------------------

class _SidebarNav extends StatelessWidget {
  final List<Routes> pages;
  final Routes current;

  const _SidebarNav({required this.pages, required this.current});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapSm),
      children: pages.map((page) => _NavItem(page: page, isActive: page == current)).toList(),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Routes page;
  final bool isActive;

  const _NavItem({required this.page, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final activeBg = isDark ? AppColorsDark.sidebarActive : AppColors.sidebarActive;
    final inactiveText = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final inactiveIcon = isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapXs),
      child: InkWell(
        onTap: () => context.read<AppBloc>().add(NavigateTo(page)),
        borderRadius: AppSpacing.borderSm,
        child: Container(
          height: AppSpacing.navItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH),
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: AppSpacing.borderSm,
          ),
          child: Row(
            children: [
              Icon(
                page.icon,
                size: AppSpacing.navIconSize,
                color: isActive ? activeColor : inactiveIcon,
              ),
              SizedBox(width: AppSpacing.gapSm),
              Text(
                page.label,
                style: (isActive ? AppTypography.navItemActive : AppTypography.navItem).copyWith(
                  color: isActive ? activeColor : inactiveText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Footer utilisateur
// -----------------------------------------------------------------------------

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppNavigating) return const SizedBox.shrink();
        final user = state.user;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
        final primaryLight = isDark ? AppColorsDark.primaryLight : AppColors.primaryLight;
        final textPrimary = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
        final textTertiary = isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;

        return SizedBox(
          height: AppSpacing.sidebarFooterHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: AppSpacing.avatarSm,
                  height: AppSpacing.avatarSm,
                  decoration: BoxDecoration(color: primaryLight, borderRadius: AppSpacing.borderFull),
                  child: Center(
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: AppTypography.labelMd.copyWith(color: primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.gapSm),
                // Nom + rôle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: AppTypography.userName.copyWith(color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _roleLabel(user.role),
                        style: AppTypography.userRole.copyWith(color: textTertiary),
                      ),
                    ],
                  ),
                ),
                // Déconnexion
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: AppSpacing.iconMd),
                  color: textTertiary,
                  tooltip: 'Se déconnecter',
                  onPressed: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            child: Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AppBloc>().add(const AppLogoutRequested());
    }
  }

  String _roleLabel(UserRole role) => role == UserRole.admin ? 'Administrateur' : 'Opérateur';
}
