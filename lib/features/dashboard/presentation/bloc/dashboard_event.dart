part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

/// Charge les métriques du dashboard pour [router], filtrées sur le hotspot
/// [hotspotName] (nom MikroTik du hotspot actuellement sélectionné).
final class DashboardLoadRequested extends DashboardEvent {
  final MikroTikRouter router;
  final String? hotspotName;

  const DashboardLoadRequested(this.router, {this.hotspotName});

  @override
  List<Object> get props => [router, if (hotspotName != null) hotspotName!];
}
