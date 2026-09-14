import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/core/enum/user_role.dart';
import 'package:aminci/core/router/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/features/app/app_sidebar.dart';
import 'package:aminci/features/app/app_topbar.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';

/// Coquille de l'application connectée (sidebar + topbar + contenu).
///
/// Utilisateur récupéré depuis [LoginBloc] — déjà obtenu au login réussi,
/// pas besoin de le recharger.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoginBloc>().state;
    if (loginState is! LoginAuthenticated) {
      // Aucune session en mémoire (ex. accès direct à /app sans passer par /login).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const Scaffold(backgroundColor: AppColors.bgPage, body: SizedBox.shrink());
    }

    final routersState = context.watch<RoutersBloc>().state;
    final selectedRouter = routersState is RoutersLoaded ? routersState.selectedRouter : null;
    if (selectedRouter == null) {
      // Aucun routeur choisi (ex. accès direct à /dashboard) — le shell a
      // besoin d'un routeur actif pour tout le reste.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/routers');
      });
      return const Scaffold(backgroundColor: AppColors.bgPage, body: SizedBox.shrink());
    }

    final user = loginState.user;
    final currentPath = GoRouterState.of(context).uri.path;
    final currentRoute = RoutesExtension.fromPath(currentPath);
    final availablePages = user.role == UserRole.admin ? RoutesExtension.forAdmin() : RoutesExtension.forOperator();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Row(
        children: [
          AppSidebar(availablePages: availablePages, currentRoute: currentRoute),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppTopBar(currentRoute: currentRoute),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
