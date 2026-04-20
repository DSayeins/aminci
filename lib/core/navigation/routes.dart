import 'package:flutter/material.dart';

/// Pages disponibles dans Aminci.
/// Le [AppBloc] filtre cette liste selon le rôle de l'utilisateur connecté.
enum Routes { dashboard, sessions, routers, profiles, history }

extension RoutesExtension on Routes {
  String get label {
    switch (this) {
      case Routes.dashboard:
        return 'Dashboard';
      case Routes.sessions:
        return 'Sessions actives';
      case Routes.routers:
        return 'Routeurs';
      case Routes.profiles:
        return 'Profils';
      case Routes.history:
        return 'Historique';
    }
  }

  IconData get icon {
    switch (this) {
      case Routes.dashboard:
        return Icons.bar_chart_rounded;
      case Routes.sessions:
        return Icons.sensors_rounded;
      case Routes.routers:
        return Icons.router_rounded;
      case Routes.profiles:
        return Icons.tune_rounded;
      case Routes.history:
        return Icons.history_rounded;
    }
  }

  /// Pages accessibles selon le rôle.
  static List<Routes> forAdmin() => Routes.values;
  static List<Routes> forOperator() => [Routes.history];
}
