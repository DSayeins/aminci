part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// État initial avant toute vérification.
final class AuthInitial extends AuthState {}

/// Opération en cours (login, création...).
final class AuthLoading extends AuthState {}

/// Utilisateur connecté — expose le [User] actif.
final class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Aucune session active — redirige vers le login.
final class AuthUnauthenticated extends AuthState {}

/// Liste des utilisateurs chargée (admin uniquement).
final class AuthUsersLoaded extends AuthState {
  final List<User> users;

  const AuthUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

/// Erreur survenue lors d'une opération auth.
final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
