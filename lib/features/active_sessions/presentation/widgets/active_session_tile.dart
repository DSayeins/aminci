import 'package:flutter/material.dart';

import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Ligne d'affichage d'une [session] active — code, IP/MAC, durée,
/// consommation, avec bouton de déconnexion.
class ActiveSessionTile extends StatelessWidget {
  final ActiveSession session;
  final VoidCallback onDisconnect;
  final bool isBusy;

  const ActiveSessionTile({
    super.key,
    required this.session,
    required this.onDisconnect,
    this.isBusy = false,
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
          Container(
            width: AppSpacing.x10,
            height: AppSpacing.x10,
            decoration: BoxDecoration(color: AppColors.statusActiveBg, borderRadius: AppSpacing.borderMd),
            child: const Icon(Icons.sensors_rounded, color: AppColors.statusActive, size: AppSpacing.iconLg),
          ),
          const SizedBox(width: AppSpacing.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.code,
                  style: AppTypography.techData.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.gapXs),
                Text(
                  [
                    if (session.address != null) session.address,
                    if (session.macAddress != null) session.macAddress,
                  ].join('  •  '),
                  style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.gapMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(session.uptime ?? '—', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.gapXs),
              Text(
                session.bytesTotalFmt,
                style: AppTypography.bodySm.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.gapMd),
          IconButton(
            icon: const Icon(Icons.link_off_rounded),
            tooltip: 'Déconnecter',
            onPressed: isBusy ? null : onDisconnect,
          ),
        ],
      ),
    );
  }
}
