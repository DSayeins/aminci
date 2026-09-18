import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/dashboard_metrics.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/domain/usecases/get_active_sessions.dart';
import 'package:aminci/features/dashboard/domain/usecases/get_dashboard_metrics.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardMetrics _getDashboardMetrics;
  final GetActiveSessions _getActiveSessions;

  DashboardBloc({
    required GetDashboardMetrics getDashboardMetrics,
    required GetActiveSessions getActiveSessions,
  })  : _getDashboardMetrics = getDashboardMetrics,
        _getActiveSessions = getActiveSessions,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(DashboardLoadRequested event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());

    final metricsResult = await _getDashboardMetrics(event.router.id);
    // Les sessions actives sont une donnée live secondaire — un échec de ce
    // fetch ne doit pas empêcher l'affichage des métriques principales.
    final activeSessionsResult = await _getActiveSessions(event.router);
    final activeSessionsCount = activeSessionsResult.fold((_) => 0, (sessions) => sessions.length);

    metricsResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (metrics) => emit(DashboardLoaded(metrics, activeSessionsCount: activeSessionsCount)),
    );
  }
}
