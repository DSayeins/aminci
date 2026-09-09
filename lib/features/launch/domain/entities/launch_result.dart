import 'package:aminci/core/models/user.dart';

sealed class LaunchResult {
  const LaunchResult();
}

/// Aucun compte admin n'existe — l'app doit guider vers la création du compte.
class LaunchResultFirstLaunch extends LaunchResult {
  const LaunchResultFirstLaunch();
}

/// Une session active est persistée — l'app peut aller directement au shell.
class LaunchResultAuthenticated extends LaunchResult {
  final User user;

  const LaunchResultAuthenticated(this.user);
}

/// Pas de session active — l'app doit passer par l'écran de login.
class LaunchResultUnauthenticated extends LaunchResult {
  const LaunchResultUnauthenticated();
}
