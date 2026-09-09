part of 'setup_bloc.dart';

sealed class SetupEvent extends Equatable {
  const SetupEvent();

  @override
  List<Object> get props => [];
}

/// Change l'étape active du wizard (0 = compte admin, 1 = routeur, 2 = préférences).
class SetupStepChanged extends SetupEvent {
  final int step;

  const SetupStepChanged(this.step);

  @override
  List<Object> get props => [step];
}

class SetupSubmitted extends SetupEvent {
  final User user;
  final MikroTikRouter router;

  /// Préférences UI initiales — `null` conserve les valeurs par défaut (voir [Preference]).
  final Preference? preference;

  const SetupSubmitted({required this.user, required this.router, this.preference});

  @override
  List<Object> get props => [
    user,
    router,
    // `preference` est nullable — exclu de props (Equatable) plutôt que de
    // typer props en List<Object?> pour toute la hiérarchie SetupEvent.
  ];
}
