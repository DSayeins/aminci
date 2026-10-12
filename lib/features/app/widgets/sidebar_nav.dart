import 'package:flutter/material.dart';

import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/app/widgets/sidebar_nav_item.dart';

class SidebarNav extends StatelessWidget {
  final List<Routes> pages;
  final Routes? current;

  const SidebarNav({super.key, required this.pages, required this.current});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapSm),
      children: pages.map((page) => SidebarNavItem(page: page, isActive: page == current)).toList(),
    );
  }
}
