import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/shared/widgets/app_breadcrumb.dart';

class AppTopBar extends StatelessWidget {
  final Routes? currentRoute;

  const AppTopBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final routersState = context.watch<RoutersBloc>().state;
    final router = routersState is RoutersLoaded ? routersState.selectedRouter : null;
    final hotspotState = context.watch<HotspotBloc>().state;
    final hotspot = hotspotState is HotspotLoaded ? hotspotState.selected : null;
    final route = currentRoute;

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
                  AppBreadcrumb(
                    items: [
                      if (router != null)
                        BreadcrumbItem(
                          label: router.name,
                          icon: Icons.router_rounded,
                          onTap: () => context.go('/routers'),
                        ),
                      if (hotspot != null)
                        BreadcrumbItem(
                          label: hotspot.name,
                          icon: Icons.wifi_tethering_rounded,
                          onTap: () => context.go('/hotspots'),
                        ),
                      if (route != null) BreadcrumbItem(label: route.label, icon: route.icon),
                    ],
                  ),
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
