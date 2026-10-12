import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.icon, this.onTap});
}

/// Fil d'Ariane : segments séparés par un chevron, le dernier étant la page
/// courante (non cliquable, mis en avant).
class AppBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const AppBreadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gapXs),
              child: Icon(Icons.chevron_right_rounded, size: AppSpacing.iconMd, color: AppColors.textTertiary),
            ),
          _BreadcrumbSegment(item: items[i], isCurrent: i == items.length - 1),
        ],
      ],
    );
  }
}

class _BreadcrumbSegment extends StatefulWidget {
  final BreadcrumbItem item;
  final bool isCurrent;

  const _BreadcrumbSegment({required this.item, required this.isCurrent});

  @override
  State<_BreadcrumbSegment> createState() => _BreadcrumbSegmentState();
}

class _BreadcrumbSegmentState extends State<_BreadcrumbSegment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final clickable = !widget.isCurrent && item.onTap != null;

    final color = widget.isCurrent
        ? AppColors.textPrimary
        : (clickable && _hovered ? AppColors.primary : AppColors.textSecondary);
    final style = widget.isCurrent
        ? AppTypography.topbarTitle.copyWith(color: color)
        : AppTypography.bodyMd.copyWith(color: color);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: widget.isCurrent ? AppSpacing.iconLg : AppSpacing.iconMd, color: color),
          const SizedBox(width: AppSpacing.gapXs),
        ],
        Text(item.label, style: style, overflow: TextOverflow.ellipsis),
      ],
    );

    if (!clickable) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: item.onTap, child: content),
    );
  }
}
