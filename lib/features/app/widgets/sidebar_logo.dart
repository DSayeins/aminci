import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class SidebarLogo extends StatelessWidget {
  const SidebarLogo({super.key});

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
            const SizedBox(width: AppSpacing.gapSm),
            Text('Aminci', style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
