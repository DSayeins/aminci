import 'package:flutter/material.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

class RouterCard extends StatelessWidget {
  final MikroTikRouter router;
  final bool isTesting;
  final RouterConnectionResult? connectionResult;
  final VoidCallback onTest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RouterCard({
    super.key,
    required this.router,
    required this.isTesting,
    required this.connectionResult,
    required this.onTest,
    required this.onEdit,
    required this.onDelete,
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
      child: Row(
        children: [
          // Icône routeur
          Container(
            width: AppSpacing.avatarMd,
            height: AppSpacing.avatarMd,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppSpacing.borderMd,
            ),
            child: const Icon(Icons.router_rounded, size: AppSpacing.iconLg, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.gapLg),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(router.name, style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary)),
                SizedBox(height: AppSpacing.gapXs),
                Row(
                  children: [
                    Text(
                      '${router.ip}:${router.port}',
                      style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: AppSpacing.gapMd),
                    Text(
                      router.username,
                      style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                if (connectionResult != null) ...[
                  SizedBox(height: AppSpacing.gapSm),
                  _ConnectionBadge(success: connectionResult!.success, message: connectionResult!.message),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Test connexion
              isTesting
                  ? SizedBox(
                      width: AppSpacing.iconXl,
                      height: AppSpacing.iconXl,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSpacing.borderDefault,
                        color: AppColors.primary,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.wifi_tethering_rounded, size: AppSpacing.iconLg),
                      color: AppColors.textTertiary,
                      tooltip: 'Tester la connexion',
                      onPressed: onTest,
                    ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: AppSpacing.iconMd),
                color: AppColors.textTertiary,
                tooltip: 'Modifier',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: AppSpacing.iconMd),
                color: AppColors.textTertiary,
                tooltip: 'Supprimer',
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool success;
  final String message;

  const _ConnectionBadge({required this.success, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(
        color: success ? AppColors.statusActiveBg : AppColors.errorBg,
        borderRadius: AppSpacing.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_rounded,
            size: AppSpacing.iconSm,
            color: success ? AppColors.statusActive : AppColors.error,
          ),
          SizedBox(width: AppSpacing.gapXs),
          Text(
            message,
            style: AppTypography.badge.copyWith(
              color: success ? AppColors.statusActive : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
