import 'package:flutter/material.dart';

import 'package:aminci/core/models/dashboard_metrics.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Répartition des vouchers par statut (en attente / actifs / expirés),
/// sous forme de trois indicateurs colorés.
class VoucherStatusBreakdown extends StatelessWidget {
  final DashboardMetrics metrics;

  const VoucherStatusBreakdown({super.key, required this.metrics});

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
          Text('Vouchers par statut', style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.gapLg),
          Row(
            children: [
              _StatusItem(
                label: 'En attente',
                count: metrics.vouchersPending,
                color: AppColors.statusPending,
                bgColor: AppColors.statusPendingBg,
              ),
              const SizedBox(width: AppSpacing.gapMd),
              _StatusItem(
                label: 'Actifs',
                count: metrics.vouchersActive,
                color: AppColors.statusActive,
                bgColor: AppColors.statusActiveBg,
              ),
              const SizedBox(width: AppSpacing.gapMd),
              _StatusItem(
                label: 'Expirés',
                count: metrics.vouchersExpired,
                color: AppColors.statusExpired,
                bgColor: AppColors.statusExpiredBg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  const _StatusItem({required this.label, required this.count, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMd, horizontal: AppSpacing.paddingSm),
        decoration: BoxDecoration(color: bgColor, borderRadius: AppSpacing.borderMd),
        child: Column(
          children: [
            Text('$count', style: AppTypography.statValue.copyWith(color: color)),
            const SizedBox(height: AppSpacing.gapXs),
            Text(label, style: AppTypography.statLabel.copyWith(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
