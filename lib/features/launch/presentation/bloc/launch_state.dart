part of 'launch_bloc.dart';

sealed class LaunchState extends Equatable {
  const LaunchState();

  @override
  List<Object> get props => [];
}

/// État initial — vérification en cours.
final class LaunchInitial extends LaunchState {}

/// Premier lancement — aucun compte admin configuré.
/// → rediriger vers l'écran de création du compte admin.
final class LaunchFirstTime extends LaunchState {}

/// Session active trouvée — utilisateur déjà connecté.
/// → rediriger directement vers le shell principal.
final class LaunchAuthenticated extends LaunchState {}

/// Aucune session active — app déjà configurée.
/// → rediriger vers l'écran de login.
final class LaunchUnauthenticated extends LaunchState {}

/// Erreur lors de la vérification.
final class LaunchError extends LaunchState {
  final String message;

  const LaunchError(this.message);

  @override
  List<Object> get props => [message];
}
