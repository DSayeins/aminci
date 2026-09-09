part of 'hotspot_bloc.dart';

sealed class HotspotState extends Equatable {
  const HotspotState();

  @override
  List<Object?> get props => [];
}

/// État initial — aucun routeur interrogé pour l'instant.
final class HotspotInitial extends HotspotState {
  const HotspotInitial();
}

final class HotspotLoading extends HotspotState {
  const HotspotLoading();
}

final class HotspotLoaded extends HotspotState {
  final List<Hotspot> hotspots;
  final Hotspot? selected;

  const HotspotLoaded(this.hotspots, {this.selected});

  HotspotLoaded copyWith({List<Hotspot>? hotspots, Hotspot? selected}) {
    return HotspotLoaded(hotspots ?? this.hotspots, selected: selected ?? this.selected);
  }

  @override
  List<Object?> get props => [hotspots, selected];
}

final class HotspotError extends HotspotState {
  final String message;

  const HotspotError(this.message);

  @override
  List<Object?> get props => [message];
}
