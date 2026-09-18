part of 'active_sessions_bloc.dart';

sealed class ActiveSessionsState extends Equatable {
  const ActiveSessionsState();

  @override
  List<Object> get props => [];
}

final class ActiveSessionsInitial extends ActiveSessionsState {
  const ActiveSessionsInitial();
}

final class ActiveSessionsLoading extends ActiveSessionsState {
  const ActiveSessionsLoading();
}

final class ActiveSessionsLoaded extends ActiveSessionsState {
  final List<ActiveSession> sessions;
  final bool isBusy;

  const ActiveSessionsLoaded(this.sessions, {this.isBusy = false});

  @override
  List<Object> get props => [sessions, isBusy];
}

final class ActiveSessionsError extends ActiveSessionsState {
  final String message;
  final List<ActiveSession> sessions;

  const ActiveSessionsError(this.message, {this.sessions = const []});

  @override
  List<Object> get props => [message, sessions];
}
