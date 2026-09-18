part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final DashboardMetrics metrics;
  final int activeSessionsCount;

  const DashboardLoaded(this.metrics, {required this.activeSessionsCount});

  @override
  List<Object> get props => [metrics, activeSessionsCount];
}

final class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
