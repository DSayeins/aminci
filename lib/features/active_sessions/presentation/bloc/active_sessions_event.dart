part of 'active_sessions_bloc.dart';

sealed class ActiveSessionsEvent extends Equatable {
  const ActiveSessionsEvent();

  @override
  List<Object> get props => [];
}

/// Charge les sessions actives de [router] (déclenché à l'entrée sur
/// l'écran) et démarre le rafraîchissement automatique périodique.
final class ActiveSessionsLoadRequested extends ActiveSessionsEvent {
  final MikroTikRouter router;

  const ActiveSessionsLoadRequested(this.router);

  @override
  List<Object> get props => [router];
}

/// Déclenché en interne par le timer de rafraîchissement — recharge la
/// liste sans afficher de spinner plein écran.
final class ActiveSessionsRefreshTicked extends ActiveSessionsEvent {
  const ActiveSessionsRefreshTicked();
}

/// Arrête le rafraîchissement automatique — déclenché quand l'écran n'est
/// plus affiché, pour ne pas continuer à interroger le routeur en arrière-plan.
final class ActiveSessionsStopped extends ActiveSessionsEvent {
  const ActiveSessionsStopped();
}

/// Déconnecte [session] sur le routeur [router].
final class ActiveSessionsDisconnectRequested extends ActiveSessionsEvent {
  final MikroTikRouter router;
  final ActiveSession session;

  const ActiveSessionsDisconnectRequested(this.router, this.session);

  @override
  List<Object> get props => [router, session];
}
