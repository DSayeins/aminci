import 'package:flutter/material.dart';

/// Pages disponibles dans Aminci.
enum Routes { dashboard, sessions, profiles, history }

extension RoutesExtension on Routes {
  String get path {
    switch (this) {
      case Routes.dashboard:
        return '/dashboard';
      case Routes.sessions:
        return '/sessions';
      case Routes.profiles:
        return '/profiles';
      case Routes.history:
        return '/history';
    }
  }

  String get label {
    switch (this) {
      case Routes.dashboard:
        return 'Dashboard';
      case Routes.sessions:
        return 'Sessions actives';
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
      case Routes.profiles:
        return Icons.tune_rounded;
      case Routes.history:
        return Icons.history_rounded;
    }
  }

  static List<Routes> forAdmin() => Routes.values;
  static List<Routes> forOperator() => [Routes.history];

  static Routes? fromPath(String path) {
    for (final route in Routes.values) {
      if (route.path == path) return route;
    }
    return null;
  }
}
