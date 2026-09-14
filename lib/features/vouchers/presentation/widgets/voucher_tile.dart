import 'package:flutter/material.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Ligne d'affichage d'un [voucher] — code, statut, consommation.
/// Sélectionnable via [selected]/[onTap] (mode multi-sélection).
class VoucherTile extends StatelessWidget {
  final Voucher voucher;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const VoucherTile({
    super.key,
    required this.voucher,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  ({Color fg, Color bg, String label}) get _statusStyle {
    switch (voucher.status) {
      case VoucherStatus.active:
        return (fg: AppColors.statusActive, bg: AppColors.statusActiveBg, label: 'Actif');
      case VoucherStatus.pending:
        return (fg: AppColors.statusPending, bg: AppColors.statusPendingBg, label: 'En attente');
      case VoucherStatus.expired:
        return (fg: AppColors.statusExpired, bg: AppColors.statusExpiredBg, label: 'Expiré');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: AppSpacing.borderLg,
      child: Container(
        padding: AppSpacing.insetCard,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.bgSurface,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDefault,
            width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
          ),
        ),
        child: Row(
          children: [
            Checkbox(value: selected, onChanged: (_) => onTap()),
            const SizedBox(width: AppSpacing.gapSm),
            Container(
              width: AppSpacing.x10,
              height: AppSpacing.x10,
              decoration: BoxDecoration(color: AppColors.bgSubtle, borderRadius: AppSpacing.borderMd),
              child: const Icon(Icons.confirmation_number_outlined, color: AppColors.textTertiary, size: AppSpacing.iconLg),
            ),
            const SizedBox(width: AppSpacing.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        voucher.code,
                        style: AppTypography.techData.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: AppSpacing.gapSm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                        decoration: BoxDecoration(color: status.bg, borderRadius: AppSpacing.borderFull),
                        child: Text(status.label, style: AppTypography.badge.copyWith(color: status.fg)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.gapXs),
                  Text(
                    [
                      if (voucher.limitUptime != null && voucher.limitUptime!.isNotEmpty) voucher.limitUptime,
                      '${voucher.bytesTotalFmt} / ${voucher.limitBytesFmt}',
                    ].join('  •  '),
                    style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
