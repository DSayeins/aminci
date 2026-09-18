import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/active_session.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/active_sessions/domain/usecases/disconnect_session.dart';
import 'package:aminci/features/active_sessions/domain/usecases/get_active_sessions.dart';

part 'active_sessions_event.dart';
part 'active_sessions_state.dart';

/// Intervalle de rafraîchissement automatique de la liste des sessions
/// actives — donnée live, jamais mise en cache.
const Duration _refreshInterval = Duration(seconds: 10);

class ActiveSessionsBloc extends Bloc<ActiveSessionsEvent, ActiveSessionsState> {
  final GetActiveSessions _getActiveSessions;
  final DisconnectSession _disconnectSession;

  MikroTikRouter? _router;
  Timer? _refreshTimer;

  ActiveSessionsBloc({
    required GetActiveSessions getActiveSessions,
    required DisconnectSession disconnectSession,
  })  : _getActiveSessions = getActiveSessions,
        _disconnectSession = disconnectSession,
        super(const ActiveSessionsInitial()) {
    on<ActiveSessionsLoadRequested>(_onLoadRequested);
    on<ActiveSessionsRefreshTicked>(_onRefreshTicked);
    on<ActiveSessionsStopped>(_onStopped);
    on<ActiveSessionsDisconnectRequested>(_onDisconnectRequested);
  }

  Future<void> _onLoadRequested(ActiveSessionsLoadRequested event, Emitter<ActiveSessionsState> emit) async {
    _router = event.router;
    emit(const ActiveSessionsLoading());
    await _fetch(emit);

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => add(const ActiveSessionsRefreshTicked()));
  }

  // Rafraîchissement silencieux périodique : ne montre pas le spinner plein
  // écran, et ignore les échecs ponctuels pour ne pas faire disparaître la
  // liste déjà affichée à cause d'un simple hoquet réseau.
  Future<void> _onRefreshTicked(ActiveSessionsRefreshTicked event, Emitter<ActiveSessionsState> emit) async {
    if (_router == null || state is! ActiveSessionsLoaded) return;
    await _fetch(emit, silent: true);
  }

  Future<void> _fetch(Emitter<ActiveSessionsState> emit, {bool silent = false}) async {
    final router = _router;
    if (router == null) return;

    final result = await _getActiveSessions(router);
    result.fold((failure) {
      if (!silent) emit(ActiveSessionsError(failure.message));
    }, (sessions) => emit(ActiveSessionsLoaded(sessions)));
  }

  void _onStopped(ActiveSessionsStopped event, Emitter<ActiveSessionsState> emit) {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _onDisconnectRequested(
    ActiveSessionsDisconnectRequested event,
    Emitter<ActiveSessionsState> emit,
  ) async {
    final current = state is ActiveSessionsLoaded ? (state as ActiveSessionsLoaded).sessions : <ActiveSession>[];
    emit(ActiveSessionsLoaded(current, isBusy: true));

    final result = await _disconnectSession(event.router, event.session);
    result.fold(
      (failure) => emit(ActiveSessionsError(failure.message, sessions: current)),
      (_) => emit(ActiveSessionsLoaded(current.where((s) => s.mikrotikId != event.session.mikrotikId).toList())),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
