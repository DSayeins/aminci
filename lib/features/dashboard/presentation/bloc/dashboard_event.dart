part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

/// Charge les métriques du dashboard pour [router].
final class DashboardLoadRequested extends DashboardEvent {
  final MikroTikRouter router;

  const DashboardLoadRequested(this.router);

  @override
  List<Object> get props => [router];
}
