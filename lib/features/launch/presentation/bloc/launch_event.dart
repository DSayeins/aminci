part of 'launch_bloc.dart';

sealed class LaunchEvent extends Equatable {
  const LaunchEvent();

  @override
  List<Object> get props => [];
}

/// Déclenché au démarrage de l'app pour vérifier l'état initial.
final class LaunchStarted extends LaunchEvent {
  const LaunchStarted();
}
