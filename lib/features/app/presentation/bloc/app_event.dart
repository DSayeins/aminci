part of 'app_bloc.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

/// Démarrage de l'AppShell — charge l'utilisateur actif et initialise la navigation.
class AppStarted extends AppEvent {
  const AppStarted();
}

/// Naviguer vers une page spécifique.
class NavigateTo extends AppEvent {
  final Routes page;
  const NavigateTo(this.page);

  @override
  List<Object> get props => [page];
}

/// Déconnexion — supprime la session active et réinitialise la navigation.
class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

/// Réinitialiser la navigation (état interne).
class ResetNavigation extends AppEvent {}
