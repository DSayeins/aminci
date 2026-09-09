part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

/// État initial avant toute tentative de connexion.
final class LoginInitial extends LoginState {}

/// Connexion en cours.
final class LoginLoading extends LoginState {}

/// Connexion réussie — expose le [User] authentifié.
final class LoginAuthenticated extends LoginState {
  final User user;

  const LoginAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Erreur survenue lors de la connexion.
final class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object> get props => [message];
}
