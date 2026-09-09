import 'package:flutter/material.dart';
import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class AppTopBar extends StatelessWidget {
  final Routes? currentRoute;

  const AppTopBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topbarHeight,
      color: AppColors.bgSurface,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingLg),
              child: Row(
                children: [
                  if (currentRoute != null) ...[
                    Icon(currentRoute!.icon, size: AppSpacing.iconLg, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.gapSm),
                    Text(currentRoute!.label, style: AppTypography.topbarTitle.copyWith(color: AppColors.textPrimary)),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
      ),
    );
  }
}
