import 'package:flutter/material.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class VoucherRow extends StatelessWidget {
  final Voucher voucher;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const VoucherRow({
    super.key,
    required this.voucher,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final (accentColor, statusBg, statusFg, statusLabel) = switch (voucher.status) {
      VoucherStatus.active => (AppColors.statusActive, AppColors.statusActiveBg, AppColors.statusActive, 'Actif'),
      VoucherStatus.pending => (
        AppColors.statusPending,
        AppColors.statusPendingBg,
        AppColors.statusPending,
        'En attente',
      ),
      VoucherStatus.expired => (AppColors.statusExpired, AppColors.statusExpiredBg, AppColors.statusExpired, 'Expiré'),
    };

    return GestureDetector(
      onTap: enabled ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.bgSurface,
          borderRadius: AppSpacing.borderMd,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDefault,
            width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
          ),
        ),
        child: ClipRRect(
          borderRadius: AppSpacing.borderMd,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Barre d'accent gauche ─────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: AppSpacing.borderThick + AppSpacing.borderDefault,
                  color: accentColor,
                ),

                // ── Contenu ───────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Ligne 1 : code + password + badges ───────────
                        Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: enabled ? (_) => onToggle() : null,
                              activeColor: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            SizedBox(width: AppSpacing.gapXs),

                            // Code
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
                              decoration: BoxDecoration(color: AppColors.bgCode, borderRadius: AppSpacing.borderSm),
                              child: Text(voucher.code, style: AppTypography.voucherCode),
                            ),
                            SizedBox(width: AppSpacing.gapSm),

                            // Séparateur
                            Text('·', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
                            SizedBox(width: AppSpacing.gapSm),

                            // Mot de passe
                            Text(
                              voucher.password,
                              style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
                            ),

                            const Spacer(),

                            // Prix
                            if (voucher.price > 0) ...[
                              _Tag(
                                label: '${voucher.price.toStringAsFixed(0)} FCFA',
                                icon: Icons.sell_outlined,
                                color: AppColors.primary,
                                bgColor: AppColors.primaryLight,
                              ),
                              SizedBox(width: AppSpacing.gapSm),
                            ],

                            // Désactivé
                            if (voucher.disabled) ...[
                              _Tag(
                                label: 'Désactivé',
                                color: AppColors.statusExpired,
                                bgColor: AppColors.statusExpiredBg,
                              ),
                              SizedBox(width: AppSpacing.gapSm),
                            ],

                            // Statut
                            _Tag(label: statusLabel, color: statusFg, bgColor: statusBg, dot: true),
                          ],
                        ),

                        // ── Ligne 2 : méta ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.x8, top: AppSpacing.x1),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: AppSpacing.iconXs,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: AppSpacing.gapXs),
                              Text(
                                voucher.createdBy,
                                style: AppTypography.statSub.copyWith(color: AppColors.textSecondary),
                              ),
                              _dot,

                              Icon(
                                Icons.calendar_today_outlined,
                                size: AppSpacing.iconXs,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: AppSpacing.gapXs),
                              Text(
                                _formatDate(voucher.createdAt),
                                style: AppTypography.statSub.copyWith(color: AppColors.textSecondary),
                              ),

                              if (voucher.server != null && voucher.server!.isNotEmpty) ...[
                                _dot,
                                Icon(Icons.router_outlined, size: AppSpacing.iconXs, color: AppColors.textTertiary),
                                SizedBox(width: AppSpacing.gapXs),
                                Text(
                                  voucher.server!,
                                  style: AppTypography.statSub.copyWith(color: AppColors.textSecondary),
                                ),
                              ],

                              if (voucher.comment != null && voucher.comment!.isNotEmpty) ...[
                                _dot,
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: AppSpacing.iconXs,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: AppSpacing.gapXs),
                                Expanded(
                                  child: Text(
                                    voucher.comment!,
                                    style: AppTypography.statSub.copyWith(color: AppColors.textTertiary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ── Ligne 3 : pills de stats ─────────────────────
                        if (_hasPills)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.x8, top: AppSpacing.x2),
                            child: Wrap(
                              spacing: AppSpacing.gapSm,
                              runSpacing: AppSpacing.gapSm,
                              children: _buildPills(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pills de données ────────────────────────────────────────────────────────

  bool get _hasPills {
    final hasConsumption =
        (voucher.uptime != null && voucher.uptime!.isNotEmpty && voucher.uptime != '0s') ||
        voucher.bytesIn > 0 ||
        voucher.bytesOut > 0;
    final hasLimits = (voucher.limitUptime != null && voucher.limitUptime!.isNotEmpty) || voucher.limitBytesTotal > 0;
    return hasConsumption || hasLimits;
  }

  List<Widget> _buildPills() {
    final pills = <Widget>[];

    // Durée consommée (± quota)
    final uptime = voucher.uptime;
    if (uptime != null && uptime.isNotEmpty && uptime != '0s') {
      final label = (voucher.limitUptime != null && voucher.limitUptime!.isNotEmpty)
          ? '$uptime / ${voucher.limitUptime}'
          : uptime;
      pills.add(_StatPill(icon: Icons.timer_outlined, label: label, iconColor: AppColors.info));
    } else if (voucher.limitUptime != null && voucher.limitUptime!.isNotEmpty) {
      pills.add(
        _StatPill(
          icon: Icons.hourglass_top_outlined,
          label: voucher.limitUptime!,
          iconColor: AppColors.textTertiary,
          prefix: 'Quota',
        ),
      );
    }

    // Download
    if (voucher.bytesIn > 0) {
      pills.add(
        _StatPill(
          icon: Icons.arrow_downward_rounded,
          label: _fmtBytes(voucher.bytesIn),
          iconColor: AppColors.statusActive,
          prefix: 'Reçu',
        ),
      );
    }

    // Upload
    if (voucher.bytesOut > 0) {
      pills.add(
        _StatPill(
          icon: Icons.arrow_upward_rounded,
          label: _fmtBytes(voucher.bytesOut),
          iconColor: AppColors.statusPending,
          prefix: 'Envoyé',
        ),
      );
    }

    // Quota données
    if (voucher.limitBytesTotal > 0) {
      final hasConso = voucher.bytesIn > 0 || voucher.bytesOut > 0;
      final label = hasConso
          ? '${_fmtBytes(voucher.bytesIn + voucher.bytesOut)} / ${voucher.limitBytesFmt}'
          : voucher.limitBytesFmt;
      pills.add(
        _StatPill(
          icon: Icons.data_usage_rounded,
          label: label,
          iconColor: AppColors.textTertiary,
          prefix: hasConso ? 'Données' : 'Quota',
        ),
      );
    }

    return pills;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static Widget get _dot => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gapSm),
    child: Container(
      width: AppSpacing.borderThick,
      height: AppSpacing.borderThick,
      decoration: const BoxDecoration(color: AppColors.textTertiary, shape: BoxShape.circle),
    ),
  );

  static String _fmtBytes(int bytes) {
    if (bytes <= 0) return '0';
    final gb = bytes / 1073741824;
    if (gb >= 1) return '${gb.toStringAsFixed(2)} Go';
    final mb = bytes / 1048576;
    if (mb >= 1) return '${mb.toStringAsFixed(1)} Mo';
    final kb = bytes / 1024;
    if (kb >= 1) return '${kb.toStringAsFixed(0)} Ko';
    return '$bytes o';
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tag (badge de statut ou label)
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;
  final bool dot;

  const _Tag({required this.label, required this.color, required this.bgColor, this.icon, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(color: bgColor, borderRadius: AppSpacing.borderFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: AppSpacing.x1 + AppSpacing.borderDefault,
              height: AppSpacing.x1 + AppSpacing.borderDefault,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: AppSpacing.gapXs),
          ],
          if (icon != null) ...[Icon(icon, size: AppSpacing.iconXs, color: color), SizedBox(width: AppSpacing.gapXs)],
          Text(label, style: AppTypography.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatPill — pill de métrique (uptime, bytes…)
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final String? prefix;

  const _StatPill({required this.icon, required this.label, required this.iconColor, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: AppSpacing.borderFull,
        border: Border.all(color: AppColors.borderSubtle, width: AppSpacing.borderThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconXs, color: iconColor),
          SizedBox(width: AppSpacing.gapXs),
          if (prefix != null) ...[
            Text('$prefix ', style: AppTypography.statSub.copyWith(color: AppColors.textTertiary)),
          ],
          Text(
            label,
            style: AppTypography.statSub.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
