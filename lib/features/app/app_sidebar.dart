import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aminci/core/enum/user_role.dart';
import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/features/logout/presentation/bloc/logout_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

class AppSidebar extends StatelessWidget {
  final List<Routes> availablePages;
  final Routes? currentRoute;

  const AppSidebar({super.key, required this.availablePages, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.sidebarBg,
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
            Text('Aminci', style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
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
    final activeColor = AppColors.primary;
    final activeBg = AppColors.sidebarActive;
    final inactiveText = AppColors.textSecondary;
    final inactiveIcon = AppColors.textTertiary;

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
    final textSecondary = AppColors.textSecondary;
    final textTertiary = AppColors.textTertiary;

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
            color: AppColors.bgSubtle,
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
      context.read<LogoutBloc>().add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) context.go('/login');
      },
      child: Padding(
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
                    Icon(Icons.logout_rounded, size: AppSpacing.navIconSize, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.gapSm),
                    Text('Se déconnecter', style: AppTypography.navItem.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
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
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is! LoginAuthenticated) return const SizedBox.shrink();
        final user = state.user;
        final displayName = user.name.isNotEmpty ? user.name : user.username;
        final primaryColor = AppColors.primary;
        final primaryLight = AppColors.primaryLight;
        final textPrimary = AppColors.textPrimary;
        final textTertiary = AppColors.textTertiary;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm, vertical: AppSpacing.gapSm),
          child: _DashedBorderBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gapSm,
                vertical: AppSpacing.gapSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSpacing.avatarSm,
                    height: AppSpacing.avatarSm,
                    decoration: BoxDecoration(color: primaryLight, borderRadius: AppSpacing.borderFull),
                    child: Center(
                      child: Text(
                        displayName[0].toUpperCase(),
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
                          displayName,
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
          ),
        );
      },
    );
  }

  String _roleLabel(UserRole role) => role == UserRole.admin ? 'Administrateur' : 'Opérateur';
}

// -----------------------------------------------------------------------------
// Boîte à bordure pointillée arrondie
// -----------------------------------------------------------------------------

class _DashedBorderBox extends StatelessWidget {
  final Widget child;

  const _DashedBorderBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: AppColors.borderDefault, radius: AppSpacing.borderMd),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final BorderRadius radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = radius.toRRect(Offset.zero & size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.borderDefault;
    canvas.drawPath(_dashPath(Path()..addRRect(rrect)), paint);
  }

  /// Découpe le contour en tirets de 4px espacés de 3px.
  Path _dashPath(Path source, {double dashWidth = 4, double dashGap = 3}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + length), Offset.zero);
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
