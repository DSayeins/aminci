part of 'routers_bloc.dart';

sealed class RoutersEvent extends Equatable {
  const RoutersEvent();

  @override
  List<Object> get props => [];
}

/// Chargement initial de la liste des routeurs.
final class RoutersLoaded extends RoutersEvent {
  const RoutersLoaded();
}

/// Ajout d'un nouveau routeur.
final class RouterAdded extends RoutersEvent {
  final String name;
  final String ip;
  final int port;
  final String username;
  final String password;
  final RouterOsVersion rosVersion;

  const RouterAdded({
    required this.name,
    required this.ip,
    required this.port,
    required this.username,
    required this.password,
    required this.rosVersion,
  });

  @override
  List<Object> get props => [name, ip, port, username, rosVersion];
}

/// Modification d'un routeur existant.
final class RouterUpdated extends RoutersEvent {
  final int id;
  final String name;
  final String ip;
  final int port;
  final String username;
  final String password;
  final RouterOsVersion rosVersion;

  const RouterUpdated({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.username,
    required this.password,
    required this.rosVersion,
  });

  @override
  List<Object> get props => [id, name, ip, port, username, rosVersion];
}

/// Suppression d'un routeur.
final class RouterDeleted extends RoutersEvent {
  final int id;

  const RouterDeleted(this.id);

  @override
  List<Object> get props => [id];
}

/// Test de connexion TCP vers un routeur.
final class RouterConnectionTested extends RoutersEvent {
  final int id;

  const RouterConnectionTested(this.id);

  @override
  List<Object> get props => [id];
}
