part of 'logout_bloc.dart';

sealed class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object> get props => [];
}

/// État initial, avant toute demande de déconnexion.
final class LogoutInitial extends LogoutState {}

/// Déconnexion en cours.
final class LogoutLoading extends LogoutState {}

/// Session fermée avec succès — l'écran doit rediriger vers `/login`.
final class LogoutSuccess extends LogoutState {}

/// Erreur survenue lors de la déconnexion.
final class LogoutError extends LogoutState {
  final String message;

  const LogoutError(this.message);

  @override
  List<Object> get props => [message];
}
