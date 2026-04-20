import 'package:flutter/material.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class ProfileCard extends StatelessWidget {
  final HotspotProfile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewUsers;
  final VoidCallback onGenerateVouchers;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onDelete,
    required this.onViewUsers,
    required this.onGenerateVouchers,
  });

  @override
  Widget build(BuildContext context) {
    final expired = profile.isExpired;
    final iconBg = expired ? AppColors.bgCode : AppColors.primaryLight;
    final iconColor = expired ? AppColors.textTertiary : AppColors.primary;
    final cardBg = expired ? AppColors.bgCode : AppColors.bgSurface;

    return Opacity(
      opacity: expired ? 0.65 : 1.0,
      child: Container(
        padding: AppSpacing.insetCard,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(color: AppColors.borderDefault, width: AppSpacing.borderThin),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppSpacing.borderMd,
              ),
              child: Icon(Icons.tune_rounded, size: AppSpacing.iconLg, color: iconColor),
            ),
            SizedBox(width: AppSpacing.gapLg),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(profile.mikrotikName,
                          style: AppTypography.sectionTitle.copyWith(
                            color: expired ? AppColors.textTertiary : AppColors.textPrimary,
                          )),
                      if (expired) ...[
                        SizedBox(width: AppSpacing.gapSm),
                        _ExpiredBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.gapXs),
                  Wrap(
                    spacing: AppSpacing.gapMd,
                    runSpacing: AppSpacing.gapXs,
                    children: [
                      if (profile.addressPool != null)
                        _InfoChip(icon: Icons.dns_rounded, label: profile.addressPool!),
                      if (profile.rateLimit != null)
                        _InfoChip(icon: Icons.speed_rounded, label: profile.rateLimit!),
                      if (profile.sessionTimeout != null)
                        _InfoChip(icon: Icons.timer_outlined, label: 'session: ${profile.sessionTimeout!}'),
                      if (profile.idleTimeout != null)
                        _InfoChip(icon: Icons.hourglass_empty_rounded, label: 'idle: ${profile.idleTimeout!}'),
                      if (profile.keepaliveTimeout != null)
                        _InfoChip(icon: Icons.favorite_border_rounded, label: 'keepalive: ${profile.keepaliveTimeout!}'),
                      _InfoChip(
                        icon: Icons.people_rounded,
                        label: '${profile.sharedUsers} conn.',
                      ),
                      if (profile.expiresAt != null && !expired)
                        _InfoChip(
                          icon: Icons.event_outlined,
                          label: 'expire le ${profile.expiresAt!.day.toString().padLeft(2, '0')}/${profile.expiresAt!.month.toString().padLeft(2, '0')}/${profile.expiresAt!.year}',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton générer vouchers (désactivé si expiré)
            IconButton(
              onPressed: expired ? null : onGenerateVouchers,
              icon: const Icon(Icons.confirmation_number_outlined, size: AppSpacing.iconMd),
              color: expired ? AppColors.textTertiary : AppColors.primary,
              tooltip: expired ? 'Profil expiré' : 'Générer des vouchers',
            ),

            // Bouton utilisateurs
            IconButton(
              onPressed: onViewUsers,
              icon: const Icon(Icons.people_rounded, size: AppSpacing.iconMd),
              color: AppColors.textTertiary,
              tooltip: 'Utilisateurs',
            ),

            // Bouton édition (désactivé si expiré)
            IconButton(
              onPressed: expired ? null : onEdit,
              icon: const Icon(Icons.edit_rounded, size: AppSpacing.iconMd),
              color: AppColors.textTertiary,
              tooltip: 'Modifier',
            ),

            // Bouton suppression (toujours actif)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: AppSpacing.iconMd),
              color: AppColors.error,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusExpiredBg,
        borderRadius: AppSpacing.borderFull,
      ),
      child: Text(
        'Expiré',
        style: AppTypography.badge.copyWith(color: AppColors.statusExpired),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.textTertiary),
        SizedBox(width: AppSpacing.gapXs),
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
