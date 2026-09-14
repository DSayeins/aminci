import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({super.key});

  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  MikroTikRouter? _router;

  @override
  void initState() {
    super.initState();
    final state = context.read<RoutersBloc>().state;
    _router = state is RoutersLoaded ? state.selectedRouter : null;

    final router = _router;
    if (router != null) {
      context.read<HotspotBloc>().add(HotspotsLoadRequested(router));
    } else {
      // Aucun routeur sélectionné — ne devrait pas arriver (on vient normalement
      // de /routers après avoir choisi un routeur), on renvoie par sécurité.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/routers');
      });
    }
  }

  void _retry() {
    final router = _router;
    if (router != null) context.read<HotspotBloc>().add(HotspotsLoadRequested(router));
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _Header(router: router),
          Expanded(child: _Body(onRetry: _retry)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Header
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final MikroTikRouter router;

  const _Header({required this.router});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin)),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.logoIconSize,
            height: AppSpacing.logoIconSize,
            decoration: const BoxDecoration(color: AppColors.logoBg, shape: BoxShape.circle),
            child: const Icon(Icons.wifi_tethering_rounded, color: AppColors.textOnPrimary, size: AppSpacing.iconMd),
          ),
          const SizedBox(width: AppSpacing.gapMd),
          Text('Aminci', style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
          const SizedBox(width: AppSpacing.gapXl),
          Container(width: AppSpacing.borderThin, height: AppSpacing.iconLg, color: AppColors.borderDefault),
          const SizedBox(width: AppSpacing.gapXl),
          Text('Hotspots — ${router.name}', style: AppTypography.topbarTitle.copyWith(color: AppColors.textPrimary)),

          const Spacer(),

          OutlinedButton.icon(
            onPressed: () => context.go('/routers'),
            icon: const Icon(Icons.arrow_back_rounded, size: AppSpacing.iconMd),
            label: const Text('Changer de routeur'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Corps — liste des hotspots
// -----------------------------------------------------------------------------

class _Body extends StatelessWidget {
  final VoidCallback onRetry;

  const _Body({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotspotBloc, HotspotState>(
      builder: (context, state) {
        if (state is HotspotLoading || state is HotspotInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HotspotError) {
          return ErrorView(message: state.message, onRetry: onRetry);
        }

        final loaded = state as HotspotLoaded;

        if (loaded.hotspots.isEmpty) {
          return const EmptyState(
            icon: Icons.wifi_tethering_rounded,
            title: 'Aucun hotspot configuré',
            subtitle: 'Configurez un serveur hotspot sur ce routeur\nvia WinBox pour pouvoir générer des vouchers.',
          );
        }

        return GridView.builder(
          padding: AppSpacing.insetPage,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: AppSpacing.gapMd,
            crossAxisSpacing: AppSpacing.gapMd,
            childAspectRatio: 0.85,
          ),
          itemCount: loaded.hotspots.length,
          itemBuilder: (context, index) {
            final hotspot = loaded.hotspots[index];
            return _HotspotCard(hotspot: hotspot, isSelected: loaded.selected?.mikrotikId == hotspot.mikrotikId);
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Carte hotspot
// -----------------------------------------------------------------------------

class _HotspotCard extends StatelessWidget {
  final Hotspot hotspot;
  final bool isSelected;

  const _HotspotCard({required this.hotspot, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetCard,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderDefault,
          width: isSelected ? AppSpacing.borderDefault : AppSpacing.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.x10,
                height: AppSpacing.x10,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.bgSubtle,
                  borderRadius: AppSpacing.borderMd,
                ),
                child: Icon(
                  Icons.wifi_tethering_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: AppSpacing.iconLg,
                ),
              ),
              const Spacer(),
              if (hotspot.disabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(color: AppColors.statusExpiredBg, borderRadius: AppSpacing.borderFull),
                  child: Text('Désactivé', style: AppTypography.badge.copyWith(color: AppColors.statusExpired)),
                )
              else if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3, vertical: AppSpacing.x1),
                  decoration: BoxDecoration(color: AppColors.statusActiveBg, borderRadius: AppSpacing.borderFull),
                  child: Text('Actif', style: AppTypography.badge.copyWith(color: AppColors.statusActive)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapLg),
          Text(
            hotspot.name,
            style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.gapXs),
          Text(
            '${hotspot.interface}${hotspot.addressPool != null ? '  •  ${hotspot.addressPool}' : ''}',
            style: AppTypography.techData.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          if (hotspot.profile != null) ...[
            const SizedBox(height: AppSpacing.gapXs),
            Text(
              'Profil : ${hotspot.profile}',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (hotspot.ipOfDnsName != null) ...[
            const SizedBox(height: AppSpacing.gapXs),
            Text(
              'DNS : ${hotspot.ipOfDnsName}',
              style: AppTypography.techData.copyWith(color: AppColors.textTertiary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.gapSm),
          Wrap(
            spacing: AppSpacing.gapXs,
            runSpacing: AppSpacing.gapXs,
            children: [
              _InfoChip(label: hotspot.https ? 'HTTPS' : 'HTTP'),
              if (hotspot.idleTimeout != null) _InfoChip(label: 'Inactivité ${hotspot.idleTimeout}'),
              if (hotspot.proxyStatus != null) _InfoChip(label: hotspot.proxyStatus!),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hotspot.disabled
                  ? null
                  : () {
                      context.read<HotspotBloc>().add(HotspotSelected(hotspot));
                      context.go('/dashboard');
                    },
              child: const Text('Utiliser'),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Petit badge d'info secondaire
// -----------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2, vertical: AppSpacing.x1),
      decoration: BoxDecoration(color: AppColors.bgSubtle, borderRadius: AppSpacing.borderSm),
      child: Text(label, style: AppTypography.badge.copyWith(color: AppColors.textSecondary)),
    );
  }
}
