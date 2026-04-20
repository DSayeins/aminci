import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Vue d'erreur générique avec bouton "Réessayer".
/// Utilisable dans n'importe quel écran qui expose un état d'erreur.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: Container(
          width: 360,
          padding: AppSpacing.insetCard,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: AppSpacing.borderLg,
            border: Border.all(
              color: AppColors.borderDefault,
              width: AppSpacing.borderThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Une erreur est survenue',
                style: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: AppSpacing.gapSm),
              Text(
                message,
                style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.gapLg),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Réessayer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
