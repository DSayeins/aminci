import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

class AppSidebar extends StatelessWidget {
  final List<Routes> availablePages;
  final Routes? currentRoute;

  const AppSidebar({super.key, required this.availablePages, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: AppSpacing.sidebarWidth,
      color: isDark ? AppColorsDark.sidebarBg : AppColors.sidebarBg,
      child: Column(
        children: [
          _SidebarLogo(),
          const Divider(height: 1),
          Expanded(
            child: _SidebarNav(pages: availablePages, current: currentRoute),
          ),
          const Divider(height: 1),
          _RouterSwitcher(),
          const Divider(height: 1),
          _LogoutButton(),
          const Divider(height: 1),
          _SidebarFooter(),
        ],
      ),
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
  final Routes? current;

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
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: AppSpacing.borderSm,
        child: InkWell(
          onTap: () => context.go(page.path),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: AppColors.bgSubtle,
          borderRadius: AppSpacing.borderSm,
          child: SizedBox(
            height: AppSpacing.navItemHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH),
              child: Row(
                children: [
                  Icon(page.icon, size: AppSpacing.navIconSize, color: isActive ? activeColor : inactiveIcon),
                  const SizedBox(width: AppSpacing.gapSm),
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
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sélecteur de routeur
// -----------------------------------------------------------------------------

class _RouterSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;

    return BlocBuilder<RoutersBloc, RoutersState>(
      buildWhen: (prev, curr) {
        final prevName = prev is RoutersLoaded ? prev.selectedRouter?.name : null;
        final currName = curr is RoutersLoaded ? curr.selectedRouter?.name : null;
        return prevName != currName;
      },
      builder: (context, state) {
        final selected = state is RoutersLoaded ? state.selectedRouter : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapSm),
          child: Material(
            color: isDark ? AppColorsDark.bgSubtle : AppColors.bgSubtle,
            borderRadius: AppSpacing.borderSm,
            child: InkWell(
              onTap: () => context.go('/routers'),
              mouseCursor: SystemMouseCursors.click,
              hoverColor: AppColors.primaryLight,
              borderRadius: AppSpacing.borderSm,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH, vertical: AppSpacing.gapSm),
                child: Row(
                  children: [
                    Icon(Icons.router_rounded, size: AppSpacing.navIconSize, color: textTertiary),
                    const SizedBox(width: AppSpacing.gapSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected?.name ?? 'Aucun routeur',
                            style: AppTypography.navItem.copyWith(color: textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            selected != null ? '${selected.ip}:${selected.port}' : 'Choisir un routeur',
                            style: AppTypography.techData.copyWith(color: textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.swap_horiz_rounded, size: AppSpacing.iconSm, color: textTertiary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Bouton déconnexion
// -----------------------------------------------------------------------------

class _LogoutButton extends StatelessWidget {
  Future<void> _confirm(BuildContext context) async {
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
      context.read<AppBloc>().add(const AppLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapXs),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppSpacing.borderSm,
        child: InkWell(
          onTap: () => _confirm(context),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: AppColors.bgSubtle,
          borderRadius: AppSpacing.borderSm,
          child: SizedBox(
            height: AppSpacing.navItemHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: AppSpacing.navIconSize,
                    color: isDark ? AppColorsDark.textTertiary : AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.gapSm),
                  Text(
                    'Se déconnecter',
                    style: AppTypography.navItem.copyWith(
                      color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
                      Text(_roleLabel(user.role), style: AppTypography.userRole.copyWith(color: textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(UserRole role) => role == UserRole.admin ? 'Administrateur' : 'Opérateur';
}
