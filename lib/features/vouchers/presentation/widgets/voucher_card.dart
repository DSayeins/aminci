import 'package:flutter/material.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final bool isNew;
  final VoidCallback onDelete;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onDelete,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetCard,
      decoration: BoxDecoration(
        color: isNew ? AppColors.primaryLight : AppColors.bgSurface,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(
          color: isNew ? AppColors.primary : AppColors.borderDefault,
          width: isNew ? AppSpacing.borderDefault : AppSpacing.borderThin,
        ),
      ),
      child: Row(
        children: [
          // Code voucher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x2),
            decoration: BoxDecoration(
              color: AppColors.bgCode,
              borderRadius: AppSpacing.borderMd,
            ),
            child: Text(voucher.code, style: AppTypography.voucherCode),
          ),
          SizedBox(width: AppSpacing.gapLg),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProfileBadge(name: voucher.profileName),
                    SizedBox(width: AppSpacing.gapSm),
                    _StatusBadge(status: voucher.status),
                    SizedBox(width: AppSpacing.gapSm),
                    Text(
                      '${voucher.price.toStringAsFixed(0)} FCFA',
                      style: AppTypography.labelMd.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.gapXs),
                Text(
                  '${_formatDate(voucher.createdAt)}  ·  ${voucher.createdBy}',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // Supprimer
          IconButton(
            icon: const Icon(Icons.delete_rounded, size: AppSpacing.iconMd),
            color: AppColors.textTertiary,
            tooltip: 'Supprimer',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}

// -----------------------------------------------------------------------------

class _ProfileBadge extends StatelessWidget {
  final String name;
  const _ProfileBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: AppSpacing.borderFull,
        border: Border.all(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      child: Text(name, style: AppTypography.badge.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VoucherStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      VoucherStatus.active => (AppColors.statusActiveBg, AppColors.statusActive, 'Actif'),
      VoucherStatus.pending => (AppColors.statusPendingBg, AppColors.statusPending, 'En attente'),
      VoucherStatus.expired => (AppColors.statusExpiredBg, AppColors.statusExpired, 'Expiré'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(color: bg, borderRadius: AppSpacing.borderFull),
      child: Text(label, style: AppTypography.badge.copyWith(color: fg)),
    );
  }
}
