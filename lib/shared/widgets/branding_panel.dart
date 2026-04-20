import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Panel gauche de branding Aminci — réutilisé sur AuthScreen et SetupScreen.
class BrandingPanel extends StatelessWidget {
  const BrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond dégradé
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
          ),
        ),

        // Cercles décoratifs
        const Positioned(top: -60, right: -50, child: _Circle(220, 0.07)),
        const Positioned(bottom: -80, left: -50, child: _Circle(260, 0.05)),
        const Positioned(top: 160, left: -40, child: _Circle(120, 0.04)),

        // Contenu
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXl,
            vertical: AppSpacing.paddingLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              _Logo(),
              const SizedBox(height: AppSpacing.gapXl),

              // Nom de l'app
              Text(
                'Aminci',
                style: AppTypography.statValue.copyWith(
                  color: AppColors.textOnPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.gapSm),
              Text(
                'Gestion de vouchers\nhotspot MikroTik',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: AppSpacing.gapXl),
              _Separator(),
              const SizedBox(height: AppSpacing.gapXl),

              // Features
              const _Feature(icon: Icons.bolt_rounded, label: 'Génération rapide de tickets'),
              const SizedBox(height: AppSpacing.gapMd),
              const _Feature(icon: Icons.router_rounded, label: 'Multi-routeurs MikroTik'),
              const SizedBox(height: AppSpacing.gapMd),
              const _Feature(icon: Icons.print_rounded, label: 'Impression PDF intégrée'),
            ],
          ),
        ),

        // Badge version en bas à droite
        const Positioned(
          bottom: AppSpacing.gapLg,
          right: AppSpacing.gapLg,
          child: _VersionBadge(),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Logo
// -----------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.x16 + AppSpacing.x3,
      height: AppSpacing.x16 + AppSpacing.x3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anneau extérieur
          Container(
            width: AppSpacing.x16 + AppSpacing.x3,
            height: AppSpacing.x16 + AppSpacing.x3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                width: AppSpacing.borderThick,
              ),
            ),
          ),
          // Fond blanc intérieur
          Container(
            width: AppSpacing.x16,
            height: AppSpacing.x16,
            decoration: const BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_tethering_rounded,
              color: AppColors.primary,
              size: AppSpacing.iconXl,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Séparateur
// -----------------------------------------------------------------------------

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.x8,
      height: AppSpacing.borderThick,
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderFull,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Feature item
// -----------------------------------------------------------------------------

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.textOnPrimary.withValues(alpha: 0.85),
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.gapSm),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Badge version
// -----------------------------------------------------------------------------

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderFull,
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          width: AppSpacing.borderThin,
        ),
      ),
      child: Text(
        'v1.0',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.textOnPrimary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Cercle décoratif
// -----------------------------------------------------------------------------

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle(this.size, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textOnPrimary.withValues(alpha: opacity),
      ),
    );
  }
}
