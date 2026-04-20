part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Tentative de connexion avec identifiants.
final class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

/// Déconnexion de l'utilisateur courant.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Restauration de session au démarrage (via [GetActiveUser]).
final class AuthSessionRestored extends AuthEvent {
  const AuthSessionRestored();
}

/// Création d'un nouvel utilisateur (admin uniquement).
final class AuthUserCreated extends AuthEvent {
  final String username;
  final String password;
  final UserRole role;

  const AuthUserCreated({
    required this.username,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [username, password, role];
}

/// Chargement de la liste des utilisateurs (admin uniquement).
final class AuthUsersRequested extends AuthEvent {
  const AuthUsersRequested();
}

/// Suppression d'un utilisateur (admin uniquement).
final class AuthUserDeleted extends AuthEvent {
  final int userId;

  const AuthUserDeleted(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Changement de mot de passe.
final class AuthPasswordChanged extends AuthEvent {
  final int userId;
  final String newPassword;

  const AuthPasswordChanged({required this.userId, required this.newPassword});

  @override
  List<Object> get props => [userId, newPassword];
}
