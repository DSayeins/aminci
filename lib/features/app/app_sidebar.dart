import 'package:flutter/material.dart';

import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/app/widgets/sidebar_account_footer.dart';
import 'package:aminci/features/app/widgets/sidebar_logo.dart';
import 'package:aminci/features/app/widgets/sidebar_nav.dart';

/// Hiérarchie : Identité (logo) → Navigation → Compte (utilisateur +
/// déconnexion). Le contexte routeur/hotspot est porté par le fil d'Ariane de
/// la topbar.
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
          const SidebarLogo(),
          const Divider(height: 1),
          Expanded(
            child: SidebarNav(pages: availablePages, current: currentRoute),
          ),
          const Divider(height: 1),
          const SidebarAccountFooter(),
        ],
      ),
    );
  }
}
