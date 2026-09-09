part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Tentative de connexion avec identifiants.
final class LoginRequested extends LoginEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

/// Session déjà active restaurée au démarrage (voir [LaunchBloc]) — pas de
/// nouvelle authentification, juste une réhydratation de l'état.
final class LoginSessionRestored extends LoginEvent {
  final User user;

  const LoginSessionRestored(this.user);

  @override
  List<Object> get props => [user];
}
