import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.buttonIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.x16, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.gapLg),
          Text(title, style: AppTypography.pageTitle.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: AppSpacing.gapSm),
          Text(
            subtitle,
            style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && buttonLabel != null) ...[
            SizedBox(height: AppSpacing.gapXl),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(buttonIcon ?? Icons.arrow_forward_rounded, size: AppSpacing.iconMd),
              label: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
