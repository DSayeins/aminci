import 'package:flutter/material.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';

/// Barre de filtres de la liste des vouchers : recherche par code + filtre
/// par statut (`null` = tous les statuts).
class VoucherFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoucherStatus? statusFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<VoucherStatus?> onStatusChanged;

  const VoucherFilterBar({
    super.key,
    required this.searchController,
    required this.statusFilter,
    required this.onQueryChanged,
    required this.onStatusChanged,
  });

  static const _statusOptions = <(VoucherStatus?, String)>[
    (null, 'Tous'),
    (VoucherStatus.pending, 'En attente'),
    (VoucherStatus.active, 'Actifs'),
    (VoucherStatus.expired, 'Expirés'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.paddingLg,
        AppSpacing.paddingMd,
        AppSpacing.paddingLg,
        0,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              controller: searchController,
              onChanged: onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un code…',
                prefixIcon: const Icon(Icons.search_rounded, size: AppSpacing.iconMd),
                fillColor: AppColors.bgSurface,
                isDense: true,
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: AppSpacing.iconMd),
                        onPressed: () {
                          searchController.clear();
                          onQueryChanged('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.gapLg),
          Wrap(
            spacing: AppSpacing.gapSm,
            children: [
              for (final (status, label) in _statusOptions)
                ChoiceChip(
                  label: Text(label),
                  selected: statusFilter == status,
                  onSelected: (_) => onStatusChanged(status),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
