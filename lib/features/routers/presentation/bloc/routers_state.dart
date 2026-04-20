part of 'routers_bloc.dart';

sealed class RoutersState extends Equatable {
  const RoutersState();

  @override
  List<Object> get props => [];
}

/// État initial avant tout chargement.
final class RoutersInitial extends RoutersState {}

/// Chargement en cours.
final class RoutersLoading extends RoutersState {}

/// Liste chargée avec succès.
final class RoutersListLoaded extends RoutersState {
  final List<MikroTikRouter> routers;

  const RoutersListLoaded(this.routers);

  @override
  List<Object> get props => [routers];
}

/// Opération (ajout / modification / suppression) réussie.
/// Contient la liste mise à jour.
final class RoutersOperationSuccess extends RoutersState {
  final List<MikroTikRouter> routers;
  final String message;

  const RoutersOperationSuccess({required this.routers, required this.message});

  @override
  List<Object> get props => [routers, message];
}

/// Test de connexion en cours pour le routeur [routerId].
final class RouterTestingConnection extends RoutersState {
  final List<MikroTikRouter> routers;
  final int routerId;

  const RouterTestingConnection({required this.routers, required this.routerId});

  @override
  List<Object> get props => [routers, routerId];
}

/// Résultat du test de connexion.
final class RouterConnectionResult extends RoutersState {
  final List<MikroTikRouter> routers;
  final int routerId;
  final bool success;
  final String message;

  const RouterConnectionResult({
    required this.routers,
    required this.routerId,
    required this.success,
    required this.message,
  });

  @override
  List<Object> get props => [routers, routerId, success, message];
}

/// Erreur sur n'importe quelle opération.
final class RoutersError extends RoutersState {
  final String message;

  const RoutersError(this.message);

  @override
  List<Object> get props => [message];
}
