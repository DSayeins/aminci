part of 'hotspot_bloc.dart';

sealed class HotspotEvent extends Equatable {
  const HotspotEvent();

  @override
  List<Object> get props => [];
}

/// Charge les hotspots du routeur [router] (déclenché à chaque changement de
/// routeur sélectionné — voir `RoutersBloc`).
final class HotspotsLoadRequested extends HotspotEvent {
  final MikroTikRouter router;

  const HotspotsLoadRequested(this.router);

  @override
  List<Object> get props => [router];
}

/// Sélectionne le hotspot actif parmi ceux déjà chargés.
final class HotspotSelected extends HotspotEvent {
  final Hotspot hotspot;

  const HotspotSelected(this.hotspot);

  @override
  List<Object> get props => [hotspot];
}
