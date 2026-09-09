part of 'logout_bloc.dart';

sealed class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object> get props => [];
}

/// Demande de déconnexion de l'utilisateur courant.
final class LogoutRequested extends LogoutEvent {
  const LogoutRequested();
}
