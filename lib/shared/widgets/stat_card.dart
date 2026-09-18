import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Carte de statistique réutilisable — icône, valeur, libellé, sous-texte
/// optionnel (ex: dashboard).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? subtitle;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.subtitle,
    this.accentColor = AppColors.primary,
  });

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
          Container(
            width: AppSpacing.x10,
            height: AppSpacing.x10,
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), borderRadius: AppSpacing.borderMd),
            child: Icon(icon, color: accentColor, size: AppSpacing.iconLg),
          ),
          const SizedBox(height: AppSpacing.gapLg),
          Text(value, style: AppTypography.statValue.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.gapXs),
          Text(label, style: AppTypography.statLabel.copyWith(color: AppColors.textSecondary)),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.gapXs),
            Text(subtitle!, style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
          ],
        ],
      ),
    );
  }
}
