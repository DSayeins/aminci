import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class SidebarNavItem extends StatelessWidget {
  final Routes page;
  final bool isActive;

  const SidebarNavItem({super.key, required this.page, required this.isActive});

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
