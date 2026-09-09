import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/features/logout/domain/usecases/logout.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final Logout _logout;

  LogoutBloc({required Logout logout}) : _logout = logout, super(LogoutInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<LogoutState> emit) async {
    emit(LogoutLoading());
    final result = await _logout();
    result.fold((failure) => emit(LogoutError(failure.message)), (_) => emit(LogoutSuccess()));
  }
}
