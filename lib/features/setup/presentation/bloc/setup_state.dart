part of 'setup_bloc.dart';

sealed class SetupState extends Equatable {
  const SetupState();

  @override
  List<Object> get props => [];
}

/// État initial — formulaire vide, prêt à saisir.
final class SetupInitial extends SetupState {}

/// Création du compte en cours.
final class SetupLoading extends SetupState {}

/// Compte créé avec succès — l'UI peut naviguer vers l'écran de login.
final class SetupSuccess extends SetupState {}

/// Échec de la création — [message] à afficher à l'utilisateur.
final class SetupError extends SetupState {
  final String message;

  const SetupError(this.message);

  @override
  List<Object> get props => [message];
}
