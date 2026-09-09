import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Écran de chargement générique (splash) — logo, titre, sous-titre et barre
/// de progression indéterminée. Utilisé pendant les chargements bloquants
/// (ex. `LaunchScreen` au démarrage), personnalisable pour d'autres contextes.
class SplashView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SplashView({
    super.key,
    this.title = 'Aminci',
    this.subtitle = 'Gestion de vouchers MikroTik',
    this.icon = Icons.wifi_tethering_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.x16,
              height: AppSpacing.x16,
              decoration: BoxDecoration(color: AppColors.logoBg, borderRadius: AppSpacing.borderLg),
              child: Icon(icon, color: AppColors.textOnPrimary, size: AppSpacing.iconXl),
            ),
            SizedBox(height: AppSpacing.gapLg),
            Text(title, style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
            SizedBox(height: AppSpacing.gapSm),
            Text(subtitle, style: AppTypography.logoSub.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: AppSpacing.gapXl),
            SizedBox(
              width: AppSpacing.x12,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.bgSubtle,
                color: AppColors.primary,
                minHeight: AppSpacing.borderDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
